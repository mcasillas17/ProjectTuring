import type { AgentId, AgentJob, ModelProviderId } from "@turing/shared-types";
import type { TuringDatabase } from "../db/connection.js";
import { parseJson } from "../db/repositories.js";

type JobRow = {
  id: string;
  run_id: string;
  agent_id: AgentId;
  status: "pending" | "in_progress" | "completed" | "failed" | "cancelled";
  attempt: number;
  payload_json: string;
};

type QueuedJobPayload = {
  userText: string;
  sessionId: string;
  userMessageId: string;
  assistantMessageId: string;
  traceId: string;
  modelProvider: ModelProviderId;
  model: string;
};

type StaleJobRow = { id: string; run_id: string; attempt: number };

class JobClaimConflictError extends Error {}

function toAgentJob(row: JobRow, agentId: AgentId): AgentJob {
  const payload = parseJson<QueuedJobPayload>(row.payload_json);
  return {
    jobId: row.id,
    runId: row.run_id,
    sessionId: payload.sessionId,
    userMessageId: payload.userMessageId,
    assistantMessageId: payload.assistantMessageId,
    agentId,
    traceId: payload.traceId,
    modelProvider: payload.modelProvider,
    model: payload.model,
    payload: { userText: payload.userText },
    attempt: row.attempt
  };
}

export function createJobsService(db: TuringDatabase, config: { jobTimeoutMs: number; maxAttempts: number }) {
  return {
    claimNext(agentId: AgentId): AgentJob | undefined {
      const claim = db.transaction((): AgentJob | undefined => {
        const row = db
          .prepare(
            "SELECT jobs.* FROM jobs JOIN agent_runs ON agent_runs.id = jobs.run_id WHERE jobs.agent_id = ? AND jobs.status = 'pending' AND agent_runs.status = 'queued' ORDER BY jobs.created_at LIMIT 1"
          )
          .get(agentId) as JobRow | undefined;
        if (!row) return undefined;

        const pickedUpAt = new Date().toISOString();
        const updatedJob = db.prepare("UPDATE jobs SET status = 'in_progress', picked_up_at = ? WHERE id = ? AND status = 'pending'").run(pickedUpAt, row.id);
        if (updatedJob.changes !== 1) return undefined;

        const updatedRun = db.prepare("UPDATE agent_runs SET status = 'running', started_at = ? WHERE id = ? AND status = 'queued'").run(pickedUpAt, row.run_id);
        if (updatedRun.changes !== 1) throw new JobClaimConflictError("Run was not claimable");

        return toAgentJob(row, agentId);
      });

      try {
        return claim();
      } catch (error) {
        if (error instanceof JobClaimConflictError) return undefined;
        throw error;
      }
    },

    reapStaleJobs(): number {
      const cutoff = new Date(Date.now() - config.jobTimeoutMs).toISOString();
      const stale = db
        .prepare("SELECT id, run_id, attempt FROM jobs WHERE status = 'in_progress' AND picked_up_at < ?")
        .all(cutoff) as StaleJobRow[];
      let count = 0;
      const tx = db.transaction(() => {
        for (const job of stale) {
          if (job.attempt >= config.maxAttempts) {
            const failedAt = new Date().toISOString();
            db.prepare("UPDATE jobs SET status = 'failed', finished_at = ?, error_code = 'job_timeout', error_message = 'Job timed out' WHERE id = ?").run(
              failedAt,
              job.id
            );
            db.prepare("UPDATE agent_runs SET status = 'failed', error_code = 'job_timeout', error_message = 'Job timed out', finished_at = ? WHERE id = ?").run(
              failedAt,
              job.run_id
            );
          } else {
            db.prepare("UPDATE jobs SET status = 'pending', attempt = attempt + 1, picked_up_at = NULL WHERE id = ?").run(job.id);
            db.prepare("UPDATE agent_runs SET status = 'queued', started_at = NULL WHERE id = ?").run(job.run_id);
          }
          count += 1;
        }
      });
      tx();
      return count;
    },

    completeRun(runId: string, assistantMessageId: string, content: string): void {
      const finishedAt = new Date().toISOString();
      const tx = db.transaction(() => {
        db.prepare("UPDATE messages SET content = ? WHERE id = ?").run(content, assistantMessageId);
        db.prepare("UPDATE agent_runs SET status = 'completed', finished_at = ? WHERE id = ?").run(finishedAt, runId);
        db.prepare("UPDATE jobs SET status = 'completed', finished_at = ? WHERE run_id = ?").run(finishedAt, runId);
      });
      tx();
    },

    failRun(runId: string, code: string, message: string): void {
      const finishedAt = new Date().toISOString();
      const tx = db.transaction(() => {
        db.prepare("UPDATE agent_runs SET status = 'failed', error_code = ?, error_message = ?, finished_at = ? WHERE id = ?").run(code, message, finishedAt, runId);
        db.prepare("UPDATE jobs SET status = 'failed', error_code = ?, error_message = ?, finished_at = ? WHERE run_id = ?").run(code, message, finishedAt, runId);
      });
      tx();
    }
  };
}
