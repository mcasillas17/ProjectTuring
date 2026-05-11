import Database from "better-sqlite3";
import { describe, expect, it } from "vitest";
import { applyMigrations } from "../src/db/migrations.js";
import { createEventsService } from "../src/events/service.js";
import { createSessionsService } from "../src/sessions/service.js";
import { buildPublicServer } from "../src/server.js";
import { createWsHub } from "../src/ws/gateway.js";
import { testConfig } from "./testServer.js";

describe("event replay", () => {
  it("persists before replaying by sequence", () => {
    const db = new Database(":memory:");
    applyMigrations(db);
    db.prepare("INSERT INTO sessions (id, created_at, updated_at) VALUES ('sess_1', 'now', 'now')").run();

    const events = createEventsService(db);
    events.append({ sessionId: "sess_1", traceId: "trace_1", type: "system", payload: { message: "one" } });
    events.append({ sessionId: "sess_1", traceId: "trace_1", type: "system", payload: { message: "two" } });

    expect(events.replay("sess_1", 1)).toHaveLength(1);
  });

  it("maps replay rows to TuringEvent shape", () => {
    const db = new Database(":memory:");
    applyMigrations(db);
    const sessions = createSessionsService(db);
    const session = sessions.createSession({ title: "Replay" });
    const queued = sessions.enqueueUserMessage({
      sessionId: session.sessionId,
      content: "hello",
      agentId: "general_assistant",
      modelProvider: "ollama",
      model: "llama3.2"
    });

    const events = createEventsService(db);
    const appended = events.append({
      sessionId: session.sessionId,
      runId: queued.runId,
      traceId: queued.traceId,
      type: "system",
      payload: { nested: { ok: true } },
      createdAt: "now"
    });

    expect(events.replay(session.sessionId, 0)).toEqual([
      {
        eventId: appended.eventId,
        sessionId: session.sessionId,
        runId: queued.runId,
        traceId: queued.traceId,
        sequence: 1,
        type: "system",
        createdAt: "now",
        payload: { nested: { ok: true } }
      }
    ]);
  });

  it("acks hello with durable replay from the requested sequence", async () => {
    const db = new Database(":memory:");
    applyMigrations(db);
    db.prepare("INSERT INTO sessions (id, created_at, updated_at) VALUES ('sess_1', 'now', 'now')").run();
    const events = createEventsService(db);
    events.append({ sessionId: "sess_1", traceId: "trace_1", type: "system", payload: { message: "one" }, createdAt: "now" });
    const second = events.append({ sessionId: "sess_1", traceId: "trace_1", type: "system", payload: { message: "two" }, createdAt: "later" });
    const app = await buildPublicServer({ db, config: testConfig, hub: createWsHub() });

    try {
      await app.ready();
      const socket = await app.injectWS("/ws?token=tk_test");
      const ack = new Promise<Record<string, unknown>>((resolve) => {
        socket.once("message", (raw) => resolve(JSON.parse(raw.toString()) as Record<string, unknown>));
      });

      socket.send(JSON.stringify({ type: "hello", sessionId: "sess_1", lastSequence: 1 }));

      expect(await ack).toEqual({
        type: "hello_ack",
        sessionId: "sess_1",
        latestSequence: 2,
        replayedEvents: [second]
      });
      socket.close();
    } finally {
      await app.close();
      db.close();
    }
  });

  it("marks hello replay as requiring resync when the replay window is truncated", async () => {
    const db = new Database(":memory:");
    applyMigrations(db);
    db.prepare("INSERT INTO sessions (id, created_at, updated_at) VALUES ('sess_1', 'now', 'now')").run();
    const events = createEventsService(db);
    for (let index = 1; index <= 501; index += 1) {
      events.append({ sessionId: "sess_1", traceId: "trace_1", type: "system", payload: { index }, createdAt: `event_${index}` });
    }
    const app = await buildPublicServer({ db, config: testConfig, hub: createWsHub() });

    try {
      await app.ready();
      const socket = await app.injectWS("/ws?token=tk_test");
      const ack = new Promise<Record<string, unknown>>((resolve) => {
        socket.once("message", (raw) => resolve(JSON.parse(raw.toString()) as Record<string, unknown>));
      });

      socket.send(JSON.stringify({ type: "hello", sessionId: "sess_1", lastSequence: 0 }));

      const message = await ack;
      expect(message).toMatchObject({
        type: "hello_ack",
        sessionId: "sess_1",
        latestSequence: 501,
        resyncRequired: true
      });
      expect(message.replayedEvents).toHaveLength(500);
      socket.close();
    } finally {
      await app.close();
      db.close();
    }
  });

  it("does not broadcast session events to clients before hello registration", () => {
    const hub = createWsHub();
    const sent: string[] = [];
    hub.add({
      socket: {
        send: (message: string) => sent.push(message),
        close: () => undefined,
        addEventListener: () => undefined
      } as unknown as WebSocket
    });

    hub.broadcast({ eventId: "evt_1", sessionId: "sess_1", traceId: "trace_1", sequence: 1, type: "system", payload: {}, createdAt: "now" });

    expect(sent).toEqual([]);
  });

  it("broadcasts only to clients registered for the event session", () => {
    const hub = createWsHub();
    const sentA: string[] = [];
    const sentB: string[] = [];
    hub.add({
      sessionId: "sess_a",
      socket: {
        send: (message: string) => sentA.push(message),
        close: () => undefined,
        addEventListener: () => undefined
      } as unknown as WebSocket
    });
    hub.add({
      sessionId: "sess_b",
      socket: {
        send: (message: string) => sentB.push(message),
        close: () => undefined,
        addEventListener: () => undefined
      } as unknown as WebSocket
    });

    const event = { eventId: "evt_1", sessionId: "sess_a", traceId: "trace_1", sequence: 1, type: "system" as const, payload: { ok: true }, createdAt: "now" };
    hub.broadcast(event);

    expect(sentA.map((message) => JSON.parse(message))).toEqual([{ type: "event", event }]);
    expect(sentB).toEqual([]);
  });
});
