import { loadRuntimeConfig } from "./config.js";
import { OrchestratorClient } from "./orchestrator/client.js";
import { runOneJob } from "./executor/jobLoop.js";
import { createGeneralAssistantExecutor } from "./agents/generalAssistant.js";
import { createLogger } from "./logging/logger.js";
import { OllamaProvider } from "./llm/ollama.js";
import { OpenAICompatibleProvider } from "./llm/openaiCompatible.js";
import type { LlmProvider } from "./llm/provider.js";
import type { ModelProviderId } from "@turing/shared-types";

const config = loadRuntimeConfig();
const logger = createLogger(config.logLevel);
const client = new OrchestratorClient(config.orchestratorInternalBaseUrl, config.internalToken);

const providers: Partial<Record<ModelProviderId, LlmProvider>> = {
  ollama: new OllamaProvider(config.ollamaBaseUrl),
  ...(config.openaiApiKey
    ? { openai_compatible: new OpenAICompatibleProvider(config.openaiBaseUrl, config.openaiApiKey) }
    : {})
};
const executor = createGeneralAssistantExecutor(providers);

while (true) {
  const job = await client.claimNext(config.agentId);
  if (job) {
    logger.info({ jobId: job.jobId, runId: job.runId }, "claimed job");
    await runOneJob(job, executor, client);
  } else {
    await new Promise((resolve) => setTimeout(resolve, 1000));
  }
}
