import { describe, expect, it } from "vitest";
import { loadConfigFromEnv } from "../src/config.js";

describe("loadConfigFromEnv", () => {
  const requiredEnv = {
    TURING_CLIENT_API_KEY: "tk_test",
    TURING_INTERNAL_TOKEN: "internal",
    MCP_SYSTEM_TOKEN_GENERAL: "system",
    MCP_FILES_TOKEN_GENERAL: "files",
    TURING_APPROVAL_JWT_SECRET: "approval"
  };

  it("requires client, internal, mcp, and approval secrets", () => {
    expect(() => loadConfigFromEnv({})).toThrow(/TURING_CLIENT_API_KEY/);
  });

  it("parses ports and defaults", () => {
    const config = loadConfigFromEnv({
      ...requiredEnv,
      DATABASE_PATH: ":memory:"
    });

    expect(config.publicPort).toBe(3000);
    expect(config.internalPort).toBe(3001);
    expect(config.ollamaModel).toBe("llama3.2");
  });

  it.each(["3000abc", "3000.5"])("rejects malformed integer value %s", (publicPort) => {
    expect(() =>
      loadConfigFromEnv({
        ...requiredEnv,
        ORCHESTRATOR_PUBLIC_PORT: publicPort
      })
    ).toThrow(/ORCHESTRATOR_PUBLIC_PORT/);
  });
});
