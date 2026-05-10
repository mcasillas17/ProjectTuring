import Database from "better-sqlite3";
import { describe, expect, it } from "vitest";
import { applyMigrations } from "../src/db/migrations.js";
import { createSessionsService } from "../src/sessions/service.js";
import { createJobsService } from "../src/jobs/service.js";

describe("sessions and jobs services", () => {
  it("creates a session, message, run, and claimable job", () => {
    const db = new Database(":memory:");
    applyMigrations(db);

    const sessions = createSessionsService(db);
    const jobs = createJobsService(db, { jobTimeoutMs: 300000, maxAttempts: 3 });

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
    const db = new Database(":memory:");
    applyMigrations(db);

    const sessions = createSessionsService(db);
    const jobs = createJobsService(db, { jobTimeoutMs: 300000, maxAttempts: 3 });

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
});
