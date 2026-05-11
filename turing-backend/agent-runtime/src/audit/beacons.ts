import type { ToolCallBeacon, ToolPolicyDecision } from "@turing/shared-types";
import { waitForApprovalToken, type RuntimeApprovalState } from "../approvals/approvalPolling.js";

export async function postToolBeacon(
  post: (beacon: ToolCallBeacon) => Promise<ToolPolicyDecision>,
  beacon: ToolCallBeacon
): Promise<ToolPolicyDecision> {
  try {
    return await post(beacon);
  } catch (error) {
    if (beacon.phase === "before") {
      return { decision: "deny", toolCallId: beacon.toolCallId, reason: "before_beacon_failed" };
    }
    throw error;
  }
}

export async function authorizeToolCall(
  post: (beacon: ToolCallBeacon) => Promise<ToolPolicyDecision>,
  getApproval: (approvalId: string) => Promise<RuntimeApprovalState>,
  beacon: ToolCallBeacon
): Promise<{ approvalToken?: string }> {
  const decision = await postToolBeacon(post, beacon);
  if (decision.decision === "allow") return {};
  if (decision.decision === "deny") throw new Error(`Tool denied: ${decision.reason}`);
  const approvalToken = await waitForApprovalToken(decision.approvalId, getApproval);
  return { approvalToken };
}
