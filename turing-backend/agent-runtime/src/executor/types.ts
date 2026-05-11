import type { AgentExecutionUpdate, AgentJob } from "@turing/shared-types";

export type AgentExecutionContext = {
  messages: Array<{ role: "system" | "user" | "assistant"; content: string }>;
};

export interface AgentExecutor {
  readonly agentId: "general_assistant";
  execute(job: AgentJob, context: AgentExecutionContext): AsyncIterable<AgentExecutionUpdate>;
}
