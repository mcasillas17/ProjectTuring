import { ulid } from "ulid";
import type { ToolCallBeacon, ToolPolicyDecision } from "@turing/shared-types";

type McpToolClient = {
  callTool(name: string, args: Record<string, unknown>, approvalToken?: string): Promise<unknown>;
};

export async function runAuthorizedMcpTool(input: {
  agentId: "general_assistant";
  runId: string;
  traceId: string;
  serverName: "system" | "files";
  toolName: string;
  args: Record<string, unknown>;
  mcpClient: McpToolClient;
  postBeacon: (beacon: ToolCallBeacon) => Promise<ToolPolicyDecision>;
}): Promise<unknown> {
  const toolCallId = `call_${ulid()}`;
  const before = await input.postBeacon({
    phase: "before",
    toolCallId,
    agentId: input.agentId,
    serverName: input.serverName,
    toolName: input.toolName,
    args: input.args,
    runId: input.runId,
    traceId: input.traceId
  });
  if (before.decision !== "allow") {
    throw new Error(before.decision === "deny" ? before.reason : "approval_required");
  }

  try {
    const result = await input.mcpClient.callTool(input.toolName, input.args);
    await input.postBeacon({
      phase: "after",
      toolCallId,
      agentId: input.agentId,
      serverName: input.serverName,
      toolName: input.toolName,
      args: input.args,
      status: "completed",
      resultSummary: JSON.stringify(result).slice(0, 500),
      runId: input.runId,
      traceId: input.traceId
    });
    return result;
  } catch (error) {
    await input.postBeacon({
      phase: "after",
      toolCallId,
      agentId: input.agentId,
      serverName: input.serverName,
      toolName: input.toolName,
      args: input.args,
      status: "failed",
      error: { code: "mcp_call_failed", message: error instanceof Error ? error.message : "MCP call failed" },
      runId: input.runId,
      traceId: input.traceId
    });
    throw error;
  }
}
