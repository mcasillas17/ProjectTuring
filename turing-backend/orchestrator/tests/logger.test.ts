import Fastify from "fastify";
import { describe, expect, it } from "vitest";
import { createLogger } from "../src/logging/logger.js";

describe("logger", () => {
  it("redacts websocket token query parameters from request logs", async () => {
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
      await app.inject({ method: "GET", url: "/ws?token=tk_secret&last=1" });
    } finally {
      await app.close();
    }

    const logs = chunks.join("");
    expect(logs).not.toContain("tk_secret");
    expect(logs).toContain("/ws?token=[redacted]&last=1");
  });
});
