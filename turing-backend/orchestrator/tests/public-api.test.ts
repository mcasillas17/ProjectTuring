import { describe, expect, it } from "vitest";
import { buildPublicServerForTest } from "./testServer.js";

describe("public REST API", () => {
  it("rejects missing API keys", async () => {
    const app = await buildPublicServerForTest();
    const response = await app.inject({ method: "GET", url: "/api/sessions" });
    expect(response.statusCode).toBe(401);
  });

  it("creates a session and queues a message", async () => {
    const app = await buildPublicServerForTest();
    const auth = { authorization: "Bearer tk_test" };

    const sessionResponse = await app.inject({ method: "POST", url: "/api/sessions", headers: auth, payload: { title: "Test" } });
    expect(sessionResponse.statusCode).toBe(201);
    const session = sessionResponse.json() as { sessionId: string };

    const messageResponse = await app.inject({
      method: "POST",
      url: `/api/sessions/${session.sessionId}/messages`,
      headers: auth,
      payload: { content: "hello", modelProvider: "ollama" }
    });

    expect(messageResponse.statusCode).toBe(202);
    expect(messageResponse.json()).toMatchObject({ status: "queued", sessionId: session.sessionId });
  });

  it("lists audit entries through the public audit endpoint", async () => {
    const app = await buildPublicServerForTest();
    const response = await app.inject({ method: "GET", url: "/api/audit", headers: { authorization: "Bearer tk_test" } });
    expect(response.statusCode).toBe(200);
    expect(response.json()).toMatchObject({ entries: expect.any(Array) });
  });
});
