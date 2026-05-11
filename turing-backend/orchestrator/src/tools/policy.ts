import type { ToolPolicy } from "@turing/shared-types";

const POLICIES = new Map<string, ToolPolicy>([
  ["system.health", "safe"],
  ["system.time", "safe"],
  ["system.echo", "safe"],
  ["system.info", "safe"],
  ["files.list", "safe"],
  ["files.search", "safe"],
  ["files.read", "safe"],
  ["files.create", "approval_required"],
  ["files.update", "approval_required"],
  ["files.delete", "disabled"],
  ["files.move", "disabled"]
]);

export function getToolPolicy(toolName: string): ToolPolicy | undefined {
  return POLICIES.get(toolName);
}
