import { describe, expect, it, vi } from "vitest";
import { McpClient } from "../src/mcp/client.js";

describe("McpClient", () => {
  it("sends bearer-authenticated tools/call JSON-RPC requests", async () => {
    const fetchMock = vi.fn(async () => ({
      ok: true,
      json: async () => ({ jsonrpc: "2.0", id: 1, result: { iso: "now" } })
    }));
    const client = new McpClient("http://mcp:7100/mcp", "token", fetchMock as unknown as typeof fetch);
    const result = await client.callTool("system.time", {});

    expect(result).toEqual({ iso: "now" });
    expect(fetchMock).toHaveBeenCalledWith(
      "http://mcp:7100/mcp",
      expect.objectContaining({ headers: expect.objectContaining({ authorization: "Bearer token" }) })
    );
  });

  it("surfaces MCP HTTP 401 instead of treating it as a tool result", async () => {
    const fetchMock = vi.fn(async () => ({
      ok: false,
      status: 401,
      text: async () => "unauthorized"
    }));
    const client = new McpClient("http://mcp:7110/mcp", "bad-token", fetchMock as unknown as typeof fetch);

    await expect(client.callTool("files.read", { path: "note.txt" })).rejects.toThrow("MCP HTTP 401");
  });
});
