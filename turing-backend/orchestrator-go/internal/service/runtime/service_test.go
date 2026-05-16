package runtime

import (
	"context"
	"database/sql"
	"encoding/json"
	"errors"
	"fmt"
	"net"
	"strings"
	"testing"
	"time"

	turingv1 "github.com/mcasillas17/TuringAgent/gen/turing/v1/go/turing/v1"
	"github.com/mcasillas17/TuringAgent/turing-backend/orchestrator-go/internal/auth"
	"github.com/mcasillas17/TuringAgent/turing-backend/orchestrator-go/internal/db"
	"github.com/mcasillas17/TuringAgent/turing-backend/orchestrator-go/internal/repository"
	"github.com/mcasillas17/TuringAgent/turing-backend/orchestrator-go/internal/service/events"
	"google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/credentials/insecure"
	"google.golang.org/grpc/metadata"
	"google.golang.org/grpc/status"
	"google.golang.org/grpc/test/bufconn"
	"google.golang.org/protobuf/types/known/structpb"
)

type harness struct {
	repo     *repository.Repository
	database *db.DB
	bus      *events.Bus
	service  *Server
	conn     *grpc.ClientConn
}

func newHarness(t *testing.T) *harness {
	t.Helper()
	database := openRuntimeTestDB(t)
	repo := repository.New(database)
	bus := events.NewBus(8)
	service := New(repo, bus)
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
	return &harness{repo: repo, database: database, bus: bus, service: service, conn: conn}
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
	return h.createRunningRunResult(t, content).RunID
}

