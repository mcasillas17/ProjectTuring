import { ulid } from "ulid";
import type { TuringDatabase } from "../db/connection.js";

export type AuditActorType = "client" | "runtime" | "mcp" | "system";

export type AuditLogRow = {
  id: string;
  correlationId: string | null;
  actorType: AuditActorType;
  actorId: string | null;
  action: string;
  target: string | null;
  payloadJson: string | null;
  createdAt: string;
};

export function createAuditService(db: TuringDatabase) {
  return {
    record(input: { correlationId?: string; actorType: AuditActorType; actorId?: string; action: string; target?: string; payload?: unknown }) {
      db.prepare("INSERT INTO audit_logs (id, correlation_id, actor_type, actor_id, action, target, payload_json, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?)").run(
        `audit_${ulid()}`,
        input.correlationId ?? null,
        input.actorType,
        input.actorId ?? null,
        input.action,
        input.target ?? null,
        input.payload === undefined ? null : JSON.stringify(input.payload),
        new Date().toISOString()
      );
    },

    list(limit = 100) {
      return db
        .prepare(
          "SELECT id, correlation_id AS correlationId, actor_type AS actorType, actor_id AS actorId, action, target, payload_json AS payloadJson, created_at AS createdAt FROM audit_logs ORDER BY created_at DESC LIMIT ?"
        )
        .all(limit) as AuditLogRow[];
    }
  };
}
