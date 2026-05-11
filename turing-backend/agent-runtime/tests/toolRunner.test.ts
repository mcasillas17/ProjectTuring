import { describe, expect, it, vi } from "vitest";
import { runAuthorizedMcpTool } from "../src/tools/toolRunner.js";

describe("runAuthorizedMcpTool", () => {
  it("posts before/after beacons around an allowed MCP call", async () => {
    const postBeacon = vi.fn(async (beacon) => ({ decision: "allow" as const, toolCallId: beacon.toolCallId }));
    const mcpClient = { callTool: vi.fn(async () => ({ iso: "now" })) };

    const result = await runAuthorizedMcpTool({
      agentId: "general_assistant",
      runId: "run_1",
      traceId: "trace_1",
      serverName: "system",
      toolName: "system.time",
      args: {},
      mcpClient,
      postBeacon,
      getApproval: async () => ({ approvalId: "appr_unused", status: "pending" as const })
    });

    expect(result).toEqual({ iso: "now" });
    expect(postBeacon).toHaveBeenCalledWith(expect.objectContaining({ phase: "before", toolName: "system.time" }));
    expect(postBeacon).toHaveBeenCalledWith(expect.objectContaining({ phase: "after", status: "completed" }));
  });
});
