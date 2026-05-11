import fs from "node:fs";
import { describe, expect, it } from "vitest";

describe("orchestrator Dockerfile", () => {
  it("copies shared-types package metadata for workspace runtime resolution", () => {
    const dockerfile = fs.readFileSync(new URL("../Dockerfile", import.meta.url), "utf8");

    expect(dockerfile).toContain("COPY --from=builder /repo/shared-types/package.json /app/shared-types/package.json");
    expect(dockerfile).toContain("COPY --from=builder /repo/shared-types/dist /app/shared-types/dist");
  });
});

describe("Docker Compose stack", () => {
  it("starts the integrated runtime and MCP services by default", () => {
    const compose = fs.readFileSync(new URL("../../infra/docker-compose.yml", import.meta.url), "utf8");

    for (const service of ["turing-agent-runtime-general", "turing-mcp-system", "turing-mcp-files"]) {
      const serviceBlock = compose.match(new RegExp(`  ${service}:[\\s\\S]*?(?=\\n  [a-zA-Z0-9_-]+:|\\nnetworks:)`))?.[0] ?? "";
      expect(serviceBlock).not.toContain("profiles:");
      expect(serviceBlock).not.toContain("future-runtime");
    }

    expect(compose).toContain("TURING_INTERNAL_TOKEN: ${TURING_INTERNAL_TOKEN}");
    expect(compose).toContain("ORCHESTRATOR_INTERNAL_BASE_URL: ${ORCHESTRATOR_INTERNAL_BASE_URL:-http://turing-orchestrator:3001/internal}");
  });
});
