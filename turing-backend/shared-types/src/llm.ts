export type LlmUsage = {
  promptTokens?: number;
  completionTokens?: number;
  totalTokens?: number;
};

export type LlmChatRequest = {
  model: string;
  messages: Array<{ role: "system" | "user" | "assistant"; content: string }>;
  temperature?: number;
  maxTokens?: number;
  abortSignal?: AbortSignal;
};

export type LlmStreamEvent =
  | { type: "delta"; text: string }
  | { type: "completed"; finishReason?: string; usage?: LlmUsage }
  | { type: "error"; code: string; message: string };
