import Fastify from "fastify";
import { describe, expect, it } from "vitest";
import { createLogger } from "../src/logging/logger.js";

describe("logger", () => {
  it("redacts auth headers and websocket token query parameters from request logs", async () => {
    const chunks: string[] = [];
    const app = Fastify({
      loggerInstance: createLogger("info", {
        write(chunk: string) {
          chunks.push(chunk);
        }
      })
    });
    app.get("/ws", async () => ({ ok: true }));

    try {
      for (const url of ["/ws?to%6ben=tk_secret&last=1", "/ws?%54oken=tk_secret_upper&last=1"]) {
        await app.inject({
          method: "GET",
          url,
          headers: { authorization: "Bearer auth_secret" }
        });
      }
    } finally {
      await app.close();
    }

    const logs = chunks.join("");
    expect(logs).not.toContain("tk_secret");
    expect(logs).not.toContain("tk_secret_upper");
    expect(logs).not.toContain("auth_secret");
    expect(logs).toContain("token");
    expect(logs).toContain("[redacted]");
  });
});