func (h *harness) createRunningRunResult(t *testing.T, content string) repository.EnqueueUserMessageResult {
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
	return enqueued
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

func TestDispatchPendingPublishesRunStartedEvent(t *testing.T) {
	h := newHarness(t)
	sessionID := h.createSessionAndRun(t, "hello")
	ch, unsubscribe := h.bus.Subscribe(sessionID)
	defer unsubscribe()
	client := h.runtimeClient(t)
	stream, err := client.ConnectWorker(h.internalContext())
	if err != nil {
		t.Fatal(err)
	}
	defer func() { _ = stream.CloseSend() }()
	if err := stream.Send(&turingv1.RuntimeUpdate{Update: &turingv1.RuntimeUpdate_WorkerReady{WorkerReady: &turingv1.RuntimeWorkerReady{WorkerId: "worker-started", AgentId: turingv1.AgentId_AGENT_ID_GENERAL_ASSISTANT, MaxConcurrentRuns: 1}}}); err != nil {
		t.Fatal(err)
	}
	assigned := recvUntil(t, stream, func(cmd *turingv1.RuntimeCommand) bool {
		return cmd.GetRunAssigned() != nil
	}).GetRunAssigned()

	deadline := time.After(2 * time.Second)
	for {
		select {
		case <-deadline:
			t.Fatal("timed out waiting for agent.run.started event")
		case event := <-ch:
			if event.Type != "agent.run.started" || event.RunID != assigned.RunId || event.TraceID != assigned.TraceId {
				continue
			}
			var payload map[string]any
			if err := json.Unmarshal([]byte(event.PayloadJSON), &payload); err != nil {
				t.Fatalf("decode started payload: %v", err)
			}
			if payload["runId"] != assigned.RunId || payload["jobId"] != assigned.JobId || payload["status"] != "running" || payload["agentId"] != "general_assistant" || payload["attempt"] != float64(assigned.Attempt) {
				t.Fatalf("bad started payload: %+v", payload)
			}
			return
		}
	}
}

func TestCancelRunSendsRuntimeCommand(t *testing.T) {
	h := newHarness(t)
	enqueued := h.enqueueRun(t, "cancel me")
	client := h.runtimeClient(t)
	stream, err := client.ConnectWorker(h.internalContext())
	if err != nil {
		t.Fatal(err)
	}
	defer func() { _ = stream.CloseSend() }()
	if err := stream.Send(&turingv1.RuntimeUpdate{Update: &turingv1.RuntimeUpdate_WorkerReady{WorkerReady: &turingv1.RuntimeWorkerReady{WorkerId: "worker-1", AgentId: turingv1.AgentId_AGENT_ID_GENERAL_ASSISTANT, MaxConcurrentRuns: 1}}}); err != nil {
		t.Fatal(err)
	}
	assigned := recvUntil(t, stream, func(cmd *turingv1.RuntimeCommand) bool {
		assigned := cmd.GetRunAssigned()
		return assigned != nil && assigned.RunId == enqueued.RunID
	}).GetRunAssigned()
	h.service.CancelRun(context.Background(), assigned.RunId, "client_cancelled")
	recvUntil(t, stream, func(cmd *turingv1.RuntimeCommand) bool {
		cancel := cmd.GetRunCancelled()
		return cancel != nil && cancel.RunId == assigned.RunId
	})
}

func TestCancelRunOnlySendsToAssignedWorker(t *testing.T) {
	h := newHarness(t)
	first := h.enqueueRun(t, "cancel first")
	second := h.enqueueRun(t, "keep second")
	client := h.runtimeClient(t)
	ctx, cancel := context.WithTimeout(h.internalContext(), 2*time.Second)
	defer cancel()
	workerOne, err := client.ConnectWorker(ctx)
	if err != nil {
		t.Fatal(err)
	}
	defer func() { _ = workerOne.CloseSend() }()
	if err := workerOne.Send(&turingv1.RuntimeUpdate{Update: &turingv1.RuntimeUpdate_WorkerReady{WorkerReady: &turingv1.RuntimeWorkerReady{WorkerId: "worker-cancel-owner", AgentId: turingv1.AgentId_AGENT_ID_GENERAL_ASSISTANT, MaxConcurrentRuns: 1}}}); err != nil {
		t.Fatal(err)
	}
	recvUntil(t, workerOne, func(cmd *turingv1.RuntimeCommand) bool {
		assigned := cmd.GetRunAssigned()
		return assigned != nil && assigned.RunId == first.RunID
	})
	workerTwo, err := client.ConnectWorker(ctx)
	if err != nil {
		t.Fatal(err)
	}
	defer func() { _ = workerTwo.CloseSend() }()
	if err := workerTwo.Send(&turingv1.RuntimeUpdate{Update: &turingv1.RuntimeUpdate_WorkerReady{WorkerReady: &turingv1.RuntimeWorkerReady{WorkerId: "worker-cancel-bystander", AgentId: turingv1.AgentId_AGENT_ID_GENERAL_ASSISTANT, MaxConcurrentRuns: 1}}}); err != nil {
		t.Fatal(err)
	}
	recvUntil(t, workerTwo, func(cmd *turingv1.RuntimeCommand) bool {
		assigned := cmd.GetRunAssigned()
		return assigned != nil && assigned.RunId == second.RunID
	})

	h.service.CancelRun(context.Background(), first.RunID, "client_cancelled")
	recvUntil(t, workerOne, func(cmd *turingv1.RuntimeCommand) bool {
		cancel := cmd.GetRunCancelled()
		return cancel != nil && cancel.RunId == first.RunID
	})
	received := make(chan struct {
		cmd *turingv1.RuntimeCommand
		err error
	}, 1)
	go func() {
		cmd, err := workerTwo.Recv()
		received <- struct {
			cmd *turingv1.RuntimeCommand
			err error
		}{cmd: cmd, err: err}
	}()
	select {
	case result := <-received:
		if result.err != nil {
			t.Fatal(result.err)
		}
		if cancel := result.cmd.GetRunCancelled(); cancel != nil {
			t.Fatalf("bystander worker received cancellation: %+v", cancel)
		}
	case <-time.After(100 * time.Millisecond):
	}
}

func TestCancelRunDoesNotQueueForFutureWorker(t *testing.T) {
	h := newHarness(t)
	runID := h.createRunningRun(t, "already cancelled")
	h.service.CancelRun(context.Background(), runID, "client_cancelled")

	client := h.runtimeClient(t)
	ctx, cancel := context.WithCancel(h.internalContext())
	defer cancel()
	stream, err := client.ConnectWorker(ctx)
	if err != nil {
		t.Fatal(err)
	}
	defer func() { _ = stream.CloseSend() }()
	if err := stream.Send(&turingv1.RuntimeUpdate{Update: &turingv1.RuntimeUpdate_WorkerReady{WorkerReady: &turingv1.RuntimeWorkerReady{WorkerId: "worker-after-cancel", AgentId: turingv1.AgentId_AGENT_ID_GENERAL_ASSISTANT, MaxConcurrentRuns: 1}}}); err != nil {
		t.Fatal(err)
	}
	accepted := recvUntil(t, stream, func(cmd *turingv1.RuntimeCommand) bool {
		return cmd.GetWorkerAccepted() != nil
	})
	if accepted.GetWorkerAccepted().WorkerId != "worker-after-cancel" {
		t.Fatalf("accepted worker = %+v", accepted.GetWorkerAccepted())
	}

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
	case result := <-received:
		if result.err != nil {
			t.Fatal(result.err)
		}
		if cancel := result.cmd.GetRunCancelled(); cancel != nil && cancel.RunId == runID {
			t.Fatalf("received queued cancellation for future worker: %+v", cancel)
		}
	case <-time.After(100 * time.Millisecond):
	}
}

