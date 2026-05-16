package repository

import (
	"context"
	"encoding/json"
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
	if messages[0].MessageID != result.UserMessageID || messages[0].Role != "user" || messages[0].Content != "hello" {
		t.Fatalf("bad user message: %+v", messages[0])
	}
	if messages[1].MessageID != result.AssistantMessageID || messages[1].Role != "assistant" || messages[1].Content != "" {
		t.Fatalf("bad assistant message: %+v", messages[1])
	}
	var runStatus, runUserMessageID, runAssistantMessageID, runTraceID, runAgentID, runProvider, runModel string
	if err := database.QueryRowContext(ctx, `
		SELECT status, user_message_id, assistant_message_id, trace_id, agent_id, model_provider, model_name
		FROM agent_runs
		WHERE id = ?
	`, result.RunID).Scan(&runStatus, &runUserMessageID, &runAssistantMessageID, &runTraceID, &runAgentID, &runProvider, &runModel); err != nil {
		t.Fatalf("query run: %v", err)
	}
	if runStatus != "queued" || runUserMessageID != result.UserMessageID || runAssistantMessageID != result.AssistantMessageID || runTraceID != result.TraceID || runAgentID != "general_assistant" || runProvider != "ollama" || runModel != "llama3.2" {
		t.Fatalf("bad run row: status=%q user=%q assistant=%q trace=%q agent=%q provider=%q model=%q", runStatus, runUserMessageID, runAssistantMessageID, runTraceID, runAgentID, runProvider, runModel)
	}
	var jobRunID, jobAgentID, jobStatus, payloadJSON string
	if err := database.QueryRowContext(ctx, `
		SELECT run_id, agent_id, status, payload_json
		FROM jobs
		WHERE id = ?
	`, result.JobID).Scan(&jobRunID, &jobAgentID, &jobStatus, &payloadJSON); err != nil {
		t.Fatalf("query job: %v", err)
	}
	if jobRunID != result.RunID || jobAgentID != "general_assistant" || jobStatus != "pending" {
		t.Fatalf("bad job row: run=%q agent=%q status=%q", jobRunID, jobAgentID, jobStatus)
	}
	var payload map[string]string
	if err := json.Unmarshal([]byte(payloadJSON), &payload); err != nil {
		t.Fatalf("decode job payload: %v", err)
	}
	if payload["userMessageId"] != result.UserMessageID || payload["assistantMessageId"] != result.AssistantMessageID || payload["traceId"] != result.TraceID {
		t.Fatalf("bad job payload: %+v", payload)
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
	var jobStatus, errorCode, errorMessage string
	if err := database.QueryRowContext(ctx, `
		SELECT status, error_code, error_message
		FROM jobs
		WHERE id = ?
	`, enqueued.JobID).Scan(&jobStatus, &errorCode, &errorMessage); err != nil {
		t.Fatalf("query cancelled job: %v", err)
	}
	if jobStatus != "cancelled" || errorCode != "cancelled" || errorMessage != "client_cancelled" {
		t.Fatalf("bad cancelled job: status=%q error_code=%q error_message=%q", jobStatus, errorCode, errorMessage)
	}
}

func TestApprovalLifecycleRecordsTokenAndUpdatesRun(t *testing.T) {
	database := openTestDB(t)
	repo := New(database)
	ctx := context.Background()
	session, err := repo.CreateSession(ctx, "Approvals")
	if err != nil {
		t.Fatal(err)
	}
	enqueued, err := repo.EnqueueUserMessage(ctx, EnqueueUserMessageInput{
		SessionID: session.SessionID, Content: "needs approval", AgentID: "general_assistant", ModelProvider: "ollama", Model: "llama3.2",
	})
	if err != nil {
		t.Fatal(err)
	}
	if err := repo.RecordToolCallBefore(ctx, ToolCallRecord{ToolCallID: "tool_1", RunID: enqueued.RunID}, "general_assistant", "mcp-files", "write_file", `{"path":"notes.txt"}`, "args_hash_1"); err != nil {
		t.Fatal(err)
	}
	approval, err := repo.CreateApproval(ctx, enqueued.RunID, "tool_1", "general_assistant", "write_file", `{"path":"notes.txt"}`, "args_hash_1", "2099-01-01T00:00:00Z")
	if err != nil {
		t.Fatal(err)
	}
	approved, err := repo.ApproveApproval(ctx, approval.ApprovalID, "approval_token_1", "2026-05-15T00:00:00Z")
	if err != nil {
		t.Fatal(err)
	}
	if approved.Status != "approved" || approved.ApprovalToken != "approval_token_1" {
		t.Fatalf("bad approval record: %+v", approved)
	}
	run, err := repo.GetRun(ctx, enqueued.RunID)
	if err != nil {
		t.Fatal(err)
	}
	if run.Status != "running" {
		t.Fatalf("run status = %q", run.Status)
	}
	var approvalJTI, approvalToken string
	if err := database.QueryRowContext(ctx, `SELECT approval_jti, approval_token FROM approvals WHERE id = ?`, approval.ApprovalID).Scan(&approvalJTI, &approvalToken); err != nil {
		t.Fatalf("query approval token fields: %v", err)
	}
	if approvalJTI != approval.ApprovalID || approvalToken != "approval_token_1" {
		t.Fatalf("bad token fields: approval_jti=%q approval_token=%q", approvalJTI, approvalToken)
	}
	consumed, err := repo.ConsumeApproval(ctx, approval.ApprovalID, "2026-05-15T00:01:00Z")
	if err != nil {
		t.Fatal(err)
	}
	if consumed.Status != "consumed" {
		t.Fatalf("approval status after consume = %q", consumed.Status)
	}
}
