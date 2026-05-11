import { Buffer } from "node:buffer";
import { createHash } from "node:crypto";
import { SignJWT } from "jose";
import { ulid } from "ulid";
import type { TuringDatabase } from "../db/connection.js";
import { createAuditService } from "../audit/service.js";
import { createEventsService } from "../events/service.js";

type ApprovalStatus = "pending" | "approved" | "denied" | "expired" | "consumed";

type ApprovalRow = {
  id: string;
  run_id: string;
  tool_call_id: string | null;
  agent_id: string;
  tool_name: string;
  args_json: string;
  args_hash: string;
  status: ApprovalStatus;
  approval_jti: string | null;
  approval_token: string | null;
  expires_at: string;
  decided_at: string | null;
  consumed_at: string | null;
  created_at: string;
};

type RunCtx = { session_id: string; trace_id: string };

export function canonicalJson(value: unknown): string {
  if (value === undefined) throw new Error("Cannot canonicalize undefined value");
  if (value === null || typeof value !== "object") return JSON.stringify(value);
  if (Array.isArray(value)) return `[${value.map(canonicalJson).join(",")}]`;
  const entries = Object.entries(value as Record<string, unknown>).sort(([a], [b]) =>
    Buffer.compare(Buffer.from(a), Buffer.from(b))
  );
  return `{${entries
    .map(([key, item]) => {
      if (item === undefined) throw new Error(`Cannot canonicalize undefined value for key ${key}`);
      return `${JSON.stringify(key)}:${canonicalJson(item)}`;
    })
    .join(",")}}`;
}

export function stableArgsHash(args: unknown): string {
  return `sha256:${createHash("sha256").update(canonicalJson(args)).digest("hex")}`;
}

function summarizeArgs(args: Record<string, unknown>): string {
  const path = typeof args.path === "string" ? args.path : "unknown path";
  return `Requested change to ${path}`;
}

