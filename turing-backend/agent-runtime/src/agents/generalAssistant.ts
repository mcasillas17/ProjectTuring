import type { AgentExecutor } from "../executor/types.js";

export function createGeneralAssistantExecutor(): AgentExecutor {
  return {
    agentId: "general_assistant",
    async *execute(job) {
      yield {
        type: "event",
        event: {
          sessionId: job.sessionId,
          runId: job.runId,
          traceId: job.traceId,
          type: "message.delta",
          payload: { messageId: job.assistantMessageId, delta: "Runtime connected. Model streaming arrives in the next task." }
        }
      };
      yield { type: "complete", content: "Runtime connected. Model streaming arrives in the next task." };
    }
  };
}
