import Database from "better-sqlite3";
import { buildInternalServer, buildPublicServer } from "../src/server.js";
import type { OrchestratorConfig } from "../src/config.js";
import type { TuringDatabase } from "../src/db/connection.js";
import { applyMigrations } from "../src/db/migrations.js";
import { createSessionsService } from "../src/sessions/service.js";

export const testConfig: OrchestratorConfig = {
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

export async function buildInternalServerForTest() {
  const db = new Database(":memory:");
  applyMigrations(db);
  const app = await buildInternalServer({ db, config: testConfig });
  return Object.assign(app, { app, db });
}

export function seedQueuedJob(db: TuringDatabase) {
  const sessions = createSessionsService(db);
  const session = sessions.createSession({ title: "Internal" });
  return sessions.enqueueUserMessage({
    sessionId: session.sessionId,
    content: "hello",
    agentId: "general_assistant",
    modelProvider: "ollama",
    model: "llama3.2"
  });
}