func TestDuplicateWorkerIDIsRejected(t *testing.T) {
	h := newHarness(t)
	client := h.runtimeClient(t)
	first, err := client.ConnectWorker(h.internalContext())
	if err != nil {
		t.Fatal(err)
	}
	defer func() { _ = first.CloseSend() }()
	ready := &turingv1.RuntimeUpdate{Update: &turingv1.RuntimeUpdate_WorkerReady{WorkerReady: &turingv1.RuntimeWorkerReady{WorkerId: "worker-1", AgentId: turingv1.AgentId_AGENT_ID_GENERAL_ASSISTANT, MaxConcurrentRuns: 1}}}
	if err := first.Send(ready); err != nil {
		t.Fatal(err)
	}
	recvUntil(t, first, func(cmd *turingv1.RuntimeCommand) bool {
		return cmd.GetWorkerAccepted() != nil
	})

	second, err := client.ConnectWorker(h.internalContext())
	if err != nil {
		t.Fatal(err)
	}
	defer func() { _ = second.CloseSend() }()
	if err := second.Send(ready); err != nil {
		t.Fatal(err)
	}
	_, err = second.Recv()
	if status.Code(err) != codes.AlreadyExists {
		t.Fatalf("duplicate worker error = %v, want AlreadyExists", err)
	}
}

func TestConnectWorkerRequeuesJobWhenAssignmentSendFails(t *testing.T) {
	h := newHarness(t)
	session, err := h.repo.CreateSession(context.Background(), "Runtime")
	if err != nil {
		t.Fatal(err)
	}
	enqueued, err := h.repo.EnqueueUserMessage(context.Background(), repository.EnqueueUserMessageInput{
		SessionID:     session.SessionID,
		Content:       "send failure",
		AgentID:       "general_assistant",
		ModelProvider: "ollama",
		Model:         "llama3.2",
	})
	if err != nil {
		t.Fatal(err)
	}
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()
	err = h.service.ConnectWorker(&failingAssignmentStream{
		ctx: ctx,
		ready: &turingv1.RuntimeUpdate{Update: &turingv1.RuntimeUpdate_WorkerReady{WorkerReady: &turingv1.RuntimeWorkerReady{
			WorkerId:          "worker-send-fails",
			AgentId:           turingv1.AgentId_AGENT_ID_GENERAL_ASSISTANT,
			MaxConcurrentRuns: 1,
		}}},
	})
	if err == nil {
		t.Fatal("ConnectWorker succeeded, want assignment send failure")
	}
	run, err := h.repo.GetRun(context.Background(), enqueued.RunID)
	if err != nil {
		t.Fatal(err)
	}
	if run.Status != "queued" {
		t.Fatalf("run status = %q, want queued after send failure", run.Status)
	}
	var jobStatus string
	var leaseOwner sql.NullString
	if err := h.database.QueryRowContext(context.Background(), `SELECT status, lease_owner FROM jobs WHERE id = ?`, enqueued.JobID).Scan(&jobStatus, &leaseOwner); err != nil {
		t.Fatal(err)
	}
	if jobStatus != "pending" || leaseOwner.Valid {
		t.Fatalf("job after send failure: status=%q lease_owner=%q", jobStatus, leaseOwner.String)
	}
}

type failingAssignmentStream struct {
	grpc.ServerStream
	ctx       context.Context
	ready     *turingv1.RuntimeUpdate
	readySent bool
}

func (s *failingAssignmentStream) Send(cmd *turingv1.RuntimeCommand) error {
	if cmd.GetWorkerAccepted() != nil {
		return nil
	}
	if cmd.GetRunAssigned() != nil {
		return errors.New("assignment send failed")
	}
	return nil
}

func (s *failingAssignmentStream) Recv() (*turingv1.RuntimeUpdate, error) {
	if !s.readySent {
		s.readySent = true
		return s.ready, nil
	}
	<-s.ctx.Done()
	return nil, s.ctx.Err()
}

func (s *failingAssignmentStream) Context() context.Context { return s.ctx }

