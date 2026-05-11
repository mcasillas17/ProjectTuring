import { describe, expect, it } from "vitest";
import { getToolPolicy } from "../src/tools/policy.js";

describe("tool policy", () => {
  it("classifies safe, approval-required, and disabled tools", () => {
    expect(getToolPolicy("system.time")).toBe("safe");
    expect(getToolPolicy("files.update")).toBe("approval_required");
    expect(getToolPolicy("files.delete")).toBe("disabled");
  });
});
