import { config as loadDotenv } from "dotenv";

export type SecretsBackend = {
  get(name: string): string | undefined;
  require(name: string): string;
};

export class EnvSecretsBackend implements SecretsBackend {
  constructor(private readonly env: NodeJS.ProcessEnv = process.env) {}

  get(name: string): string | undefined {
    const value = this.env[name];
    return value && value.length > 0 ? value : undefined;
  }

  require(name: string): string {
    const value = this.get(name);
    if (!value) throw new Error(`Missing required env var ${name}`);
    return value;
  }
}

export type OrchestratorConfig = {
  clientApiKey: string;
  internalToken: string;
  mcpSystemTokenGeneral: string;
  mcpFilesTokenGeneral: string;
  approvalJwtSecret: string;
  publicPort: number;
  internalPort: number;
  databasePath: string;
  ollamaBaseUrl: string;
  ollamaModel: string;
  openaiBaseUrl: string;
  openaiApiKey?: string;
  openaiModel: string;
  jobTimeoutMs: number;
  jobReaperIntervalMs: number;
  jobMaxAttempts: number;
  maxConcurrentRunsGeneral: number;
  maxToolCallsPerRun: number;
  modelTimeoutMs: number;
  toolTimeoutMs: number;
  logLevel: string;
};

function intFromEnv(env: NodeJS.ProcessEnv, name: string, fallback: number): number {
  const raw = env[name];
  if (!raw) return fallback;
  const parsed = Number.parseInt(raw, 10);
  if (!Number.isFinite(parsed)) throw new Error(`Invalid integer env var ${name}`);
  return parsed;
}

export function loadConfigFromEnv(env: NodeJS.ProcessEnv = process.env): OrchestratorConfig {
  const secrets = new EnvSecretsBackend(env);
  return {
    clientApiKey: secrets.require("TURING_CLIENT_API_KEY"),
    internalToken: secrets.require("TURING_INTERNAL_TOKEN"),
    mcpSystemTokenGeneral: secrets.require("MCP_SYSTEM_TOKEN_GENERAL"),
    mcpFilesTokenGeneral: secrets.require("MCP_FILES_TOKEN_GENERAL"),
    approvalJwtSecret: secrets.require("TURING_APPROVAL_JWT_SECRET"),
    publicPort: intFromEnv(env, "ORCHESTRATOR_PUBLIC_PORT", 3000),
    internalPort: intFromEnv(env, "ORCHESTRATOR_INTERNAL_PORT", 3001),
    databasePath: env.DATABASE_PATH ?? "/app/data/turing.db",
    ollamaBaseUrl: env.OLLAMA_BASE_URL ?? "http://host.docker.internal:11434",
    ollamaModel: env.OLLAMA_MODEL ?? "llama3.2",
    openaiBaseUrl: env.OPENAI_BASE_URL ?? "https://api.openai.com/v1",
    openaiApiKey: secrets.get("OPENAI_API_KEY"),
    openaiModel: env.OPENAI_MODEL ?? "gpt-4o-mini",
    jobTimeoutMs: intFromEnv(env, "TURING_JOB_TIMEOUT_MS", 300000),
    jobReaperIntervalMs: intFromEnv(env, "TURING_JOB_REAPER_INTERVAL_MS", 60000),
    jobMaxAttempts: intFromEnv(env, "TURING_JOB_MAX_ATTEMPTS", 3),
    maxConcurrentRunsGeneral: intFromEnv(env, "TURING_MAX_CONCURRENT_RUNS_GENERAL", 1),
    maxToolCallsPerRun: intFromEnv(env, "TURING_MAX_TOOL_CALLS_PER_RUN", 10),
    modelTimeoutMs: intFromEnv(env, "TURING_MODEL_TIMEOUT_MS", 120000),
    toolTimeoutMs: intFromEnv(env, "TURING_TOOL_TIMEOUT_MS", 30000),
    logLevel: env.LOG_LEVEL ?? "info"
  };
}

export function loadConfig(): OrchestratorConfig {
  loadDotenv();
  return loadConfigFromEnv();
}
