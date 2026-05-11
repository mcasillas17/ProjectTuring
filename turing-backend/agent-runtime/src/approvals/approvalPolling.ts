export type RuntimeApprovalState = {
  approvalId: string;
  status: "pending" | "approved" | "denied" | "expired" | "consumed";
  approvalToken?: string;
};

export async function waitForApprovalToken(
  approvalId: string,
  loadApproval: (approvalId: string) => Promise<RuntimeApprovalState>,
  options: { pollMs: number; timeoutMs: number } = { pollMs: 1000, timeoutMs: 65_000 }
): Promise<string> {
  const deadline = Date.now() + options.timeoutMs;
  while (Date.now() < deadline) {
    const approval = await loadApproval(approvalId);
    if (approval.status === "approved" && approval.approvalToken) return approval.approvalToken;
    if (approval.status === "denied") throw new Error("Approval denied");
    if (approval.status === "expired") throw new Error("Approval expired");
    if (approval.status === "consumed") throw new Error("Approval already consumed");
    await new Promise((resolve) => setTimeout(resolve, options.pollMs));
  }
  throw new Error("Approval timed out");
}
