import fs from "node:fs";
import { describe, expect, it } from "vitest";

describe("orchestrator Dockerfile", () => {
  it("copies shared-types package metadata for workspace runtime resolution", () => {
    const dockerfile = fs.readFileSync(new URL("../Dockerfile", import.meta.url), "utf8");

    expect(dockerfile).toContain("COPY --from=builder /repo/shared-types/package.json /app/shared-types/package.json");
    expect(dockerfile).toContain("COPY --from=builder /repo/shared-types/dist /app/shared-types/dist");
  });
});
