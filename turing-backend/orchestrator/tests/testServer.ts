import Database from "better-sqlite3";
import { buildPublicServer } from "../src/server.js";
import { applyMigrations } from "../src/db/migrations.js";

export const testConfig = {
  clientApiKey: "tk_test",
  internalToken: "internal",
  mcpSystemTokenGeneral: "system",
  mcpFilesTokenGeneral: "files",
  approvalJwtSecret: "approval",
  publicPort: 3000,
  internalPort: 3001,
  databasePath: ":memory:",
  ollamaBaseUrl: "http://ollama",
  ollamaModel: "llama3.2",
  openaiBaseUrl: "https://api.openai.com/v1",
  openaiModel: "gpt-4o-mini",
  jobTimeoutMs: 300000,
  jobReaperIntervalMs: 60000,
  jobMaxAttempts: 3,
  maxConcurrentRunsGeneral: 1,
  maxToolCallsPerRun: 10,
  modelTimeoutMs: 120000,
  toolTimeoutMs: 30000,
  logLevel: "silent"
};

export async function buildPublicServerForTest() {
  const db = new Database(":memory:");
  applyMigrations(db);
  return buildPublicServer({
    db,
    config: testConfig
  });
}
