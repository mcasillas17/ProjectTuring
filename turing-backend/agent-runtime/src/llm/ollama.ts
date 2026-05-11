import type { LlmChatRequest, LlmStreamEvent } from "@turing/shared-types";
import type { LlmProvider } from "./provider.js";

export class OllamaProvider implements LlmProvider {
  readonly id = "ollama" as const;

  constructor(private readonly baseUrl: string, private readonly fetchImpl: typeof fetch = fetch) {}

  async *streamChat(request: LlmChatRequest): AsyncIterable<LlmStreamEvent> {
    const response = await this.fetchImpl(`${this.baseUrl}/api/chat`, {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ model: request.model, messages: request.messages, stream: true }),
      signal: request.abortSignal
    });

    if (!response.ok || !response.body) {
      yield { type: "error", code: "model_unavailable", message: `Ollama returned ${response.status}` };
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
        if (!line.trim()) continue;
        const chunk = JSON.parse(line);
        if (chunk.message?.content) yield { type: "delta", text: chunk.message.content };
        if (chunk.done) yield { type: "completed", finishReason: chunk.done_reason };
      }
    }
  }
}
