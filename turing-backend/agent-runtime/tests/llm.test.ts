import { describe, expect, it, vi } from "vitest";
import { OllamaProvider } from "../src/llm/ollama.js";

describe("OllamaProvider", () => {
  it("converts Ollama streamed chunks into LlmStreamEvents", async () => {
    const fetchMock = vi.fn(async () => ({
      ok: true,
      body: ReadableStream.from([
        new TextEncoder().encode(JSON.stringify({ message: { content: "hi" }, done: false }) + "\n"),
        new TextEncoder().encode(JSON.stringify({ done: true, done_reason: "stop" }) + "\n")
      ])
    }));

    const provider = new OllamaProvider("http://ollama", fetchMock as unknown as typeof fetch);
    const events = [];
    for await (const event of provider.streamChat({ model: "llama3.2", messages: [{ role: "user", content: "hello" }] })) {
      events.push(event);
    }

    expect(events).toEqual([{ type: "delta", text: "hi" }, { type: "completed", finishReason: "stop" }]);
  });
});
