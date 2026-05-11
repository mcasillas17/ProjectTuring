import type { ModelProviderId, ToolCallBeacon, ToolPolicyDecision } from "@turing/shared-types";
import type { AgentExecutor } from "../executor/types.js";
import type { LlmProvider } from "../llm/provider.js";
import type { RuntimeApprovalState } from "../approvals/approvalPolling.js";
import { runAuthorizedMcpTool } from "../tools/toolRunner.js";

type McpToolClient = {
  callTool(name: string, args: Record<string, unknown>, approvalToken?: string): Promise<unknown>;
};

export type GeneralAssistantTools = {
  systemMcpClient: McpToolClient;
  filesMcpClient: McpToolClient;
  postBeacon: (beacon: ToolCallBeacon) => Promise<ToolPolicyDecision>;
  getApproval: (approvalId: string) => Promise<RuntimeApprovalState>;
};

export function createGeneralAssistantExecutor(
  providers: Partial<Record<ModelProviderId, LlmProvider>>,
  tools?: GeneralAssistantTools
): AgentExecutor {
  return {
    agentId: "general_assistant",
    async *execute(job, context) {
      const trimmed = job.payload.userText.trim();

      // Debug slash commands that exercise the MCP/approval pipeline end-to-end
      // without needing LLM function calling. Kept simple on purpose for v1.0.
      if (tools && trimmed === "/tool system.time") {
        try {
          const result = await runAuthorizedMcpTool({
            agentId: "general_assistant",
            runId: job.runId,
            traceId: job.traceId,
            serverName: "system",
            toolName: "system.time",
            args: {},
            mcpClient: tools.systemMcpClient,
            postBeacon: tools.postBeacon,
            getApproval: tools.getApproval
          });
          const content = JSON.stringify(result);
          yield {
            type: "event",
            event: { sessionId: job.sessionId, runId: job.runId, traceId: job.traceId, type: "message.delta", payload: { messageId: job.assistantMessageId, delta: content } }
          };
          yield { type: "complete", content };
        } catch (error) {
          yield { type: "fail", code: "tool_call_failed", message: error instanceof Error ? error.message : "Tool call failed", retryable: false };
        }
        return;
      }

      if (tools && trimmed === "/tool files.create") {
        const args = { path: "runtime-smoke.txt", content: "created through approval flow" };
        try {
          const result = await runAuthorizedMcpTool({
            agentId: "general_assistant",
            runId: job.runId,
            traceId: job.traceId,
            serverName: "files",
            toolName: "files.create",
            args,
            mcpClient: tools.filesMcpClient,
            postBeacon: tools.postBeacon,
            getApproval: tools.getApproval
          });
          const content = JSON.stringify(result);
          yield {
            type: "event",
            event: { sessionId: job.sessionId, runId: job.runId, traceId: job.traceId, type: "message.delta", payload: { messageId: job.assistantMessageId, delta: content } }
          };
          yield { type: "complete", content };
        } catch (error) {
          yield { type: "fail", code: "tool_call_failed", message: error instanceof Error ? error.message : "Tool call failed", retryable: false };
        }
        return;
      }

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
