package repository

import (
	"context"
	"path/filepath"
	"testing"

	"github.com/mcasillas17/TuringAgent/turing-backend/orchestrator-go/internal/db"
)

func openTestDB(t *testing.T) *db.DB {
	t.Helper()
	database, err := db.Open(filepath.Join(t.TempDir(), "turing.db"))
	if err != nil {
		t.Fatalf("open db: %v", err)
	}
	t.Cleanup(func() { _ = database.Close() })
	if err := db.ApplyMigrations(context.Background(), database); err != nil {
		t.Fatalf("apply migrations: %v", err)
	}
	return database
}

func TestSessionMessageRunJobTransaction(t *testing.T) {
	database := openTestDB(t)
	repo := New(database)
	ctx := context.Background()
	session, err := repo.CreateSession(ctx, "Test chat")
	if err != nil {
		t.Fatalf("CreateSession: %v", err)
	}
	result, err := repo.EnqueueUserMessage(ctx, EnqueueUserMessageInput{
		SessionID:     session.SessionID,
		Content:       "hello",
		AgentID:       "general_assistant",
		ModelProvider: "ollama",
		Model:         "llama3.2",
	})
	if err != nil {
		t.Fatalf("EnqueueUserMessage: %v", err)
	}
	messages, err := repo.ListMessages(ctx, session.SessionID, 50)
	if err != nil {
		t.Fatalf("ListMessages: %v", err)
	}
	if len(messages) != 2 {
		t.Fatalf("message count = %d, want 2", len(messages))
	}
	if result.Status != "queued" || result.RunID == "" || result.JobID == "" || result.TraceID == "" {
		t.Fatalf("bad enqueue result: %+v", result)
	}
}

func TestEventsAreSequencedPerSession(t *testing.T) {
	database := openTestDB(t)
	repo := New(database)
	ctx := context.Background()
	session, err := repo.CreateSession(ctx, "Events")
	if err != nil {
		t.Fatal(err)
	}
	first, err := repo.AppendEvent(ctx, AppendEventInput{SessionID: session.SessionID, TraceID: "trace_1", Type: "system", PayloadJSON: `{"a":1}`})
	if err != nil {
		t.Fatal(err)
	}
	second, err := repo.AppendEvent(ctx, AppendEventInput{SessionID: session.SessionID, TraceID: "trace_1", Type: "system", PayloadJSON: `{"b":2}`})
	if err != nil {
		t.Fatal(err)
	}
	if first.Sequence != 1 || second.Sequence != 2 {
		t.Fatalf("sequences = %d/%d", first.Sequence, second.Sequence)
	}
	replayed, latest, err := repo.ReplayEvents(ctx, session.SessionID, 1, 500)
	if err != nil {
		t.Fatal(err)
	}
	if latest != 2 || len(replayed) != 1 || replayed[0].Sequence != 2 {
		t.Fatalf("replay latest=%d events=%+v", latest, replayed)
	}
}

func TestCancelRunUpdatesRunAndJob(t *testing.T) {
	database := openTestDB(t)
	repo := New(database)
	ctx := context.Background()
	session, err := repo.CreateSession(ctx, "Cancel")
	if err != nil {
		t.Fatal(err)
	}
	enqueued, err := repo.EnqueueUserMessage(ctx, EnqueueUserMessageInput{
		SessionID: session.SessionID, Content: "cancel me", AgentID: "general_assistant", ModelProvider: "ollama", Model: "llama3.2",
	})
	if err != nil {
		t.Fatal(err)
	}
	if err := repo.MarkRunRunning(ctx, enqueued.RunID); err != nil {
		t.Fatal(err)
	}
	if err := repo.CancelRun(ctx, enqueued.RunID, "client_cancelled"); err != nil {
		t.Fatal(err)
	}
	run, err := repo.GetRun(ctx, enqueued.RunID)
	if err != nil {
		t.Fatal(err)
	}
	if run.Status != "cancelled" {
		t.Fatalf("run status = %q", run.Status)
	}
}