func TestDispatchPendingRespectsWorkerMaxConcurrentRuns(t *testing.T) {
	h := newHarness(t)
	first := h.enqueueRun(t, "first")
	client := h.runtimeClient(t)
	ctx, cancel := context.WithTimeout(h.internalContext(), 2*time.Second)
	defer cancel()
	stream, err := client.ConnectWorker(ctx)
	if err != nil {
		t.Fatal(err)
	}
	defer func() { _ = stream.CloseSend() }()
	if err := stream.Send(&turingv1.RuntimeUpdate{Update: &turingv1.RuntimeUpdate_WorkerReady{WorkerReady: &turingv1.RuntimeWorkerReady{WorkerId: "worker-capacity", AgentId: turingv1.AgentId_AGENT_ID_GENERAL_ASSISTANT, MaxConcurrentRuns: 1}}}); err != nil {
		t.Fatal(err)
	}
	recvUntil(t, stream, func(cmd *turingv1.RuntimeCommand) bool {
		assigned := cmd.GetRunAssigned()
		return assigned != nil && assigned.RunId == first.RunID
	})
	second := h.enqueueRun(t, "second")
	if err := h.service.DispatchPending(context.Background()); err != nil {
		t.Fatal(err)
	}
	run, err := h.repo.GetRun(context.Background(), second.RunID)
	if err != nil {
		t.Fatal(err)
	}
	if run.Status != "queued" {
		t.Fatalf("second run status = %q, want queued while worker is at capacity", run.Status)
	}

	if err := stream.Send(&turingv1.RuntimeUpdate{Update: &turingv1.RuntimeUpdate_RunCompleted{RunCompleted: &turingv1.RuntimeRunCompleted{
		RunId:              first.RunID,
		AssistantMessageId: first.AssistantMessageID,
		Content:            "done",
	}}}); err != nil {
		t.Fatal(err)
	}
	recvUntil(t, stream, func(cmd *turingv1.RuntimeCommand) bool {
		assigned := cmd.GetRunAssigned()
		return assigned != nil && assigned.RunId == second.RunID
	})
}

func TestConnectWorkerHonorsMaxConcurrentAboveDefaultBuffer(t *testing.T) {
	h := newHarness(t)
	const runCount = 9
	enqueued := make(map[string]repository.EnqueueUserMessageResult, runCount)
	for i := 0; i < runCount; i++ {
		run := h.enqueueRun(t, fmt.Sprintf("run %d", i))
		enqueued[run.RunID] = run
	}
	client := h.runtimeClient(t)
	ctx, cancel := context.WithTimeout(h.internalContext(), 2*time.Second)
	defer cancel()
	stream, err := client.ConnectWorker(ctx)
	if err != nil {
		t.Fatal(err)
	}
	defer func() { _ = stream.CloseSend() }()
	if err := stream.Send(&turingv1.RuntimeUpdate{Update: &turingv1.RuntimeUpdate_WorkerReady{WorkerReady: &turingv1.RuntimeWorkerReady{WorkerId: "worker-large-capacity", AgentId: turingv1.AgentId_AGENT_ID_GENERAL_ASSISTANT, MaxConcurrentRuns: runCount}}}); err != nil {
		t.Fatal(err)
	}
	assigned := map[string]bool{}
	for len(assigned) < runCount {
		cmd := recvUntil(t, stream, func(cmd *turingv1.RuntimeCommand) bool {
			return cmd.GetRunAssigned() != nil
		})
		runID := cmd.GetRunAssigned().RunId
		if _, ok := enqueued[runID]; !ok {
			t.Fatalf("unexpected run assigned: %+v", cmd.GetRunAssigned())
		}
		assigned[runID] = true
	}
}

func TestRuntimeRejectsGenericTerminalEvents(t *testing.T) {
	h := newHarness(t)
	enqueued := h.createRunningRunResult(t, "generic terminal")
	err := h.service.applyUpdate(context.Background(), &turingv1.RuntimeUpdate{Update: &turingv1.RuntimeUpdate_Event{Event: &turingv1.TuringEvent{
		SessionId: enqueued.SessionID,
		RunId:     enqueued.RunID,
		TraceId:   enqueued.TraceID,
		Type:      turingv1.TuringEventType_TURING_EVENT_TYPE_AGENT_RUN_COMPLETED,
	}}})
	if status.Code(err) != codes.InvalidArgument {
		t.Fatalf("generic terminal event error = %v, want InvalidArgument", err)
	}
	run, err := h.repo.GetRun(context.Background(), enqueued.RunID)
	if err != nil {
		t.Fatal(err)
	}
	if run.Status != "running" {
		t.Fatalf("run status = %q, want running", run.Status)
	}
}

