import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";

const testEnv = {
  TURING_CLIENT_API_KEY: "tk_test",
  TURING_INTERNAL_TOKEN: "internal",
  MCP_SYSTEM_TOKEN_GENERAL: "system",
  MCP_FILES_TOKEN_GENERAL: "files",
  TURING_APPROVAL_JWT_SECRET: "approval",
  ORCHESTRATOR_PUBLIC_PORT: "3000",
  ORCHESTRATOR_INTERNAL_PORT: "3001",
  TURING_JOB_TIMEOUT_MS: "300000",
  TURING_JOB_REAPER_INTERVAL_MS: "60000",
  TURING_JOB_MAX_ATTEMPTS: "3",
  TURING_MAX_CONCURRENT_RUNS_GENERAL: "1",
  TURING_MAX_TOOL_CALLS_PER_RUN: "10",
  TURING_MODEL_TIMEOUT_MS: "120000",
  TURING_TOOL_TIMEOUT_MS: "30000",
  DATABASE_PATH: ":memory:",
  LOG_LEVEL: "silent"
};

const envKeys = Object.keys(testEnv);
let previousEnv: Record<string, string | undefined>;

describe("buildPublicServer", () => {
  beforeEach(() => {
    vi.resetModules();
    previousEnv = Object.fromEntries(envKeys.map((key) => [key, process.env[key]]));
    Object.assign(process.env, testEnv);
  });

  afterEach(() => {
    for (const key of envKeys) {
      const value = previousEnv[key];
      if (value === undefined) delete process.env[key];
      else process.env[key] = value;
    }
    vi.resetModules();
  });

  it("can be created and respond to health checks", async () => {
    const { buildPublicServer } = await import("../src/server.js");
    const app = await buildPublicServer();

    try {
      const response = await app.inject({ method: "GET", url: "/health" });

      expect(response.statusCode).toBe(200);
      expect(response.json()).toEqual({ ok: true });
    } finally {
      await app.close();
    }
  });
});
