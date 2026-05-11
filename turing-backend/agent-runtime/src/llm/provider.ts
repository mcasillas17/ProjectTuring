import type { LlmChatRequest, LlmStreamEvent } from "@turing/shared-types";

export interface LlmProvider {
  readonly id: "ollama" | "openai_compatible";
  streamChat(request: LlmChatRequest): AsyncIterable<LlmStreamEvent>;
}