func TestRuntimeEventUsesPersistedRunSessionAndTrace(t *testing.T) {
	h := newHarness(t)
	enqueued := h.createRunningRunResult(t, "event session")
	otherSession, err := h.repo.CreateSession(context.Background(), "Other")
	if err != nil {
		t.Fatal(err)
	}
	payload, err := structpb.NewStruct(map[string]any{"delta": "hi"})
	if err != nil {
		t.Fatal(err)
	}
	if err := h.service.applyUpdate(context.Background(), &turingv1.RuntimeUpdate{Update: &turingv1.RuntimeUpdate_Event{Event: &turingv1.TuringEvent{
		SessionId: otherSession.SessionID,
		RunId:     enqueued.RunID,
		TraceId:   "trace_spoofed",
		Type:      turingv1.TuringEventType_TURING_EVENT_TYPE_MESSAGE_DELTA,
		Payload:   payload,
	}}}); err != nil {
		t.Fatal(err)
	}
	replayed, _, err := h.repo.ReplayEvents(context.Background(), enqueued.SessionID, enqueued.QueuedEvent.Sequence, 10)
	if err != nil {
		t.Fatal(err)
	}
	for _, event := range replayed {
		if event.Type == "message.delta" && event.RunID.Valid && event.RunID.String == enqueued.RunID {
			if event.SessionID != enqueued.SessionID || event.TraceID != enqueued.TraceID {
				t.Fatalf("event used spoofed metadata: %+v", event)
			}
			return
		}
	}
	t.Fatalf("message.delta not replayed for run session: %+v", replayed)
}

func TestRuntimeRejectsEventsWithoutRunID(t *testing.T) {
	h := newHarness(t)
	session, err := h.repo.CreateSession(context.Background(), "Runtime")
	if err != nil {
		t.Fatal(err)
	}
	err = h.service.applyUpdate(context.Background(), &turingv1.RuntimeUpdate{Update: &turingv1.RuntimeUpdate_Event{Event: &turingv1.TuringEvent{
		SessionId: session.SessionID,
		TraceId:   "trace_session",
		Type:      turingv1.TuringEventType_TURING_EVENT_TYPE_SYSTEM,
	}}})
	if status.Code(err) != codes.InvalidArgument {
		t.Fatalf("empty-run event error = %v, want InvalidArgument", err)
	}
}

func TestWorkerCannotCompleteAnotherWorkersRun(t *testing.T) {
	h := newHarness(t)
	first := h.enqueueRun(t, "first")
	second := h.enqueueRun(t, "second")
	client := h.runtimeClient(t)
	ctx, cancel := context.WithTimeout(h.internalContext(), 2*time.Second)
	defer cancel()
	workerOne, err := client.ConnectWorker(ctx)
	if err != nil {
		t.Fatal(err)
	}
	defer func() { _ = workerOne.CloseSend() }()
	if err := workerOne.Send(&turingv1.RuntimeUpdate{Update: &turingv1.RuntimeUpdate_WorkerReady{WorkerReady: &turingv1.RuntimeWorkerReady{WorkerId: "worker-owner-1", AgentId: turingv1.AgentId_AGENT_ID_GENERAL_ASSISTANT, MaxConcurrentRuns: 1}}}); err != nil {
		t.Fatal(err)
	}
	recvUntil(t, workerOne, func(cmd *turingv1.RuntimeCommand) bool {
		assigned := cmd.GetRunAssigned()
		return assigned != nil && assigned.RunId == first.RunID
	})
	workerTwo, err := client.ConnectWorker(ctx)
	if err != nil {
		t.Fatal(err)
	}
	defer func() { _ = workerTwo.CloseSend() }()
	if err := workerTwo.Send(&turingv1.RuntimeUpdate{Update: &turingv1.RuntimeUpdate_WorkerReady{WorkerReady: &turingv1.RuntimeWorkerReady{WorkerId: "worker-owner-2", AgentId: turingv1.AgentId_AGENT_ID_GENERAL_ASSISTANT, MaxConcurrentRuns: 1}}}); err != nil {
		t.Fatal(err)
	}
	recvUntil(t, workerTwo, func(cmd *turingv1.RuntimeCommand) bool {
		assigned := cmd.GetRunAssigned()
		return assigned != nil && assigned.RunId == second.RunID
	})
	if err := workerTwo.Send(&turingv1.RuntimeUpdate{Update: &turingv1.RuntimeUpdate_RunCompleted{RunCompleted: &turingv1.RuntimeRunCompleted{
		RunId:              first.RunID,
		AssistantMessageId: first.AssistantMessageID,
		Content:            "wrong worker",
	}}}); err != nil {
		t.Fatal(err)
	}
	time.Sleep(50 * time.Millisecond)
	run, err := h.repo.GetRun(context.Background(), first.RunID)
	if err != nil {
		t.Fatal(err)
	}
	if run.Status != "running" {
		t.Fatalf("first run status = %q, want running after wrong-worker completion", run.Status)
	}
}

