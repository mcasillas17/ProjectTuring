package repository

import (
	"context"
	"errors"
)

type ToolCallRecord struct {
	ToolCallID string
	RunID      string
	Status     string
	ApprovalID string
}

func (r *Repository) RecordToolCallBefore(ctx context.Context, record ToolCallRecord, agentID string, serverName string, toolName string, argsJSON string, argsHash string) error {
	status := record.Status
	if status == "" {
		status = "requested"
	}
	tx, err := r.db.BeginTx(ctx, nil)
	if err != nil {
		return err
	}
	defer tx.Rollback()
	var approvalID any
	if record.ApprovalID != "" {
		approvalID = record.ApprovalID
	}
	if _, err := tx.ExecContext(ctx, `INSERT INTO tool_calls (id, run_id, agent_id, server_name, tool_name, args_json, args_hash, status, approval_id, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`, record.ToolCallID, record.RunID, agentID, serverName, toolName, argsJSON, argsHash, status, approvalID, now()); err != nil {
		return err
	}
	return tx.Commit()
}

func (r *Repository) RecordToolCallAfter(ctx context.Context, toolCallID string, runID string, status string, resultSummary string, errorCode string, errorMessage string, durationMS int64) error {
	if status == "" {
		status = "completed"
	}
	tx, err := r.db.BeginTx(ctx, nil)
	if err != nil {
		return err
	}
	defer tx.Rollback()
	result, err := tx.ExecContext(ctx, `UPDATE tool_calls SET status = ?, result_summary = ?, error_code = ?, error_message = ?, duration_ms = ?, completed_at = ? WHERE id = ? AND run_id = ?`, status, nullableText(resultSummary), nullableText(errorCode), nullableText(errorMessage), durationMS, now(), toolCallID, runID)
	if err != nil {
		return err
	}
	changed, _ := result.RowsAffected()
	if changed != 1 {
		return errors.New("tool call not found")
	}
	return tx.Commit()
}

func nullableText(value string) any {
	if value == "" {
		return nil
	}
	return value
}
