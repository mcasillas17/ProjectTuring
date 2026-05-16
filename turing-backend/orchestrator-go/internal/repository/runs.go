package repository

import "context"

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

func (r *Repository) CancelRun(ctx context.Context, runID string, reason string) error {
	finishedAt := now()
	tx, err := r.db.BeginTx(ctx, nil)
	if err != nil {
		return err
	}
	defer tx.Rollback()
	if _, err := tx.ExecContext(ctx, `UPDATE agent_runs SET status = 'cancelled', cancellation_reason = ?, finished_at = ? WHERE id = ? AND status IN ('queued','running','waiting_approval')`, reason, finishedAt, runID); err != nil {
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
