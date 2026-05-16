package repository

import (
	"context"
	"database/sql"
	"errors"
	"strings"

	turingv1 "github.com/mcasillas17/TuringAgent/gen/turing/v1/go/turing/v1"
	"github.com/mcasillas17/TuringAgent/turing-backend/orchestrator-go/internal/ids"
	"google.golang.org/protobuf/encoding/protojson"
)

type Run struct {
	RunID              string
	SessionID          string
	Status             string
	TraceID            string
	AssistantMessageID string
}

func (r *Repository) MarkRunRunning(ctx context.Context, runID string) error {
	startedAt := now()
	tx, err := r.db.BeginTx(ctx, nil)
	if err != nil {
		return err
	}
	defer tx.Rollback()
	result, err := tx.ExecContext(ctx, `UPDATE agent_runs SET status = 'running', started_at = ? WHERE id = ? AND status = 'queued'`, startedAt, runID)
	if err != nil {
		return err
	}
	if err := expectOneRow(result, "run is not queued"); err != nil {
		return err
	}
	result, err = tx.ExecContext(ctx, `UPDATE jobs SET status = 'in_progress', picked_up_at = ? WHERE run_id = ? AND status = 'pending'`, startedAt, runID)
	if err != nil {
		return err
	}
	if err := expectOneRow(result, "pending job not found for run"); err != nil {
		return err
	}
	return tx.Commit()
}

func (r *Repository) CompleteRun(ctx context.Context, runID string, assistantMessageID string, content string) error {
	finishedAt := now()
	tx, err := r.db.BeginTx(ctx, nil)
	if err != nil {
		return err
	}
	defer tx.Rollback()
	result, err := tx.ExecContext(ctx, `UPDATE agent_runs SET status = 'completed', finished_at = ? WHERE id = ? AND status IN ('running','waiting_approval')`, finishedAt, runID)
	if err != nil {
		return err
	}
	if err := expectOneRow(result, "run is not completable"); err != nil {
		return err
	}
	if assistantMessageID != "" {
		result, err = tx.ExecContext(ctx, `UPDATE messages SET content = ? WHERE id = ? AND run_id = ? AND role = 'assistant'`, content, assistantMessageID, runID)
		if err != nil {
			return err
		}
		if err := expectOneRow(result, "assistant message not found"); err != nil {
			return err
		}
	}
	if _, err := tx.ExecContext(ctx, `UPDATE jobs SET status = 'completed', finished_at = ? WHERE run_id = ? AND status IN ('pending','in_progress')`, finishedAt, runID); err != nil {
		return err
	}
	return tx.Commit()
}

func (r *Repository) CompleteRunWithEvent(ctx context.Context, runID string, assistantMessageID string, content string, payloadJSON string) (Event, error) {
	finishedAt := now()
	tx, err := r.db.BeginTx(ctx, nil)
	if err != nil {
		return Event{}, err
	}
	defer tx.Rollback()
	var sessionID, traceID string
	if err := tx.QueryRowContext(ctx, `SELECT session_id, trace_id FROM agent_runs WHERE id = ?`, runID).Scan(&sessionID, &traceID); err != nil {
		return Event{}, err
	}
	result, err := tx.ExecContext(ctx, `UPDATE agent_runs SET status = 'completed', finished_at = ? WHERE id = ? AND status IN ('running','waiting_approval')`, finishedAt, runID)
	if err != nil {
		return Event{}, err
	}
	if err := expectOneRow(result, "run is not completable"); err != nil {
		return Event{}, err
	}
	if assistantMessageID != "" {
		result, err = tx.ExecContext(ctx, `UPDATE messages SET content = ? WHERE id = ? AND run_id = ? AND role = 'assistant'`, content, assistantMessageID, runID)
		if err != nil {
			return Event{}, err
		}
		if err := expectOneRow(result, "assistant message not found"); err != nil {
			return Event{}, err
		}
	}
	if _, err := tx.ExecContext(ctx, `UPDATE jobs SET status = 'completed', finished_at = ? WHERE run_id = ? AND status IN ('pending','in_progress')`, finishedAt, runID); err != nil {
		return Event{}, err
	}
	event, err := appendRunEventTx(ctx, tx, sessionID, runID, traceID, "agent.run.completed", payloadJSON, finishedAt)
	if err != nil {
		return Event{}, err
	}
	if err := tx.Commit(); err != nil {
		return Event{}, err
	}
	return event, nil
}

func (r *Repository) FailRun(ctx context.Context, runID string, code string, message string) error {
	finishedAt := now()
	tx, err := r.db.BeginTx(ctx, nil)
	if err != nil {
		return err
	}
	defer tx.Rollback()
	result, err := tx.ExecContext(ctx, `UPDATE agent_runs SET status = 'failed', error_code = ?, error_message = ?, finished_at = ? WHERE id = ? AND status IN ('queued','running','waiting_approval')`, code, message, finishedAt, runID)
	if err != nil {
		return err
	}
	if err := expectOneRow(result, "run is not failable"); err != nil {
		return err
	}
	if _, err := tx.ExecContext(ctx, `UPDATE jobs SET status = 'failed', finished_at = ?, error_code = ?, error_message = ? WHERE run_id = ? AND status IN ('pending','in_progress')`, finishedAt, code, message, runID); err != nil {
		return err
	}
	return tx.Commit()
}

