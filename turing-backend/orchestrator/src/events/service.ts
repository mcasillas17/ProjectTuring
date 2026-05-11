import { ulid } from "ulid";
import type { TuringEvent, TuringEventInput, TuringEventType } from "@turing/shared-types";
import type { TuringDatabase } from "../db/connection.js";
import { parseJson } from "../db/repositories.js";

type SequenceRow = { next: number };
type EventRow = {
  id: string;
  session_id: string;
  run_id: string | null;
  trace_id: string;
  sequence: number;
  type: TuringEventType;
  payload_json: string;
  created_at: string;
};
type LatestSequenceRow = { latest: number };

export const EVENT_REPLAY_LIMIT = 500;

function toEvent(row: EventRow): TuringEvent {
  return {
    eventId: row.id,
    sessionId: row.session_id,
    runId: row.run_id ?? undefined,
    traceId: row.trace_id,
    sequence: row.sequence,
    type: row.type,
    createdAt: row.created_at,
    payload: parseJson<Record<string, unknown>>(row.payload_json)
  };
}

export function createEventsService(db: TuringDatabase) {
  return {
    append(input: TuringEventInput): TuringEvent {
      const tx = db.transaction((): TuringEvent => {
        const row = db.prepare("SELECT COALESCE(MAX(sequence), 0) + 1 AS next FROM events WHERE session_id = ?").get(input.sessionId) as SequenceRow;
        const event: TuringEvent = {
          eventId: `evt_${ulid()}`,
          sessionId: input.sessionId,
          runId: input.runId,
          traceId: input.traceId,
          sequence: row.next,
          type: input.type,
          createdAt: input.createdAt ?? new Date().toISOString(),
          payload: input.payload
        };
        db.prepare("INSERT INTO events (id, session_id, run_id, trace_id, sequence, type, payload_json, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?)").run(
          event.eventId,
          event.sessionId,
          event.runId ?? null,
          event.traceId,
          event.sequence,
          event.type,
          JSON.stringify(event.payload),
          event.createdAt
        );
        return event;
      });

      return tx();
    },

    replay(sessionId: string, afterSequence: number): TuringEvent[] {
      const rows = db
        .prepare(
          "SELECT id, session_id, run_id, trace_id, sequence, type, payload_json, created_at FROM events WHERE session_id = ? AND sequence > ? ORDER BY sequence LIMIT ?"
        )
        .all(sessionId, afterSequence, EVENT_REPLAY_LIMIT) as EventRow[];
      return rows.map(toEvent);
    },

    latestSequence(sessionId: string): number {
      const row = db.prepare("SELECT COALESCE(MAX(sequence), 0) AS latest FROM events WHERE session_id = ?").get(sessionId) as LatestSequenceRow;
      return row.latest;
    }
  };
}