export function createApprovalsService(db: TuringDatabase, jwtSecret: string) {
  const events = createEventsService(db);
  const audit = createAuditService(db);

  function getRow(approvalId: string): ApprovalRow | undefined {
    return db.prepare("SELECT * FROM approvals WHERE id = ?").get(approvalId) as ApprovalRow | undefined;
  }

  function getRunCtx(runId: string): RunCtx {
    const row = db.prepare("SELECT session_id, trace_id FROM agent_runs WHERE id = ?").get(runId) as RunCtx | undefined;
    if (!row) throw new Error("Run not found");
    return row;
  }

  return {
    createApproval(input: { runId: string; toolCallId?: string; agentId: string; toolName: string; args: Record<string, unknown> }) {
      if (input.toolCallId) {
        const existing = db
          .prepare("SELECT id, status FROM approvals WHERE tool_call_id = ?")
          .get(input.toolCallId) as { id: string; status: ApprovalStatus } | undefined;
        if (existing) {
          return { approvalId: existing.id, status: existing.status, event: undefined };
        }
      }
      const approvalId = `appr_${ulid()}`;
      const now = new Date();
      const expiresAt = new Date(now.getTime() + 60_000).toISOString();
      const run = getRunCtx(input.runId);
      let requestedEvent: ReturnType<typeof events.append> | undefined;
      const tx = db.transaction(() => {
        db.prepare(
          "INSERT INTO approvals (id, run_id, tool_call_id, agent_id, tool_name, args_json, args_hash, status, expires_at, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, 'pending', ?, ?)"
        ).run(
          approvalId,
          input.runId,
          input.toolCallId ?? null,
          input.agentId,
          input.toolName,
          JSON.stringify(input.args),
          stableArgsHash(input.args),
          expiresAt,
          now.toISOString()
        );
        db.prepare("UPDATE agent_runs SET status = 'waiting_approval' WHERE id = ?").run(input.runId);
        requestedEvent = events.append({
          sessionId: run.session_id,
          runId: input.runId,
          traceId: run.trace_id,
          type: "approval.requested",
          payload: {
            approvalId,
            toolName: input.toolName,
            argsSummary: summarizeArgs(input.args)
          }
        });
      });
      tx();
      return { approvalId, status: "pending" as ApprovalStatus, event: requestedEvent };
    },

    get(approvalId: string): ApprovalRow {
      const row = getRow(approvalId);
      if (!row) throw new Error("Approval not found");
      return row;
    },

    getForRuntime(approvalId: string): { approvalId: string; status: ApprovalStatus; approvalToken?: string } | undefined {
      const row = getRow(approvalId);
      if (!row) return undefined;
      return {
        approvalId,
        status: row.status,
        approvalToken: row.status === "approved" && row.approval_token ? row.approval_token : undefined
      };
    },

    async approve(approvalId: string) {
      const approval = getRow(approvalId);
      if (!approval || approval.status !== "pending") throw new Error("Approval is not pending");
      const run = getRunCtx(approval.run_id);
      if (Date.parse(approval.expires_at) <= Date.now()) {
        const decidedAt = new Date().toISOString();
        const tx = db.transaction(() => {
          db.prepare("UPDATE approvals SET status = 'expired', decided_at = ? WHERE id = ? AND status = 'pending'").run(decidedAt, approvalId);
          db.prepare(
            "UPDATE agent_runs SET status = 'failed', error_code = 'approval_expired', error_message = 'Approval expired', finished_at = ? WHERE id = ? AND status = 'waiting_approval'"
          ).run(decidedAt, approval.run_id);
        });
        tx();
        events.append({
          sessionId: run.session_id,
          runId: approval.run_id,
          traceId: run.trace_id,
          type: "approval.expired",
          payload: { approvalId, toolName: approval.tool_name }
        });
        audit.record({
          correlationId: approval.run_id,
          actorType: "system",
          action: "approval.expired",
          target: approvalId,
          payload: { toolName: approval.tool_name }
        });
        throw new Error("Approval expired");
      }
      const secret = new TextEncoder().encode(jwtSecret);
      const exp = Math.floor(Date.now() / 1000) + 60;
      const token = await new SignJWT({
        tool: approval.tool_name,
        args_hash: approval.args_hash
      })
        .setProtectedHeader({ alg: "HS256" })
        .setIssuer("turing.orchestrator")
        .setSubject(approval.agent_id)
        .setAudience("mcp-files")
        .setJti(approval.id)
        .setIssuedAt()
        .setExpirationTime(exp)
        .sign(secret);
      const decidedAt = new Date().toISOString();
      const tx = db.transaction(() => {
        db.prepare(
          "UPDATE approvals SET status = 'approved', approval_jti = ?, approval_token = ?, decided_at = ? WHERE id = ?"
        ).run(approval.id, token, decidedAt, approval.id);
        db.prepare("UPDATE agent_runs SET status = 'running' WHERE id = ? AND status = 'waiting_approval'").run(approval.run_id);
      });
      tx();
      const event = events.append({
        sessionId: run.session_id,
        runId: approval.run_id,
        traceId: run.trace_id,
        type: "approval.approved",
        payload: { approvalId, toolName: approval.tool_name }
      });
      audit.record({
        correlationId: approval.run_id,
        actorType: "client",
        action: "approval.approved",
        target: approvalId,
        payload: { toolName: approval.tool_name }
      });
      return { approvalId, status: "approved" as const, event };
    },

    deny(approvalId: string) {
      const approval = getRow(approvalId);
      if (!approval || approval.status !== "pending") throw new Error("Approval is not pending");
      const run = getRunCtx(approval.run_id);
      const decidedAt = new Date().toISOString();
      const tx = db.transaction(() => {
        db.prepare("UPDATE approvals SET status = 'denied', decided_at = ? WHERE id = ? AND status = 'pending'").run(decidedAt, approvalId);
        db.prepare(
          "UPDATE agent_runs SET status = 'failed', error_code = 'approval_denied', error_message = 'User denied approval', finished_at = ? WHERE id = ?"
        ).run(decidedAt, approval.run_id);
      });
      tx();
      const event = events.append({
        sessionId: run.session_id,
        runId: approval.run_id,
        traceId: run.trace_id,
        type: "approval.denied",
        payload: { approvalId, toolName: approval.tool_name }
      });
      audit.record({
        correlationId: approval.run_id,
        actorType: "client",
        action: "approval.denied",
        target: approvalId,
        payload: { toolName: approval.tool_name }
      });
      return { approvalId, status: "denied" as const, event };
    },

    consume(approvalId: string) {
      const approval = getRow(approvalId);
      if (!approval) throw new Error("Approval is not approved");
      const run = getRunCtx(approval.run_id);
      const result = db
        .prepare("UPDATE approvals SET status = 'consumed', consumed_at = ? WHERE id = ? AND status = 'approved'")
        .run(new Date().toISOString(), approvalId);
      if (result.changes !== 1) throw new Error("Approval is not approved");
      const event = events.append({
        sessionId: run.session_id,
        runId: approval.run_id,
        traceId: run.trace_id,
        type: "approval.consumed",
        payload: { approvalId, toolName: approval.tool_name }
      });
      audit.record({
        correlationId: approval.run_id,
        actorType: "mcp",
        action: "approval.consumed",
        target: approvalId,
        payload: { toolName: approval.tool_name }
      });
      return { approvalId, status: "consumed" as const, event };
    },

    expirePendingApprovals(now: Date = new Date()) {
      const expired = db
        .prepare("SELECT id, run_id, tool_name FROM approvals WHERE status = 'pending' AND expires_at <= ?")
        .all(now.toISOString()) as Array<{ id: string; run_id: string; tool_name: string }>;
      const expiredEvents: ReturnType<typeof events.append>[] = [];
      const tx = db.transaction(() => {
        for (const approval of expired) {
          db.prepare("UPDATE approvals SET status = 'expired', decided_at = ? WHERE id = ? AND status = 'pending'").run(now.toISOString(), approval.id);
          db.prepare(
            "UPDATE agent_runs SET status = 'failed', error_code = 'approval_expired', error_message = 'Approval expired', finished_at = ? WHERE id = ? AND status = 'waiting_approval'"
          ).run(now.toISOString(), approval.run_id);
        }
      });
      tx();
      for (const approval of expired) {
        const run = getRunCtx(approval.run_id);
        expiredEvents.push(
          events.append({
            sessionId: run.session_id,
            runId: approval.run_id,
            traceId: run.trace_id,
            type: "approval.expired",
            payload: { approvalId: approval.id, toolName: approval.tool_name }
          })
        );
        audit.record({
          correlationId: approval.run_id,
          actorType: "system",
          action: "approval.expired",
          target: approval.id,
          payload: { toolName: approval.tool_name }
        });
      }
      return expiredEvents;
    }
  };
}