func (r *Repository) FailRunWithEvent(ctx context.Context, runID string, code string, message string, payloadJSON string) (Event, error) {
	finishedAt := now()
	tx, err := r.db.BeginTx(ctx, nil)
	if err != nil {
		return Event{}, err
	}
	defer tx.Rollback()
	var sessionID, traceID string
	if err := tx.QueryRowContext(ctx, `SELECT session_id, trace_id FROM agent_runs WHERE id = ?`, runID).Scan(&sessionID, &traceID); err != nil {
		return Event{}, err
	}
	result, err := tx.ExecContext(ctx, `UPDATE agent_runs SET status = 'failed', error_code = ?, error_message = ?, finished_at = ? WHERE id = ? AND status IN ('queued','running','waiting_approval')`, code, message, finishedAt, runID)
	if err != nil {
		return Event{}, err
	}
	if err := expectOneRow(result, "run is not failable"); err != nil {
		return Event{}, err
	}
	if _, err := tx.ExecContext(ctx, `UPDATE jobs SET status = 'failed', finished_at = ?, error_code = ?, error_message = ? WHERE run_id = ? AND status IN ('pending','in_progress')`, finishedAt, code, message, runID); err != nil {
		return Event{}, err
	}
	event, err := appendRunEventTx(ctx, tx, sessionID, runID, traceID, "agent.run.failed", payloadJSON, finishedAt)
	if err != nil {
		return Event{}, err
	}
	if err := tx.Commit(); err != nil {
		return Event{}, err
	}
	return event, nil
}

func (r *Repository) CancelRun(ctx context.Context, runID string, reason string) error {
	finishedAt := now()
	tx, err := r.db.BeginTx(ctx, nil)
	if err != nil {
		return err
	}
	defer tx.Rollback()
	result, err := tx.ExecContext(ctx, `UPDATE agent_runs SET status = 'cancelled', cancellation_reason = ?, finished_at = ? WHERE id = ? AND status IN ('queued','running','waiting_approval')`, reason, finishedAt, runID)
	if err != nil {
		return err
	}
	if err := expectOneRow(result, "run is not cancellable"); err != nil {
		return err
	}
	if _, err := tx.ExecContext(ctx, `UPDATE jobs SET status = 'cancelled', finished_at = ?, error_code = 'cancelled', error_message = ? WHERE run_id = ? AND status IN ('pending','in_progress')`, finishedAt, reason, runID); err != nil {
		return err
	}
	return tx.Commit()
}

func (r *Repository) GetRun(ctx context.Context, runID string) (Run, error) {
	var run Run
	err := r.db.QueryRowContext(ctx, `SELECT id, session_id, status, trace_id, COALESCE(assistant_message_id, '') FROM agent_runs WHERE id = ?`, runID).Scan(&run.RunID, &run.SessionID, &run.Status, &run.TraceID, &run.AssistantMessageID)
	return run, err
}

func appendRunEventTx(ctx context.Context, tx *sql.Tx, sessionID string, runID string, traceID string, eventType string, payloadJSON string, createdAt string) (Event, error) {
	if payloadJSON == "" {
		payloadJSON = "{}"
	}
	var sequence int64
	if err := tx.QueryRowContext(ctx, `SELECT COALESCE(MAX(sequence), 0) + 1 FROM events WHERE session_id = ?`, sessionID).Scan(&sequence); err != nil {
		return Event{}, err
	}
	event := Event{
		EventID:     ids.New("evt"),
		SessionID:   sessionID,
		RunID:       sql.NullString{String: runID, Valid: true},
		TraceID:     traceID,
		Sequence:    sequence,
		Type:        eventType,
		PayloadJSON: payloadJSON,
		CreatedAt:   createdAt,
	}
	if _, err := tx.ExecContext(ctx, `INSERT INTO events (id, session_id, run_id, trace_id, sequence, type, payload_json, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?)`, event.EventID, event.SessionID, runID, event.TraceID, event.Sequence, event.Type, event.PayloadJSON, event.CreatedAt); err != nil {
		return Event{}, err
	}
	return event, nil
}

func (r *Repository) AppendRuntimeEvent(ctx context.Context, event *turingv1.TuringEvent) (Event, error) {
	if event == nil {
		return Event{}, errors.New("runtime event is required")
	}
	payloadJSON := "{}"
	if event.Payload != nil {
		payload, err := protojson.Marshal(event.Payload)
		if err != nil {
			return Event{}, err
		}
		payloadJSON = string(payload)
	}
	return r.AppendEvent(ctx, AppendEventInput{
		SessionID:   event.SessionId,
		RunID:       event.RunId,
		TraceID:     event.TraceId,
		Type:        runtimeEventType(event.Type),
		PayloadJSON: payloadJSON,
	})
}

func runtimeEventType(value turingv1.TuringEventType) string {
	normalized := strings.ToLower(strings.TrimPrefix(value.String(), "TURING_EVENT_TYPE_"))
	return strings.ReplaceAll(normalized, "_", ".")
}
