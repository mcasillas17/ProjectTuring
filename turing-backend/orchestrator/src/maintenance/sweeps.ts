import type { TuringEvent } from "@turing/shared-types";
import type { OrchestratorConfig } from "../config.js";
import type { TuringDatabase } from "../db/connection.js";
import { createApprovalsService } from "../approvals/service.js";
import { createJobsService } from "../jobs/service.js";

type BroadcastHub = { broadcast(event: TuringEvent): void };

export function startSweeps(deps: { db: TuringDatabase; config: OrchestratorConfig; hub?: BroadcastHub }) {
  const approvals = createApprovalsService(deps.db, deps.config.approvalJwtSecret);
  const jobs = createJobsService(deps.db, { jobTimeoutMs: deps.config.jobTimeoutMs, maxAttempts: deps.config.jobMaxAttempts });
  const timer = setInterval(() => {
    jobs.reapStaleJobs();
    const expiredEvents = approvals.expirePendingApprovals();
    for (const event of expiredEvents) deps.hub?.broadcast(event);
  }, deps.config.jobReaperIntervalMs);

  timer.unref?.();
  return { stop: () => clearInterval(timer) };
}
