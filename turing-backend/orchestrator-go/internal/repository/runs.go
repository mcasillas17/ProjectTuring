package repository

import (
	"context"
	"errors"
	"strings"

	turingv1 "github.com/mcasillas17/TuringAgent/gen/turing/v1/go/turing/v1"
	"google.golang.org/protobuf/encoding/protojson"
)

type Run struct {
	RunID   string
	Status  string
	TraceID string
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
	err := r.db.QueryRowContext(ctx, `SELECT id, status, trace_id FROM agent_runs WHERE id = ?`, runID).Scan(&run.RunID, &run.Status, &run.TraceID)
	return run, err
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
