import type { ToolCallBeacon, ToolPolicyDecision } from "@turing/shared-types";

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
