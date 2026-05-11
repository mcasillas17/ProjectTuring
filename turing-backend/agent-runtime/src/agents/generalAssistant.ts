import type { ModelProviderId } from "@turing/shared-types";
import type { AgentExecutor } from "../executor/types.js";
import type { LlmProvider } from "../llm/provider.js";

export function createGeneralAssistantExecutor(providers: Partial<Record<ModelProviderId, LlmProvider>>): AgentExecutor {
  return {
    agentId: "general_assistant",
    async *execute(job, context) {
      const provider = providers[job.modelProvider];
      if (!provider) {
        yield { type: "fail", code: "model_provider_unavailable", message: `Provider ${job.modelProvider} is not configured`, retryable: false };
        return;
      }

      let content = "";
      yield {
        type: "event",
        event: { sessionId: job.sessionId, runId: job.runId, traceId: job.traceId, type: "message.started", payload: { messageId: job.assistantMessageId, role: "assistant" } }
      };

      for await (const event of provider.streamChat({ model: job.model, messages: context.messages.concat([{ role: "user", content: job.payload.userText }]) })) {
        if (event.type === "delta") {
          content += event.text;
          yield {
            type: "event",
            event: { sessionId: job.sessionId, runId: job.runId, traceId: job.traceId, type: "message.delta", payload: { messageId: job.assistantMessageId, delta: event.text } }
          };
        }
        if (event.type === "error") {
          yield { type: "fail", code: event.code, message: event.message, retryable: false };
          return;
        }
      }

      yield {
        type: "event",
        event: { sessionId: job.sessionId, runId: job.runId, traceId: job.traceId, type: "message.completed", payload: { messageId: job.assistantMessageId, content } }
      };
      yield { type: "complete", content };
    }
  };
}
