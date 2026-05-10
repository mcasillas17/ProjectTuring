import { describe, expect, it } from "vitest";
import { loadConfigFromEnv } from "../src/config.js";

describe("loadConfigFromEnv", () => {
  it("requires client, internal, mcp, and approval secrets", () => {
    expect(() => loadConfigFromEnv({})).toThrow(/TURING_CLIENT_API_KEY/);
  });

  it("parses ports and defaults", () => {
    const config = loadConfigFromEnv({
      TURING_CLIENT_API_KEY: "tk_test",
      TURING_INTERNAL_TOKEN: "internal",
      MCP_SYSTEM_TOKEN_GENERAL: "system",
      MCP_FILES_TOKEN_GENERAL: "files",
      TURING_APPROVAL_JWT_SECRET: "approval",
      DATABASE_PATH: ":memory:"
    });

    expect(config.publicPort).toBe(3000);
    expect(config.internalPort).toBe(3001);
    expect(config.ollamaModel).toBe("llama3.2");
  });
});
