import { describe, expect, it } from "vitest";
import { waitForApprovalToken } from "../src/approvals/approvalPolling.js";

describe("waitForApprovalToken", () => {
  it("returns the stored approval token once the user approves", async () => {
    const states = [
      { approvalId: "appr_1", status: "pending" as const },
      { approvalId: "appr_1", status: "approved" as const, approvalToken: "jwt-token" }
    ];

    const token = await waitForApprovalToken("appr_1", async () => states.shift()!, { pollMs: 1, timeoutMs: 100 });

    expect(token).toBe("jwt-token");
  });

  it("fails when the approval is denied or expires", async () => {
    await expect(
      waitForApprovalToken("appr_1", async () => ({ approvalId: "appr_1", status: "expired" }), { pollMs: 1, timeoutMs: 100 })
    ).rejects.toThrow("Approval expired");
  });
});
