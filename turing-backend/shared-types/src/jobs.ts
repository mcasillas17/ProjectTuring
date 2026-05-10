export type AgentId = "general_assistant";
export type ModelProviderId = "ollama" | "openai_compatible";

export type AgentJob = {
  jobId: string;
  runId: string;
  sessionId: string;
  userMessageId: string;
  assistantMessageId: string;
  agentId: AgentId;
  traceId: string;
  modelProvider: ModelProviderId;
  model: string;
  payload: {
    userText: string;
    requestedTools?: string[];
  };
  attempt: number;
};

export type AgentExecutionUpdate =
  | { type: "event"; event: import("./events.js").TuringEventInput }
  | { type: "complete"; content: string; usage?: import("./llm.js").LlmUsage }
  | { type: "fail"; code: string; message: string; retryable: boolean };
