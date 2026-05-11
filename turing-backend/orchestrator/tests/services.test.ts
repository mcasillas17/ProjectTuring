import Database from "better-sqlite3";
import { describe, expect, it } from "vitest";
import { applyMigrations } from "../src/db/migrations.js";
import { createSessionsService } from "../src/sessions/service.js";
import { createJobsService } from "../src/jobs/service.js";

function createTestServices(config = { jobTimeoutMs: 300000, maxAttempts: 3 }) {
  const db = new Database(":memory:");
  applyMigrations(db);

  return {
    db,
    sessions: createSessionsService(db),
    jobs: createJobsService(db, config)
  };
}

describe("sessions and jobs services", () => {
  it("creates a session, message, run, and claimable job", () => {
    const { sessions, jobs } = createTestServices();

    const session = sessions.createSession({ title: "Test" });
    const queued = sessions.enqueueUserMessage({
      sessionId: session.sessionId,
      content: "hello",
      agentId: "general_assistant",
      modelProvider: "ollama",
      model: "llama3.2"
    });

    const job = jobs.claimNext("general_assistant");
    expect(job?.jobId).toBe(queued.jobId);
    expect(job?.payload.userText).toBe("hello");
  });

  it("does not claim jobs for non-queued runs", () => {
    const { db, sessions, jobs } = createTestServices();

    const session = sessions.createSession({ title: "Cancelled" });
    const queued = sessions.enqueueUserMessage({
      sessionId: session.sessionId,
      content: "hello",
      agentId: "general_assistant",
      modelProvider: "ollama",
      model: "llama3.2"
    });
    db.prepare("UPDATE agent_runs SET status = 'cancelled' WHERE id = ?").run(queued.runId);

    expect(jobs.claimNext("general_assistant")).toBeUndefined();
    const row = db.prepare("SELECT status FROM jobs WHERE id = ?").get(queued.jobId) as { status: string };
    expect(row.status).toBe("pending");
  });

  it("returns API-shaped session and message identifiers", () => {
    const { sessions } = createTestServices();

    const session = sessions.createSession({ title: "Public shape" });
    const queued = sessions.enqueueUserMessage({
      sessionId: session.sessionId,
      content: "hello",
      agentId: "general_assistant",
      modelProvider: "ollama",
      model: "llama3.2"
    });

    const [listedSession] = sessions.listSessions();
    expect(listedSession).toHaveProperty("sessionId", session.sessionId);
    expect(listedSession).not.toHaveProperty("id");

    const messages = sessions.getMessages(session.sessionId);
    expect(messages).toHaveLength(2);
    expect(messages[0]).toHaveProperty("messageId", queued.userMessageId);
    expect(messages[0]).not.toHaveProperty("id");
    expect(messages[1]).toHaveProperty("messageId", queued.assistantMessageId);
    expect(messages[1]).not.toHaveProperty("id");
  });

  it("makes retried stale jobs claimable again", () => {
    const { db, sessions, jobs } = createTestServices({ jobTimeoutMs: 1000, maxAttempts: 3 });

    const session = sessions.createSession({ title: "Retry stale" });
    const queued = sessions.enqueueUserMessage({
      sessionId: session.sessionId,
      content: "hello",
      agentId: "general_assistant",
      modelProvider: "ollama",
      model: "llama3.2"
    });

    const firstClaim = jobs.claimNext("general_assistant");
    expect(firstClaim?.jobId).toBe(queued.jobId);
    expect(firstClaim?.attempt).toBe(1);

    const stalePickedUpAt = new Date(Date.now() - 60000).toISOString();
    db.prepare("UPDATE jobs SET picked_up_at = ? WHERE id = ?").run(stalePickedUpAt, queued.jobId);

    expect(jobs.reapStaleJobs()).toBe(1);
    const reapedJob = db.prepare("SELECT status, attempt, picked_up_at AS pickedUpAt FROM jobs WHERE id = ?").get(queued.jobId) as {
      status: string;
      attempt: number;
      pickedUpAt: string | null;
    };
    const reapedRun = db.prepare("SELECT status, started_at AS startedAt FROM agent_runs WHERE id = ?").get(queued.runId) as {
      status: string;
      startedAt: string | null;
    };
    expect(reapedJob).toEqual({ status: "pending", attempt: 2, pickedUpAt: null });
    expect(reapedRun).toEqual({ status: "queued", startedAt: null });

    const retried = jobs.claimNext("general_assistant");
    expect(retried?.jobId).toBe(queued.jobId);
    expect(retried?.attempt).toBe(2);

    const claimedJob = db.prepare("SELECT status, attempt, picked_up_at AS pickedUpAt FROM jobs WHERE id = ?").get(queued.jobId) as {
      status: string;
      attempt: number;
      pickedUpAt: string | null;
    };
    const claimedRun = db.prepare("SELECT status, started_at AS startedAt FROM agent_runs WHERE id = ?").get(queued.runId) as {
      status: string;
      startedAt: string | null;
    };
    expect(claimedJob.status).toBe("in_progress");
    expect(claimedJob.attempt).toBe(2);
    expect(claimedJob.pickedUpAt).not.toBeNull();
    expect(claimedRun.status).toBe("running");
    expect(claimedRun.startedAt).not.toBeNull();
  });
});
