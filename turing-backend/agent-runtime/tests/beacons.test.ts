import { describe, expect, it } from "vitest";
import { postToolBeacon } from "../src/audit/beacons.js";

describe("postToolBeacon", () => {
  it("fails closed when the orchestrator before-beacon request fails", async () => {
    const decision = await postToolBeacon(
      async () => {
        throw new Error("connect ECONNREFUSED");
      },
      { phase: "before", toolCallId: "call_1", agentId: "general_assistant", serverName: "system", toolName: "system.time", runId: "run_1", traceId: "trace_1" }
    );

    expect(decision).toEqual({ decision: "deny", toolCallId: "call_1", reason: "before_beacon_failed" });
  });
});