func TestRunCancelledAckRequiresPersistedCancellation(t *testing.T) {
	h := newHarness(t)
	enqueued := h.createRunningRunResult(t, "bad ack")
	err := h.service.applyUpdate(context.Background(), &turingv1.RuntimeUpdate{Update: &turingv1.RuntimeUpdate_RunCancelledAck{RunCancelledAck: &turingv1.RuntimeCancelledAck{RunId: enqueued.RunID}}})
	if status.Code(err) != codes.FailedPrecondition {
		t.Fatalf("cancel ack error = %v, want FailedPrecondition", err)
	}
	run, err := h.repo.GetRun(context.Background(), enqueued.RunID)
	if err != nil {
		t.Fatal(err)
	}
	if run.Status != "running" {
		t.Fatalf("run status = %q, want running", run.Status)
	}
}

func TestRuntimeRejectsEventsAfterCancelledRun(t *testing.T) {
	h := newHarness(t)
	enqueued := h.createRunningRunResult(t, "cancelled event")
	if _, err := h.repo.CancelRunWithEvent(context.Background(), enqueued.RunID, "client_cancelled", `{"reason":"client_cancelled"}`); err != nil {
		t.Fatal(err)
	}
	payload, err := structpb.NewStruct(map[string]any{"delta": "late"})
	if err != nil {
		t.Fatal(err)
	}
	err = h.service.applyUpdate(context.Background(), &turingv1.RuntimeUpdate{Update: &turingv1.RuntimeUpdate_Event{Event: &turingv1.TuringEvent{
		RunId:   enqueued.RunID,
		Type:    turingv1.TuringEventType_TURING_EVENT_TYPE_MESSAGE_DELTA,
		Payload: payload,
	}}})
	if status.Code(err) != codes.FailedPrecondition {
		t.Fatalf("post-cancel event error = %v, want FailedPrecondition", err)
	}
	replayed, _, err := h.repo.ReplayEvents(context.Background(), enqueued.SessionID, enqueued.QueuedEvent.Sequence, 10)
	if err != nil {
		t.Fatal(err)
	}
	for _, event := range replayed {
		if event.Type == "message.delta" && event.RunID.Valid && event.RunID.String == enqueued.RunID {
			t.Fatalf("late event was persisted after cancellation: %+v", event)
		}
	}
}

func TestRunCompletedUsesPersistedAssistantMessageID(t *testing.T) {
	h := newHarness(t)
	enqueued := h.createRunningRunResult(t, "complete without message id")
	err := h.service.applyUpdate(context.Background(), &turingv1.RuntimeUpdate{Update: &turingv1.RuntimeUpdate_RunCompleted{RunCompleted: &turingv1.RuntimeRunCompleted{
		RunId:   enqueued.RunID,
		Content: "done",
	}}})
	if err != nil {
		t.Fatal(err)
	}
	var content string
	if err := h.database.QueryRowContext(context.Background(), `SELECT content FROM messages WHERE id = ?`, enqueued.AssistantMessageID).Scan(&content); err != nil {
		t.Fatal(err)
	}
	if content != "done" {
		t.Fatalf("assistant content = %q, want done", content)
	}
	replayed, _, err := h.repo.ReplayEvents(context.Background(), enqueued.SessionID, enqueued.QueuedEvent.Sequence, 10)
	if err != nil {
		t.Fatal(err)
	}
	for _, event := range replayed {
		if event.Type != "agent.run.completed" {
			continue
		}
		var payload map[string]string
		if err := json.Unmarshal([]byte(event.PayloadJSON), &payload); err != nil {
			t.Fatal(err)
		}
		if payload["assistantMessageId"] != enqueued.AssistantMessageID {
			t.Fatalf("completion payload = %+v", payload)
		}
		return
	}
	t.Fatal("agent.run.completed event not replayed")
}

