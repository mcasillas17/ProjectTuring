import Database from "better-sqlite3";
import { describe, expect, it } from "vitest";
import { applyMigrations } from "../src/db/migrations.js";
import { createApprovalsService, stableArgsHash } from "../src/approvals/service.js";
import { seedQueuedJob } from "./testServer.js";

describe("approvals", () => {
  it("creates, emits approval.requested, approves, signs, and consumes an approval once", async () => {
    const db = new Database(":memory:");
    applyMigrations(db);
    const seeded = seedQueuedJob(db);
    const approvals = createApprovalsService(db, "secret");

    const created = approvals.createApproval({
      runId: seeded.runId,
      agentId: "general_assistant",
      toolName: "files.update",
      args: { path: "note.txt", content: "hello" }
    });
    expect((db.prepare("SELECT status FROM agent_runs WHERE id = ?").get(seeded.runId) as { status: string }).status).toBe("waiting_approval");
    const approvalEvent = db.prepare("SELECT type, payload_json FROM events WHERE session_id = ? AND type = 'approval.requested'").get(seeded.sessionId) as { type: string; payload_json: string };
    expect(approvalEvent.type).toBe("approval.requested");
    expect(JSON.parse(approvalEvent.payload_json)).toMatchObject({ approvalId: created.approvalId, toolName: "files.update" });

    const approved = await approvals.approve(created.approvalId);
    const runtimeApproval = approvals.getForRuntime(created.approvalId);

    expect(approved).toMatchObject({ approvalId: created.approvalId, status: "approved", event: expect.objectContaining({ type: "approval.approved" }) });
    expect(db.prepare("SELECT action FROM audit_logs WHERE action = 'approval.approved'").get()).toMatchObject({ action: "approval.approved" });
    expect(runtimeApproval?.approvalToken).toContain(".");
    expect((db.prepare("SELECT status FROM agent_runs WHERE id = ?").get(seeded.runId) as { status: string }).status).toBe("running");
    expect(stableArgsHash({ path: "note.txt", content: "hello" })).toMatch(/^sha256:/);
    expect(approvals.consume(created.approvalId)).toMatchObject({ approvalId: created.approvalId, status: "consumed", event: expect.objectContaining({ type: "approval.consumed" }) });
    expect(approvals.get(created.approvalId).status).toBe("consumed");
    expect(() => approvals.consume(created.approvalId)).toThrow(/not approved/);
  });

  it("reuses an existing approval for repeated before-beacons for the same tool call", () => {
    const db = new Database(":memory:");
    applyMigrations(db);
    const seeded = seedQueuedJob(db);
    db.prepare(
      "INSERT INTO tool_calls (id, run_id, agent_id, server_name, tool_name, args_json, args_hash, status, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, 'requested', ?)"
    ).run(
      "call_1",
      seeded.runId,
      "general_assistant",
      "files",
      "files.update",
      JSON.stringify({ path: "note.txt", content: "hello" }),
      "sha256:placeholder",
      new Date().toISOString()
    );
    const approvals = createApprovalsService(db, "secret");
    const input = {
      runId: seeded.runId,
      toolCallId: "call_1",
      agentId: "general_assistant",
      toolName: "files.update",
      args: { path: "note.txt", content: "hello" }
    };

    const first = approvals.createApproval(input);
    const second = approvals.createApproval(input);

    expect(second.approvalId).toBe(first.approvalId);
    expect(db.prepare("SELECT COUNT(*) AS count FROM approvals WHERE tool_call_id = 'call_1'").get()).toMatchObject({ count: 1 });
  });

  it("canonicalizes args with byte-order keys and rejects undefined values", () => {
    expect(stableArgsHash({ B: 1, a: 2 })).toBe("sha256:812e5e7fb7bb816dc477e91a136430192eadcf83ff303881298146e106ae0161");
    expect(() => stableArgsHash({ path: "note.txt", content: undefined })).toThrow(/undefined/);
  });

  it("expires pending approvals", () => {
    const db = new Database(":memory:");
    applyMigrations(db);
    const seeded = seedQueuedJob(db);
    const approvals = createApprovalsService(db, "secret");
    const created = approvals.createApproval({
      runId: seeded.runId,
      agentId: "general_assistant",
      toolName: "files.update",
      args: { path: "note.txt", content: "hello" }
    });
    db.prepare("UPDATE approvals SET expires_at = ? WHERE id = ?").run("2000-01-01T00:00:00.000Z", created.approvalId);
    expect(approvals.expirePendingApprovals(new Date("2000-01-01T00:00:01.000Z"))).toEqual([expect.objectContaining({ type: "approval.expired" })]);
    expect(approvals.get(created.approvalId).status).toBe("expired");
    expect(db.prepare("SELECT action FROM audit_logs WHERE action = 'approval.expired'").get()).toMatchObject({ action: "approval.expired" });
  });

  it("denies approvals with a durable event and audit entry", () => {
    const db = new Database(":memory:");
    applyMigrations(db);
    const seeded = seedQueuedJob(db);
    const approvals = createApprovalsService(db, "secret");
    const created = approvals.createApproval({
      runId: seeded.runId,
      agentId: "general_assistant",
      toolName: "files.update",
      args: { path: "note.txt", content: "hello" }
    });

    const denied = approvals.deny(created.approvalId);

    expect(denied).toMatchObject({ approvalId: created.approvalId, status: "denied", event: expect.objectContaining({ type: "approval.denied" }) });
    expect(db.prepare("SELECT action FROM audit_logs WHERE action = 'approval.denied'").get()).toMatchObject({ action: "approval.denied" });
  });

  it("does not approve an expired approval", async () => {
    const db = new Database(":memory:");
    applyMigrations(db);
    const seeded = seedQueuedJob(db);
    const approvals = createApprovalsService(db, "secret");
    const created = approvals.createApproval({
      runId: seeded.runId,
      agentId: "general_assistant",
      toolName: "files.update",
      args: { path: "note.txt", content: "hello" }
    });
    db.prepare("UPDATE approvals SET expires_at = ? WHERE id = ?").run("2000-01-01T00:00:00.000Z", created.approvalId);
    await expect(approvals.approve(created.approvalId)).rejects.toThrow(/expired/);
    expect(approvals.get(created.approvalId).status).toBe("expired");
  });
});
