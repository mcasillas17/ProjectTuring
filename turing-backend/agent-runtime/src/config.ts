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

export function loadRuntimeConfig(env: NodeJS.ProcessEnv = process.env) {
  loadDotenv();
  const secrets = new EnvSecretsBackend(env);
  return {
    orchestratorInternalBaseUrl: secrets.get("ORCHESTRATOR_INTERNAL_BASE_URL") ?? "http://turing-orchestrator:3001/internal",
    internalToken: secrets.require("TURING_INTERNAL_TOKEN"),
    agentId: "general_assistant" as const,
    ollamaBaseUrl: secrets.get("OLLAMA_BASE_URL") ?? "http://host.docker.internal:11434",
    ollamaModel: secrets.get("OLLAMA_MODEL") ?? "llama3.2",
    openaiBaseUrl: secrets.get("OPENAI_BASE_URL") ?? "https://api.openai.com/v1",
    openaiApiKey: secrets.get("OPENAI_API_KEY"),
    openaiModel: secrets.get("OPENAI_MODEL") ?? "gpt-4o-mini",
    mcpSystemBaseUrl: secrets.get("MCP_SYSTEM_BASE_URL") ?? "http://turing-mcp-system:7100/mcp",
    mcpFilesBaseUrl: secrets.get("MCP_FILES_BASE_URL") ?? "http://turing-mcp-files:7110/mcp",
    mcpSystemToken: secrets.require("MCP_SYSTEM_TOKEN_GENERAL"),
    mcpFilesToken: secrets.require("MCP_FILES_TOKEN_GENERAL"),
    maxConcurrentRuns: Number.parseInt(secrets.get("TURING_MAX_CONCURRENT_RUNS_GENERAL") ?? "1", 10),
    maxToolCallsPerRun: Number.parseInt(secrets.get("TURING_MAX_TOOL_CALLS_PER_RUN") ?? "10", 10),
    modelTimeoutMs: Number.parseInt(secrets.get("TURING_MODEL_TIMEOUT_MS") ?? "120000", 10),
    toolTimeoutMs: Number.parseInt(secrets.get("TURING_TOOL_TIMEOUT_MS") ?? "30000", 10),
    logLevel: secrets.get("LOG_LEVEL") ?? "info"
  };
}

export type RuntimeConfig = ReturnType<typeof loadRuntimeConfig>;