func TestRunCompletedRejectsMismatchedAssistantMessageID(t *testing.T) {
	h := newHarness(t)
	enqueued := h.createRunningRunResult(t, "wrong assistant")
	err := h.service.applyUpdate(context.Background(), &turingv1.RuntimeUpdate{Update: &turingv1.RuntimeUpdate_RunCompleted{RunCompleted: &turingv1.RuntimeRunCompleted{
		RunId:              enqueued.RunID,
		AssistantMessageId: "msg_wrong",
		Content:            "wrong",
	}}})
	if status.Code(err) != codes.InvalidArgument {
		t.Fatalf("mismatched assistant message error = %v, want InvalidArgument", err)
	}
	run, err := h.repo.GetRun(context.Background(), enqueued.RunID)
	if err != nil {
		t.Fatal(err)
	}
	if run.Status != "running" {
		t.Fatalf("run status = %q, want running", run.Status)
	}
}

func TestToolBeaconRequiresRunID(t *testing.T) {
	h := newHarness(t)
	err := h.service.applyUpdate(context.Background(), &turingv1.RuntimeUpdate{Update: &turingv1.RuntimeUpdate_ToolBeacon{ToolBeacon: &turingv1.ToolCallBeacon{
		ToolCallId: "call_missing_run",
		AgentId:    turingv1.AgentId_AGENT_ID_GENERAL_ASSISTANT,
		ToolName:   "system.time",
	}}})
	if status.Code(err) != codes.InvalidArgument {
		t.Fatalf("tool beacon error = %v, want InvalidArgument", err)
	}
}

func TestToolBeaconRejectsTerminalRun(t *testing.T) {
	h := newHarness(t)
	enqueued := h.createRunningRunResult(t, "terminal beacon")
	if _, err := h.repo.CancelRunWithEvent(context.Background(), enqueued.RunID, "client_cancelled", `{"reason":"client_cancelled"}`); err != nil {
		t.Fatal(err)
	}
	err := h.service.applyUpdate(context.Background(), &turingv1.RuntimeUpdate{Update: &turingv1.RuntimeUpdate_ToolBeacon{ToolBeacon: &turingv1.ToolCallBeacon{
		RunId:      enqueued.RunID,
		TraceId:    enqueued.TraceID,
		ToolCallId: "call_terminal",
		AgentId:    turingv1.AgentId_AGENT_ID_GENERAL_ASSISTANT,
		ToolName:   "system.time",
	}}})
	if status.Code(err) != codes.FailedPrecondition {
		t.Fatalf("terminal tool beacon error = %v, want FailedPrecondition", err)
	}
}

func TestCancelRunWaitsForCommandBufferSpace(t *testing.T) {
	h := newHarness(t)
	commands := make(chan *turingv1.RuntimeCommand, 1)
	commands <- &turingv1.RuntimeCommand{Command: &turingv1.RuntimeCommand_WorkerAccepted{WorkerAccepted: &turingv1.RuntimeWorkerAccepted{WorkerId: "worker-buffered"}}}
	h.service.mu.Lock()
	h.service.workers["worker-buffered"] = &worker{commands: commands, maxConcurrent: 1, assignments: map[string]string{"run_buffered": "job_buffered"}}
	h.service.mu.Unlock()
	ctx, cancel := context.WithTimeout(context.Background(), time.Second)
	defer cancel()
	done := make(chan struct{})
	go func() {
		h.service.CancelRun(ctx, "run_buffered", "client_cancelled")
		close(done)
	}()
	time.Sleep(20 * time.Millisecond)
	<-commands
	select {
	case <-done:
		t.Fatal("CancelRun returned before buffer space was available")
	default:
	}
	select {
	case cmd := <-commands:
		cancel := cmd.GetRunCancelled()
		if cancel == nil || cancel.RunId != "run_buffered" {
			t.Fatalf("command = %+v, want run_cancelled", cmd)
		}
	case <-time.After(time.Second):
		t.Fatal("timed out waiting for cancellation command")
	}
	select {
	case <-done:
	case <-time.After(time.Second):
		t.Fatal("CancelRun did not return after cancellation delivery")
	}
}

