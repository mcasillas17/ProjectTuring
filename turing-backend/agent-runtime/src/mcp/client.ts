export class McpClient {
  private nextId = 1;

  constructor(private readonly endpoint: string, private readonly token: string, private readonly fetchImpl: typeof fetch = fetch) {}

  async listTools(): Promise<unknown[]> {
    const result = await this.request("tools/list", {});
    return (result as { tools?: unknown[] }).tools ?? [];
  }

  async callTool(name: string, args: Record<string, unknown>, approvalToken?: string): Promise<unknown> {
    return this.request("tools/call", {
      name,
      arguments: args,
      ...(approvalToken ? { _meta: { approvalToken } } : {})
    });
  }

  private async request(method: string, params: Record<string, unknown>): Promise<unknown> {
    const response = await this.fetchImpl(this.endpoint, {
      method: "POST",
      headers: { "content-type": "application/json", authorization: `Bearer ${this.token}` },
      body: JSON.stringify({ jsonrpc: "2.0", id: this.nextId++, method, params })
    });
    if (!response.ok) throw new Error(`MCP HTTP ${response.status}`);
    const payload = await response.json();
    if (payload.error) throw new Error(String(payload.error.message ?? "MCP error"));
    return payload.result;
  }
}
