import type { LlmChatRequest, LlmStreamEvent } from "@turing/shared-types";
import type { LlmProvider } from "./provider.js";

export class OpenAICompatibleProvider implements LlmProvider {
  readonly id = "openai_compatible" as const;

  constructor(private readonly baseUrl: string, private readonly apiKey: string, private readonly fetchImpl: typeof fetch = fetch) {}

  async *streamChat(request: LlmChatRequest): AsyncIterable<LlmStreamEvent> {
    const response = await this.fetchImpl(`${this.baseUrl}/chat/completions`, {
      method: "POST",
      headers: {
        "content-type": "application/json",
        authorization: `Bearer ${this.apiKey}`
      },
      body: JSON.stringify({ model: request.model, messages: request.messages, stream: true }),
      signal: request.abortSignal
    });

    if (!response.ok || !response.body) {
      yield { type: "error", code: "model_unavailable", message: `OpenAI-compatible provider returned ${response.status}` };
      return;
    }

    const reader = response.body.getReader();
    const decoder = new TextDecoder();
    let buffer = "";
    while (true) {
      const { done, value } = await reader.read();
      if (done) break;
      buffer += decoder.decode(value, { stream: true });
      const lines = buffer.split("\n");
      buffer = lines.pop() ?? "";
      for (const line of lines) {
        const trimmed = line.trim();
        if (!trimmed.startsWith("data:")) continue;
        const data = trimmed.slice("data:".length).trim();
        if (data === "[DONE]") {
          yield { type: "completed", finishReason: "stop" };
          continue;
        }
        const chunk = JSON.parse(data);
        const text = chunk.choices?.[0]?.delta?.content;
        if (text) yield { type: "delta", text };
      }
    }
  }
}
