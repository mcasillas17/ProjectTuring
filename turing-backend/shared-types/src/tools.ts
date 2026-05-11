export type ToolPolicy = "safe" | "approval_required" | "disabled";

export type ToolCallBeacon = {
  phase: "before" | "after";
  toolCallId: string;
  agentId: "general_assistant";
  serverName: "system" | "files";
  toolName: string;
  args?: Record<string, unknown>;
  status?: "completed" | "failed" | "denied";
  resultSummary?: string;
  durationMs?: number;
  error?: { code: string; message: string } | null;
  runId: string;
  traceId: string;
  createdAt?: string;
};

export type ToolPolicyDecision =
  | { decision: "allow"; toolCallId: string }
  | { decision: "deny"; toolCallId: string; reason: string }
  | { decision: "approval_required"; toolCallId: string; approvalId: string };
