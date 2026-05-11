import type { AgentJob, ToolCallBeacon, ToolPolicyDecision, TuringEventInput } from "@turing/shared-types";
import type { RuntimeOrchestratorClient } from "../executor/jobLoop.js";
import type { RuntimeApprovalState } from "../approvals/approvalPolling.js";

type MessageRow = { role: "system" | "user" | "assistant" | "tool"; content: string };

export class OrchestratorClient implements RuntimeOrchestratorClient {
  constructor(private readonly baseUrl: string, private readonly token: string) {}

  private async request<T>(path: string, init: RequestInit = {}): Promise<T> {
    const response = await fetch(`${this.baseUrl}${path}`, {
      ...init,
      headers: {
        "content-type": "application/json",
        authorization: `Bearer ${this.token}`,
        ...init.headers
      }
    });
    if (!response.ok) throw new Error(`Orchestrator request failed: ${response.status} ${path}`);
    return response.status === 204 ? (undefined as T) : ((await response.json()) as T);
  }

  claimNext(agentId: "general_assistant"): Promise<AgentJob | undefined> {
    return this.request<AgentJob | undefined>(`/jobs/next?agent=${agentId}&waitMs=30000`);
  }

  async fetchMessages(sessionId: string): Promise<Array<{ role: "system" | "user" | "assistant"; content: string }>> {
    const result = await this.request<{ messages: MessageRow[] }>(`/sessions/${sessionId}/messages?limit=50`);
    // Orchestrator returns messages newest-first (ORDER BY sequence DESC). LLM
    // input must be chronological, so reverse here and drop "tool" rows that
    // the v1.0 chat protocol does not feed back to the model.
    return result.messages
      .filter((m): m is { role: "system" | "user" | "assistant"; content: string } => m.role !== "tool")
      .reverse();
  }

  async postEvent(runId: string, event: TuringEventInput): Promise<void> {
    await this.request(`/runs/${runId}/events`, { method: "POST", body: JSON.stringify({ event }) });
  }

  postToolBeacon(runId: string, beacon: ToolCallBeacon): Promise<ToolPolicyDecision> {
    return this.request<ToolPolicyDecision>(`/runs/${runId}/audit/tool-call`, { method: "POST", body: JSON.stringify(beacon) });
  }

  getApproval(approvalId: string): Promise<RuntimeApprovalState> {
    return this.request<RuntimeApprovalState>(`/approvals/${approvalId}`);
  }

  async completeRun(runId: string, assistantMessageId: string, content: string): Promise<void> {
    await this.request(`/runs/${runId}/complete`, { method: "POST", body: JSON.stringify({ assistantMessageId, content }) });
  }

  async failRun(runId: string, error: { code: string; message: string; retryable: boolean }): Promise<void> {
    await this.request(`/runs/${runId}/fail`, { method: "POST", body: JSON.stringify(error) });
  }
}