func TestWorkerDisconnectRequeuesAssignedJob(t *testing.T) {
	h := newHarness(t)
	enqueued := h.enqueueRun(t, "disconnect")
	client := h.runtimeClient(t)
	stream, err := client.ConnectWorker(h.internalContext())
	if err != nil {
		t.Fatal(err)
	}
	if err := stream.Send(&turingv1.RuntimeUpdate{Update: &turingv1.RuntimeUpdate_WorkerReady{WorkerReady: &turingv1.RuntimeWorkerReady{WorkerId: "worker-disconnect", AgentId: turingv1.AgentId_AGENT_ID_GENERAL_ASSISTANT, MaxConcurrentRuns: 1}}}); err != nil {
		t.Fatal(err)
	}
	recvUntil(t, stream, func(cmd *turingv1.RuntimeCommand) bool {
		assigned := cmd.GetRunAssigned()
		return assigned != nil && assigned.RunId == enqueued.RunID
	})
	if err := stream.CloseSend(); err != nil {
		t.Fatal(err)
	}
	deadline := time.Now().Add(2 * time.Second)
	for time.Now().Before(deadline) {
		run, err := h.repo.GetRun(context.Background(), enqueued.RunID)
		if err == nil && run.Status == "queued" {
			var jobStatus string
			if err := h.database.QueryRowContext(context.Background(), `SELECT status FROM jobs WHERE id = ?`, enqueued.JobID).Scan(&jobStatus); err != nil {
				t.Fatal(err)
			}
			if jobStatus != "pending" {
				t.Fatalf("job status = %q, want pending", jobStatus)
			}
			return
		}
		time.Sleep(10 * time.Millisecond)
	}
	t.Fatal("assigned job was not requeued after worker disconnect")
}

func (h *harness) enqueueRun(t *testing.T, content string) repository.EnqueueUserMessageResult {
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
	return enqueued
}

func TestRunCompletedPublishesTerminalEvent(t *testing.T) {
	h := newHarness(t)
	enqueued := h.createRunningRunResult(t, "complete me")
	ch, unsubscribe := h.bus.Subscribe(enqueued.SessionID)
	defer unsubscribe()

	err := h.service.applyUpdate(context.Background(), &turingv1.RuntimeUpdate{Update: &turingv1.RuntimeUpdate_RunCompleted{RunCompleted: &turingv1.RuntimeRunCompleted{
		RunId:              enqueued.RunID,
		AssistantMessageId: enqueued.AssistantMessageID,
		Content:            "done",
	}}})
	if err != nil {
		t.Fatal(err)
	}

	event := recvBusEvent(t, ch, func(event events.Event) bool {
		return event.Type == "agent.run.completed" && event.RunID == enqueued.RunID
	})
	if event.TraceID != enqueued.TraceID {
		t.Fatalf("terminal event trace_id = %q, want %q", event.TraceID, enqueued.TraceID)
	}
	var payload map[string]string
	if err := json.Unmarshal([]byte(event.PayloadJSON), &payload); err != nil {
		t.Fatalf("decode payload: %v", err)
	}
	if payload["assistantMessageId"] != enqueued.AssistantMessageID {
		t.Fatalf("payload = %+v", payload)
	}
}

func TestRunFailedPublishesTerminalEvent(t *testing.T) {
	h := newHarness(t)
	enqueued := h.createRunningRunResult(t, "fail me")
	ch, unsubscribe := h.bus.Subscribe(enqueued.SessionID)
	defer unsubscribe()

	err := h.service.applyUpdate(context.Background(), &turingv1.RuntimeUpdate{Update: &turingv1.RuntimeUpdate_RunFailed{RunFailed: &turingv1.RuntimeRunFailed{
		RunId:     enqueued.RunID,
		Code:      "model_error",
		Message:   "model failed",
		Retryable: true,
	}}})
	if err != nil {
		t.Fatal(err)
	}

	event := recvBusEvent(t, ch, func(event events.Event) bool {
		return event.Type == "agent.run.failed" && event.RunID == enqueued.RunID
	})
	var payload struct {
		Code      string `json:"code"`
		Message   string `json:"message"`
		Retryable bool   `json:"retryable"`
	}
	if err := json.Unmarshal([]byte(event.PayloadJSON), &payload); err != nil {
		t.Fatalf("decode payload: %v", err)
	}
	if payload.Code != "model_error" || payload.Message != "model failed" || !payload.Retryable {
		t.Fatalf("payload = %+v", payload)
	}
}

func recvBusEvent(t *testing.T, ch <-chan events.Event, match func(events.Event) bool) events.Event {
	t.Helper()
	deadline := time.After(2 * time.Second)
	for {
		select {
		case <-deadline:
			t.Fatal("timed out waiting for bus event")
		case event := <-ch:
			if match(event) {
				return event
			}
		}
	}
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
