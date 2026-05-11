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


  it("rejects non-string session titles", async () => {
    const app = await buildPublicServerForTest();
    const response = await app.inject({
      method: "POST",
      url: "/api/sessions",
      headers: { authorization: "Bearer tk_test" },
      payload: { title: { nested: true } }
    });

    expect(response.statusCode).toBe(400);
    expect(response.json()).toMatchObject({ error: { code: "invalid_request", requestId: expect.any(String) } });
  });

  it("rejects invalid message model options", async () => {
    const app = await buildPublicServerForTest();
    const auth = { authorization: "Bearer tk_test" };
    const sessionResponse = await app.inject({ method: "POST", url: "/api/sessions", headers: auth, payload: { title: "Test" } });
    const session = sessionResponse.json() as { sessionId: string };

    const invalidProviderResponse = await app.inject({
      method: "POST",
      url: `/api/sessions/${session.sessionId}/messages`,
      headers: auth,
      payload: { content: "hello", modelProvider: 123 }
    });
    expect(invalidProviderResponse.statusCode).toBe(400);
    expect(invalidProviderResponse.json()).toMatchObject({ error: { code: "invalid_request", requestId: expect.any(String) } });

    const invalidModelResponse = await app.inject({
      method: "POST",
      url: `/api/sessions/${session.sessionId}/messages`,
      headers: auth,
      payload: { content: "hello", model: 123 }
    });
    expect(invalidModelResponse.statusCode).toBe(400);
    expect(invalidModelResponse.json()).toMatchObject({ error: { code: "invalid_request", requestId: expect.any(String) } });
  });

  it("returns a typed not found error when posting to a missing session", async () => {
    const app = await buildPublicServerForTest();
    const response = await app.inject({
      method: "POST",
      url: "/api/sessions/sess_missing/messages",
      headers: { authorization: "Bearer tk_test" },
      payload: { content: "hello" }
    });

    expect(response.statusCode).toBe(404);
    expect(response.json()).toMatchObject({ error: { code: "session_not_found", requestId: expect.any(String) } });
  });

  it("does not require bearer auth for the websocket path", async () => {
    const app = await buildPublicServerForTest();
    const response = await app.inject({ method: "GET", url: "/ws" });

    expect(response.statusCode).not.toBe(401);
  });

  it("includes the queued job id in replayed agent run events", async () => {
    const app = await buildPublicServerForTest();
    const auth = { authorization: "Bearer tk_test" };
    const sessionResponse = await app.inject({ method: "POST", url: "/api/sessions", headers: auth, payload: { title: "Test" } });
    const session = sessionResponse.json() as { sessionId: string };

    const messageResponse = await app.inject({
      method: "POST",
      url: `/api/sessions/${session.sessionId}/messages`,
      headers: auth,
      payload: { content: "hello" }
    });
    expect(messageResponse.statusCode).toBe(202);
    const message = messageResponse.json() as { jobId: string };

    const eventsResponse = await app.inject({ method: "GET", url: `/api/sessions/${session.sessionId}/events`, headers: auth });
    expect(eventsResponse.statusCode).toBe(200);
    const body = eventsResponse.json() as { events: Array<{ type: string; payload: Record<string, unknown> }> };
    const queuedEvent = body.events.find((event) => event.type === "agent.run.queued");

    expect(queuedEvent?.payload).toMatchObject({ jobId: message.jobId });
  });

  it("lists audit entries through the public audit endpoint", async () => {
    const app = await buildPublicServerForTest();
    const response = await app.inject({ method: "GET", url: "/api/audit", headers: { authorization: "Bearer tk_test" } });
    expect(response.statusCode).toBe(200);
    expect(response.json()).toMatchObject({ entries: expect.any(Array) });
  });
});
