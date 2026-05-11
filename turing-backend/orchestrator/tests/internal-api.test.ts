import { describe, expect, it } from "vitest";
import { buildInternalServerForTest, seedQueuedJob } from "./testServer.js";

const headers = { authorization: "Bearer internal" };

describe("internal API", () => {
  it("requires the internal token", async () => {
    const app = await buildInternalServerForTest();
    const response = await app.inject({ method: "GET", url: "/internal/jobs/next?agent=general_assistant" });
    expect(response.statusCode).toBe(401);
  });

  it("claims a queued job and appends a run event", async () => {
    const { app, db } = await buildInternalServerForTest();
    const seeded = seedQueuedJob(db);

    const claim = await app.inject({ method: "GET", url: "/internal/jobs/next?agent=general_assistant", headers });
    expect(claim.statusCode).toBe(200);
    expect(claim.json()).toMatchObject({ jobId: seeded.jobId, runId: seeded.runId });

    const event = await app.inject({
      method: "POST",
      url: `/internal/runs/${seeded.runId}/events`,
      headers,
      payload: {
        event: {
          sessionId: seeded.sessionId,
          runId: seeded.runId,
          traceId: seeded.traceId,
          type: "message.delta",
          payload: { messageId: seeded.assistantMessageId, delta: "hi" }
        }
      }
    });

    expect(event.statusCode).toBe(200);
    expect(event.json()).toMatchObject({ sequence: 2 });
  });

  it("requires completed runs to update their own assistant message", async () => {
    const { app, db } = await buildInternalServerForTest();
    const seeded = seedQueuedJob(db);
    const other = seedQueuedJob(db);

    await app.inject({ method: "GET", url: "/internal/jobs/next?agent=general_assistant", headers });
    const response = await app.inject({
      method: "POST",
      url: `/internal/runs/${seeded.runId}/complete`,
      headers,
      payload: { assistantMessageId: other.assistantMessageId, content: "wrong message" }
    });

    expect(response.statusCode).toBe(400);
    const otherMessage = db.prepare("SELECT content FROM messages WHERE id = ?").get(other.assistantMessageId) as { content: string };
    const run = db.prepare("SELECT status FROM agent_runs WHERE id = ?").get(seeded.runId) as { status: string };
    expect(otherMessage.content).toBe("");
    expect(run.status).toBe("running");
  });

  it("rejects tool-call after beacons that target a different run", async () => {
    const { app, db } = await buildInternalServerForTest();
    const runA = seedQueuedJob(db);
    const runB = seedQueuedJob(db);
    const toolCallId = "call_cross_run";

    await app.inject({ method: "GET", url: "/internal/jobs/next?agent=general_assistant", headers });
    await app.inject({ method: "GET", url: "/internal/jobs/next?agent=general_assistant", headers });

    const before = await app.inject({
      method: "POST",
      url: `/internal/runs/${runA.runId}/audit/tool-call`,
      headers,
      payload: {
        phase: "before",
        toolCallId,
        agentId: "general_assistant",
        serverName: "system",
        toolName: "system.time",
        args: { path: "alpha" },
        runId: runA.runId,
        traceId: runA.traceId
      }
    });
    expect(before.statusCode).toBe(200);

    const after = await app.inject({
      method: "POST",
      url: `/internal/runs/${runB.runId}/audit/tool-call`,
      headers,
      payload: {
        phase: "after",
        toolCallId,
        agentId: "general_assistant",
        serverName: "system",
        toolName: "system.time",
        status: "completed",
        resultSummary: "wrong run",
        durationMs: 10,
        runId: runB.runId,
        traceId: runB.traceId
      }
    });

    expect(after.statusCode).toBe(409);
    expect(after.json()).toMatchObject({ error: { code: "tool_call_run_mismatch", requestId: expect.any(String) } });
    const toolCall = db.prepare("SELECT run_id AS runId, status, completed_at AS completedAt FROM tool_calls WHERE id = ?").get(toolCallId) as {
      runId: string;
      status: string;
      completedAt: string | null;
    };
    expect(toolCall).toEqual({ runId: runA.runId, status: "requested", completedAt: null });
    const runBCompletedEvents = db
      .prepare("SELECT COUNT(*) AS count FROM events WHERE run_id = ? AND type = 'tool.call.completed'")
      .get(runB.runId) as { count: number };
    expect(runBCompletedEvents.count).toBe(0);
  });

  it("rejects run events whose traceId does not match the run", async () => {
    const { app, db } = await buildInternalServerForTest();
    const seeded = seedQueuedJob(db);

    await app.inject({ method: "GET", url: "/internal/jobs/next?agent=general_assistant", headers });
    const response = await app.inject({
      method: "POST",
      url: `/internal/runs/${seeded.runId}/events`,
      headers,
      payload: {
        event: {
          sessionId: seeded.sessionId,
          runId: seeded.runId,
          traceId: "trace_wrong",
          type: "message.delta",
          payload: { messageId: seeded.assistantMessageId, delta: "hi" }
        }
      }
    });

    expect(response.statusCode).toBe(400);
    expect(response.json()).toMatchObject({ error: { code: "invalid_request", requestId: expect.any(String) } });
    const persisted = db.prepare("SELECT COUNT(*) AS count FROM events WHERE run_id = ? AND type = 'message.delta'").get(seeded.runId) as { count: number };
    expect(persisted.count).toBe(0);
  });

  it("rejects run events that include server-generated replay fields", async () => {
    const { app, db } = await buildInternalServerForTest();
    const seeded = seedQueuedJob(db);

    await app.inject({ method: "GET", url: "/internal/jobs/next?agent=general_assistant", headers });
    const response = await app.inject({
      method: "POST",
      url: `/internal/runs/${seeded.runId}/events`,
      headers,
      payload: {
        event: {
          eventId: "evt_client_supplied",
          sequence: 999,
          sessionId: seeded.sessionId,
          runId: seeded.runId,
          traceId: seeded.traceId,
          type: "message.delta",
          payload: { messageId: seeded.assistantMessageId, delta: "hi" }
        }
      }
    });

    expect(response.statusCode).toBe(400);
    expect(response.json()).toMatchObject({ error: { code: "invalid_request", requestId: expect.any(String) } });
    const persisted = db.prepare("SELECT COUNT(*) AS count FROM events WHERE run_id = ? AND type = 'message.delta'").get(seeded.runId) as { count: number };
    expect(persisted.count).toBe(0);
  });

  it("rejects terminal run overwrites after completion", async () => {
    const { app, db } = await buildInternalServerForTest();
    const seeded = seedQueuedJob(db);

    await app.inject({ method: "GET", url: "/internal/jobs/next?agent=general_assistant", headers });
    const completed = await app.inject({
      method: "POST",
      url: `/internal/runs/${seeded.runId}/complete`,
      headers,
      payload: { assistantMessageId: seeded.assistantMessageId, content: "done" }
    });
    expect(completed.statusCode).toBe(200);

    const failed = await app.inject({
      method: "POST",
      url: `/internal/runs/${seeded.runId}/fail`,
      headers,
      payload: { code: "runtime_error", message: "too late" }
    });

    expect(failed.statusCode).toBe(409);
    expect(failed.json()).toMatchObject({ error: { code: "run_state_conflict", requestId: expect.any(String) } });
    const run = db.prepare("SELECT status, error_code AS errorCode, error_message AS errorMessage FROM agent_runs WHERE id = ?").get(seeded.runId) as {
      status: string;
      errorCode: string | null;
      errorMessage: string | null;
    };
    const job = db.prepare("SELECT status, error_code AS errorCode, error_message AS errorMessage FROM jobs WHERE id = ?").get(seeded.jobId) as {
      status: string;
      errorCode: string | null;
      errorMessage: string | null;
    };
    expect(run).toEqual({ status: "completed", errorCode: null, errorMessage: null });
    expect(job).toEqual({ status: "completed", errorCode: null, errorMessage: null });
  });

  it("uses canonical JSON for tool-call args hashes", async () => {
    const { app, db } = await buildInternalServerForTest();
    const seeded = seedQueuedJob(db);

    await app.inject({ method: "GET", url: "/internal/jobs/next?agent=general_assistant", headers });
    for (const [toolCallId, args] of [
      ["call_args_ab", { a: 1, b: 2 }],
      ["call_args_ba", { b: 2, a: 1 }]
    ] as const) {
      const response = await app.inject({
        method: "POST",
        url: `/internal/runs/${seeded.runId}/audit/tool-call`,
        headers,
        payload: {
          phase: "before",
          toolCallId,
          agentId: "general_assistant",
          serverName: "system",
          toolName: "system.time",
          args,
          runId: seeded.runId,
          traceId: seeded.traceId
        }
      });
      expect(response.statusCode).toBe(200);
    }

    const rows = db
      .prepare("SELECT id, args_json AS argsJson, args_hash AS argsHash FROM tool_calls WHERE id IN (?, ?) ORDER BY id")
      .all("call_args_ab", "call_args_ba") as { id: string; argsJson: string; argsHash: string }[];
    expect(rows).toHaveLength(2);
    expect(rows[0].argsHash).toBe(rows[1].argsHash);
    expect(rows.map((row) => row.argsJson)).toEqual(['{"a":1,"b":2}', '{"a":1,"b":2}']);
  });

  it("creates an approval and returns approval_required when a file tool needs approval", async () => {
    const { app, db } = await buildInternalServerForTest();
    const seeded = seedQueuedJob(db);

    await app.inject({ method: "GET", url: "/internal/jobs/next?agent=general_assistant", headers });
    const response = await app.inject({
      method: "POST",
      url: `/internal/runs/${seeded.runId}/audit/tool-call`,
      headers,
      payload: {
        phase: "before",
        toolCallId: "call_files_update",
        agentId: "general_assistant",
        serverName: "files",
        toolName: "files.update",
        args: { path: "note.txt", content: "hello" },
        runId: seeded.runId,
        traceId: seeded.traceId
      }
    });

    expect(response.statusCode).toBe(200);
    const body = response.json() as { decision: string; toolCallId: string; approvalId: string };
    expect(body.decision).toBe("approval_required");
    expect(body.toolCallId).toBe("call_files_update");
    expect(body.approvalId).toMatch(/^appr_/);

    const toolCall = db.prepare("SELECT status, approval_id AS approvalId FROM tool_calls WHERE id = ?").get("call_files_update") as {
      status: string;
      approvalId: string;
    };
    expect(toolCall.status).toBe("approval_required");
    expect(toolCall.approvalId).toBe(body.approvalId);

    const run = db.prepare("SELECT status FROM agent_runs WHERE id = ?").get(seeded.runId) as { status: string };
    expect(run.status).toBe("waiting_approval");

    const approvalEvent = db
      .prepare("SELECT type FROM events WHERE session_id = ? AND type = 'approval.requested'")
      .get(seeded.sessionId) as { type: string } | undefined;
    expect(approvalEvent?.type).toBe("approval.requested");
  });

  it("denies unknown tools instead of allowing them", async () => {
    const { app, db } = await buildInternalServerForTest();
    const seeded = seedQueuedJob(db);

    await app.inject({ method: "GET", url: "/internal/jobs/next?agent=general_assistant", headers });
    const response = await app.inject({
      method: "POST",
      url: `/internal/runs/${seeded.runId}/audit/tool-call`,
      headers,
      payload: {
        phase: "before",
        toolCallId: "call_unknown",
        agentId: "general_assistant",
        serverName: "system",
        toolName: "system.shell",
        args: {},
        runId: seeded.runId,
        traceId: seeded.traceId
      }
    });

    expect(response.statusCode).toBe(200);
    expect(response.json()).toMatchObject({
      decision: "deny",
      toolCallId: "call_unknown",
      reason: expect.stringContaining("Unknown")
    });
  });
});
