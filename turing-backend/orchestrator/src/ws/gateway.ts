import { Buffer } from "node:buffer";
import type {
  FastifyBaseLogger,
  FastifyInstance,
  FastifyTypeProviderDefault,
  RawReplyDefaultExpression,
  RawRequestDefaultExpression,
  RawServerBase
} from "fastify";
import type { TuringEvent } from "@turing/shared-types";
import type { WebSocket } from "@fastify/websocket";
import type { TuringDatabase } from "../db/connection.js";
import { createEventsService } from "../events/service.js";
import { tokenMatches } from "../security/auth.js";

type Client = {
  sessionId?: string;
  socket: WebSocket;
};

type ClientMessage = {
  type: string;
  sessionId?: string;
  lastSequence?: number;
  ts?: number;
};

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

function rawMessageToString(raw: unknown): string {
  if (typeof raw === "string") return raw;
  if (Buffer.isBuffer(raw)) return raw.toString("utf8");
  if (Array.isArray(raw)) return Buffer.concat(raw).toString("utf8");
  if (raw instanceof ArrayBuffer) return Buffer.from(raw).toString("utf8");
  if (ArrayBuffer.isView(raw)) return Buffer.from(raw.buffer, raw.byteOffset, raw.byteLength).toString("utf8");
  return String(raw);
}

function parseClientMessage(raw: unknown): ClientMessage | undefined {
  const parsed = JSON.parse(rawMessageToString(raw)) as unknown;
  if (!isRecord(parsed) || typeof parsed.type !== "string") return undefined;
  return {
    type: parsed.type,
    sessionId: typeof parsed.sessionId === "string" ? parsed.sessionId : undefined,
    lastSequence: typeof parsed.lastSequence === "number" && Number.isFinite(parsed.lastSequence) ? parsed.lastSequence : undefined,
    ts: typeof parsed.ts === "number" && Number.isFinite(parsed.ts) ? parsed.ts : undefined
  };
}

export function createWsHub() {
  const clients = new Set<Client>();

  return {
    add(client: Client) {
      clients.add(client);
      client.socket.addEventListener("close", () => clients.delete(client));
    },

    broadcast(event: TuringEvent) {
      for (const client of clients) {
        if (!client.sessionId || client.sessionId !== event.sessionId) continue;
        try {
          client.socket.send(JSON.stringify({ type: "event", event }));
        } catch {
          client.socket.close();
          clients.delete(client);
        }
      }
    }
  };
}

export async function registerWebSocket<
  RawServer extends RawServerBase,
  RawRequest extends RawRequestDefaultExpression<RawServer>,
  RawReply extends RawReplyDefaultExpression<RawServer>,
  Logger extends FastifyBaseLogger
>(
  app: FastifyInstance<RawServer, RawRequest, RawReply, Logger, FastifyTypeProviderDefault>,
  deps: { db: TuringDatabase; clientApiKey: string; hub: ReturnType<typeof createWsHub> }
) {
  const events = createEventsService(deps.db);

  app.get("/ws", { websocket: true }, (socket, request) => {
    const token = (request.query as { token?: string }).token;
    if (!tokenMatches(token, deps.clientApiKey)) {
      socket.close(1008, "unauthorized");
      return;
    }

    const client: Client = { socket };
    deps.hub.add(client);

    socket.on("message", (raw) => {
      let message: ClientMessage | undefined;
      try {
        message = parseClientMessage(raw);
      } catch {
        socket.close(1008, "invalid_json");
        return;
      }

      if (!message) {
        socket.close(1008, "invalid_message");
        return;
      }

      if (message.type === "hello") {
        if (!message.sessionId) {
          socket.close(1008, "invalid_hello");
          return;
        }
        client.sessionId = message.sessionId;
        const afterSequence = message.lastSequence ?? 0;
        const replayedEvents = events.replay(message.sessionId, afterSequence);
        socket.send(
          JSON.stringify({
            type: "hello_ack",
            sessionId: message.sessionId,
            latestSequence: replayedEvents.at(-1)?.sequence ?? afterSequence,
            replayedEvents
          })
        );
        return;
      }

      if (message.type === "ping") {
        socket.send(JSON.stringify({ type: "pong", ts: message.ts }));
        return;
      }

      socket.close(1008, "invalid_message");
    });
  });
}
