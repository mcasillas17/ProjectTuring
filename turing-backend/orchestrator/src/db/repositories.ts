import type { TuringDatabase } from "./connection.js";

export type JsonObject = Record<string, unknown>;

export type SessionDetailRow = {
  sessionId: string;
  title: string | null;
  createdAt: string;
  updatedAt: string;
};

export type ToolCallSummaryRow = {
  id: string;
  runId: string;
  toolName: string;
  status: string;
  argsHash: string;
  approvalId: string | null;
  durationMs: number | null;
  createdAt: string;
  completedAt: string | null;
};

export function parseJson<T>(value: string): T {
  return JSON.parse(value) as T;
}

export function getSessionById(db: TuringDatabase, sessionId: string): SessionDetailRow | undefined {
  return db
    .prepare("SELECT id AS sessionId, title, created_at AS createdAt, updated_at AS updatedAt FROM sessions WHERE id = ?")
    .get(sessionId) as SessionDetailRow | undefined;
}

export function listToolCalls(db: TuringDatabase, limit = 100): ToolCallSummaryRow[] {
  return db
    .prepare(
      "SELECT id, run_id AS runId, tool_name AS toolName, status, args_hash AS argsHash, approval_id AS approvalId, duration_ms AS durationMs, created_at AS createdAt, completed_at AS completedAt FROM tool_calls ORDER BY created_at DESC LIMIT ?"
    )
    .all(limit) as ToolCallSummaryRow[];
}
