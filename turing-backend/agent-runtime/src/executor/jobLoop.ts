import type { AgentJob, TuringEventInput } from "@turing/shared-types";
import type { AgentExecutor } from "./types.js";

export type RuntimeOrchestratorClient = {
  fetchMessages(sessionId: string): Promise<Array<{ role: "system" | "user" | "assistant"; content: string }>>;
  postEvent(runId: string, event: TuringEventInput): Promise<void>;
  completeRun(runId: string, assistantMessageId: string, content: string): Promise<void>;
  failRun(runId: string, error: { code: string; message: string; retryable: boolean }): Promise<void>;
};

export async function runOneJob(job: AgentJob, executor: AgentExecutor, client: RuntimeOrchestratorClient): Promise<void> {
  try {
    const messages = await client.fetchMessages(job.sessionId);
    for await (const update of executor.execute(job, { messages })) {
      if (update.type === "event") await client.postEvent(job.runId, update.event);
      if (update.type === "complete") await client.completeRun(job.runId, job.assistantMessageId, update.content);
      if (update.type === "fail") await client.failRun(job.runId, { code: update.code, message: update.message, retryable: update.retryable });
    }
  } catch (error) {
    await client.failRun(job.runId, {
      code: "runtime_error",
      message: error instanceof Error ? error.message : "Unknown runtime error",
      retryable: false
    });
  }
}
