import fs from "node:fs";
import { describe, expect, it } from "vitest";

describe("orchestrator Dockerfile", () => {
  it("copies shared-types package metadata for workspace runtime resolution", () => {
    const dockerfile = fs.readFileSync(new URL("../Dockerfile", import.meta.url), "utf8");

    expect(dockerfile).toContain("COPY --from=builder /repo/shared-types/package.json /app/shared-types/package.json");
    expect(dockerfile).toContain("COPY --from=builder /repo/shared-types/dist /app/shared-types/dist");
  });
});

describe("Docker Compose skeleton", () => {
  it("profile-gates future service build contexts that are not part of Tasks 1-7", () => {
    const compose = fs.readFileSync(new URL("../../infra/docker-compose.yml", import.meta.url), "utf8");

    for (const service of ["turing-agent-runtime-general", "turing-mcp-system", "turing-mcp-files"]) {
      const serviceBlock = compose.match(new RegExp(`  ${service}:[\\s\\S]*?(?=\\n  [a-zA-Z0-9_-]+:|\\nnetworks:)`))?.[0] ?? "";
      expect(serviceBlock).toContain("profiles:");
      expect(serviceBlock).toContain("future-runtime");
    }
  });
});
