package repository

import (
	"context"
	"database/sql"
	"encoding/json"

	"github.com/mcasillas17/TuringAgent/turing-backend/orchestrator-go/internal/ids"
)

type EnqueueUserMessageInput struct {
	SessionID     string
	Content       string
	AgentID       string
	ModelProvider string
	Model         string
}

type EnqueueUserMessageResult struct {
	SessionID          string
	UserMessageID      string
	AssistantMessageID string
	RunID              string
	JobID              string
	TraceID            string
	Status             string
}

type Job struct {
	JobID              string
	RunID              string
	SessionID          string
	UserMessageID      string
	AssistantMessageID string
	TraceID            string
	ModelProvider      string
	Model              string
	UserText           string
	Attempt            int
}

func (r *Repository) EnqueueUserMessage(ctx context.Context, input EnqueueUserMessageInput) (EnqueueUserMessageResult, error) {
	createdAt := now()
	userMessageID := ids.New("msg")
	assistantMessageID := ids.New("msg")
	runID := ids.New("run")
	jobID := ids.New("job")
	traceID := ids.New("trace")
	tx, err := r.db.BeginTx(ctx, nil)
	if err != nil {
		return EnqueueUserMessageResult{}, err
	}
	defer tx.Rollback()
	var next int64
	if err := tx.QueryRowContext(ctx, `SELECT COALESCE(MAX(sequence), 0) + 1 FROM messages WHERE session_id = ?`, input.SessionID).Scan(&next); err != nil {
		return EnqueueUserMessageResult{}, err
	}
	if _, err := tx.ExecContext(ctx, `INSERT INTO messages (id, session_id, role, content, content_type, sequence, created_at) VALUES (?, ?, 'user', ?, 'text', ?, ?)`, userMessageID, input.SessionID, input.Content, next, createdAt); err != nil {
		return EnqueueUserMessageResult{}, err
	}
	if _, err := tx.ExecContext(ctx, `INSERT INTO messages (id, session_id, run_id, role, content, content_type, sequence, created_at) VALUES (?, ?, ?, 'assistant', '', 'text', ?, ?)`, assistantMessageID, input.SessionID, runID, next+1, createdAt); err != nil {
		return EnqueueUserMessageResult{}, err
	}
	if _, err := tx.ExecContext(ctx, `INSERT INTO agent_runs (id, session_id, user_message_id, assistant_message_id, agent_id, trace_id, status, model_provider, model_name, created_at) VALUES (?, ?, ?, ?, ?, ?, 'queued', ?, ?, ?)`, runID, input.SessionID, userMessageID, assistantMessageID, input.AgentID, traceID, input.ModelProvider, input.Model, createdAt); err != nil {
		return EnqueueUserMessageResult{}, err
	}
	payload, err := json.Marshal(map[string]any{
		"userText":           input.Content,
		"sessionId":          input.SessionID,
		"userMessageId":      userMessageID,
		"assistantMessageId": assistantMessageID,
		"traceId":            traceID,
		"modelProvider":      input.ModelProvider,
		"model":              input.Model,
	})
	if err != nil {
		return EnqueueUserMessageResult{}, err
	}
	if _, err := tx.ExecContext(ctx, `INSERT INTO jobs (id, run_id, agent_id, status, payload_json, created_at) VALUES (?, ?, ?, 'pending', ?, ?)`, jobID, runID, input.AgentID, string(payload), createdAt); err != nil {
		return EnqueueUserMessageResult{}, err
	}
	if err := tx.Commit(); err != nil {
		return EnqueueUserMessageResult{}, err
	}
	return EnqueueUserMessageResult{SessionID: input.SessionID, UserMessageID: userMessageID, AssistantMessageID: assistantMessageID, RunID: runID, JobID: jobID, TraceID: traceID, Status: "queued"}, nil
}

func (r *Repository) ClaimNextJob(ctx context.Context, agentID string, leaseOwner string) (Job, error) {
	pickedUpAt := now()
	tx, err := r.db.BeginTx(ctx, nil)
	if err != nil {
		return Job{}, err
	}
	defer tx.Rollback()
	var job Job
	var payloadJSON string
	err = tx.QueryRowContext(ctx, `
		SELECT
			j.id,
			j.run_id,
			r.session_id,
			r.user_message_id,
			COALESCE(r.assistant_message_id, ''),
			r.trace_id,
			r.model_provider,
			r.model_name,
			j.payload_json,
			j.attempt
		FROM jobs j
		JOIN agent_runs r ON r.id = j.run_id
		WHERE j.agent_id = ? AND j.status = 'pending' AND r.status = 'queued'
		ORDER BY j.created_at, j.id
		LIMIT 1
	`, agentID).Scan(
		&job.JobID,
		&job.RunID,
		&job.SessionID,
		&job.UserMessageID,
		&job.AssistantMessageID,
		&job.TraceID,
		&job.ModelProvider,
		&job.Model,
		&payloadJSON,
		&job.Attempt,
	)
	if err == sql.ErrNoRows {
		return Job{}, nil
	}
	if err != nil {
		return Job{}, err
	}
	var payload struct {
		UserText string `json:"userText"`
	}
	if err := json.Unmarshal([]byte(payloadJSON), &payload); err != nil {
		return Job{}, err
	}
	job.UserText = payload.UserText
	result, err := tx.ExecContext(ctx, `UPDATE jobs SET status = 'in_progress', lease_owner = ?, picked_up_at = ? WHERE id = ? AND status = 'pending'`, leaseOwner, pickedUpAt, job.JobID)
	if err != nil {
		return Job{}, err
	}
	if err := expectOneRow(result, "pending job not found for claim"); err != nil {
		return Job{}, err
	}
	result, err = tx.ExecContext(ctx, `UPDATE agent_runs SET status = 'running', started_at = COALESCE(started_at, ?), worker_id = ? WHERE id = ? AND status = 'queued'`, pickedUpAt, leaseOwner, job.RunID)
	if err != nil {
		return Job{}, err
	}
	if err := expectOneRow(result, "run is not queued"); err != nil {
		return Job{}, err
	}
	if err := tx.Commit(); err != nil {
		return Job{}, err
	}
	return job, nil
}
