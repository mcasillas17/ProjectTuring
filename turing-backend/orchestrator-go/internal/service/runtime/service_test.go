package runtime

import (
	"context"
	"database/sql"
	"fmt"
	"net"
	"strings"
	"testing"
	"time"

	turingv1 "github.com/mcasillas17/TuringAgent/gen/turing/v1/go/turing/v1"
	"github.com/mcasillas17/TuringAgent/turing-backend/orchestrator-go/internal/auth"
	"github.com/mcasillas17/TuringAgent/turing-backend/orchestrator-go/internal/db"
	"github.com/mcasillas17/TuringAgent/turing-backend/orchestrator-go/internal/repository"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
	"google.golang.org/grpc/metadata"
	"google.golang.org/grpc/test/bufconn"
)

type harness struct {
	repo    *repository.Repository
	service *Server
	conn    *grpc.ClientConn
}

func newHarness(t *testing.T) *harness {
	t.Helper()
	database := openRuntimeTestDB(t)
	repo := repository.New(database)
	service := New(repo)
	lis := bufconn.Listen(1024 * 1024)
	grpcServer := grpc.NewServer(grpc.StreamInterceptor(auth.StreamInterceptor("internal-token")))
	turingv1.RegisterRuntimeServiceServer(grpcServer, service)
	go func() {
		_ = grpcServer.Serve(lis)
	}()
	conn, err := grpc.DialContext(context.Background(), "bufnet",
		grpc.WithContextDialer(func(context.Context, string) (net.Conn, error) {
			return lis.Dial()
		}),
		grpc.WithTransportCredentials(insecure.NewCredentials()),
	)
	if err != nil {
		t.Fatalf("dial bufconn: %v", err)
	}
	t.Cleanup(func() {
		grpcServer.Stop()
		_ = conn.Close()
	})
	return &harness{repo: repo, service: service, conn: conn}
}

func openRuntimeTestDB(t *testing.T) *db.DB {
	t.Helper()
	name := strings.NewReplacer("/", "_", " ", "_", ":", "_").Replace(t.Name())
	sqlDB, err := sql.Open("sqlite3", fmt.Sprintf("file:%s?mode=memory&cache=shared&_foreign_keys=on", name))
	if err != nil {
		t.Fatalf("open db: %v", err)
	}
	sqlDB.SetMaxOpenConns(1)
	database := &db.DB{DB: sqlDB}
	t.Cleanup(func() { _ = database.Close() })
	if err := db.ApplyMigrations(context.Background(), database); err != nil {
		t.Fatalf("apply migrations: %v", err)
	}
	return database
}

func (h *harness) runtimeClient(t *testing.T) turingv1.RuntimeServiceClient {
	t.Helper()
	return turingv1.NewRuntimeServiceClient(h.conn)
}

func (h *harness) internalContext() context.Context {
	return metadata.NewOutgoingContext(context.Background(), metadata.Pairs("authorization", "Bearer internal-token"))
}

func (h *harness) createSessionAndRun(t *testing.T, content string) string {
	t.Helper()
	session, err := h.repo.CreateSession(context.Background(), "Runtime")
	if err != nil {
		t.Fatalf("CreateSession: %v", err)
	}
	if _, err := h.repo.EnqueueUserMessage(context.Background(), repository.EnqueueUserMessageInput{
		SessionID:     session.SessionID,
		Content:       content,
		AgentID:       "general_assistant",
		ModelProvider: "ollama",
		Model:         "llama3.2",
	}); err != nil {
		t.Fatalf("EnqueueUserMessage: %v", err)
	}
	return session.SessionID
}

func (h *harness) createRunningRun(t *testing.T, content string) string {
	t.Helper()
	session, err := h.repo.CreateSession(context.Background(), "Runtime")
	if err != nil {
		t.Fatalf("CreateSession: %v", err)
	}
	enqueued, err := h.repo.EnqueueUserMessage(context.Background(), repository.EnqueueUserMessageInput{
		SessionID:     session.SessionID,
		Content:       content,
		AgentID:       "general_assistant",
		ModelProvider: "ollama",
		Model:         "llama3.2",
	})
	if err != nil {
		t.Fatalf("EnqueueUserMessage: %v", err)
	}
	if err := h.repo.MarkRunRunning(context.Background(), enqueued.RunID); err != nil {
		t.Fatalf("MarkRunRunning: %v", err)
	}
	return enqueued.RunID
}

func TestAssignsPendingJobToReadyWorker(t *testing.T) {
	h := newHarness(t)
	sessionID := h.createSessionAndRun(t, "hello")
	_ = sessionID
	client := h.runtimeClient(t)
	stream, err := client.ConnectWorker(h.internalContext())
	if err != nil {
		t.Fatal(err)
	}
	defer func() { _ = stream.CloseSend() }()
	if err := stream.Send(&turingv1.RuntimeUpdate{Update: &turingv1.RuntimeUpdate_WorkerReady{WorkerReady: &turingv1.RuntimeWorkerReady{WorkerId: "worker-1", AgentId: turingv1.AgentId_AGENT_ID_GENERAL_ASSISTANT, MaxConcurrentRuns: 1}}}); err != nil {
		t.Fatal(err)
	}
	cmd := recvUntil(t, stream, func(cmd *turingv1.RuntimeCommand) bool {
		return cmd.GetRunAssigned() != nil
	})
	if cmd.GetRunAssigned() == nil {
		t.Fatalf("command = %T, want run_assigned", cmd.Command)
	}
}

func TestCancelRunSendsRuntimeCommand(t *testing.T) {
	h := newHarness(t)
	runID := h.createRunningRun(t, "cancel me")
	client := h.runtimeClient(t)
	stream, err := client.ConnectWorker(h.internalContext())
	if err != nil {
		t.Fatal(err)
	}
	defer func() { _ = stream.CloseSend() }()
	if err := stream.Send(&turingv1.RuntimeUpdate{Update: &turingv1.RuntimeUpdate_WorkerReady{WorkerReady: &turingv1.RuntimeWorkerReady{WorkerId: "worker-1", AgentId: turingv1.AgentId_AGENT_ID_GENERAL_ASSISTANT, MaxConcurrentRuns: 1}}}); err != nil {
		t.Fatal(err)
	}
	h.service.CancelRun(context.Background(), runID, "client_cancelled")
	recvUntil(t, stream, func(cmd *turingv1.RuntimeCommand) bool {
		cancel := cmd.GetRunCancelled()
		return cancel != nil && cancel.RunId == runID
	})
}

func recvUntil(t *testing.T, stream turingv1.RuntimeService_ConnectWorkerClient, match func(*turingv1.RuntimeCommand) bool) *turingv1.RuntimeCommand {
	t.Helper()
	deadline := time.After(2 * time.Second)
	for {
		received := make(chan struct {
			cmd *turingv1.RuntimeCommand
			err error
		}, 1)
		go func() {
			cmd, err := stream.Recv()
			received <- struct {
				cmd *turingv1.RuntimeCommand
				err error
			}{cmd: cmd, err: err}
		}()
		select {
		case <-deadline:
			t.Fatal("timed out waiting for runtime command")
		case result := <-received:
			if result.err != nil {
				t.Fatal(result.err)
			}
			if match(result.cmd) {
				return result.cmd
			}
		}
	}
}
