import { ulid } from "ulid";
import type { AgentId, ModelProviderId, SendMessageResponse } from "@turing/shared-types";
import type { TuringDatabase } from "../db/connection.js";

const now = () => new Date().toISOString();
const id = (prefix: string) => `${prefix}_${ulid()}`;

type SessionRow = {
  id: string;
  title: string | null;
  status: "active" | "archived";
  createdAt: string;
  updatedAt: string;
};

type MessageRow = {
  id: string;
  role: "user" | "assistant" | "system" | "tool";
  content: string;
  contentType: string;
  sequence: number;
  createdAt: string;
};

type SequenceRow = { next: number };

export function createSessionsService(db: TuringDatabase) {
  return {
    createSession(input: { title?: string }) {
      const createdAt = now();
      const sessionId = id("sess");
      db.prepare("INSERT INTO sessions (id, title, created_at, updated_at) VALUES (?, ?, ?, ?)").run(
        sessionId,
        input.title ?? null,
        createdAt,
        createdAt
      );
      return { sessionId, createdAt };
    },

    listSessions(limit = 50) {
      return db
        .prepare("SELECT id, title, status, created_at AS createdAt, updated_at AS updatedAt FROM sessions ORDER BY updated_at DESC LIMIT ?")
        .all(limit) as SessionRow[];
    },

    getMessages(sessionId: string, limit = 50) {
      return (db
        .prepare(
          "SELECT id, role, content, content_type AS contentType, sequence, created_at AS createdAt FROM messages WHERE session_id = ? ORDER BY sequence DESC LIMIT ?"
        )
        .all(sessionId, limit) as MessageRow[]).reverse();
    },

    enqueueUserMessage(input: {
      sessionId: string;
      content: string;
      agentId: AgentId;
      modelProvider: ModelProviderId;
      model: string;
    }): SendMessageResponse {
      const createdAt = now();
      const userMessageId = id("msg");
      const assistantMessageId = id("msg");
      const runId = id("run");
      const jobId = id("job");
      const traceId = id("trace");

      const tx = db.transaction(() => {
        const sequenceRow = db
          .prepare("SELECT COALESCE(MAX(sequence), 0) + 1 AS next FROM messages WHERE session_id = ?")
          .get(input.sessionId) as SequenceRow;

        db.prepare("INSERT INTO messages (id, session_id, role, content, content_type, sequence, created_at) VALUES (?, ?, 'user', ?, 'text', ?, ?)").run(
          userMessageId,
          input.sessionId,
          input.content,
          sequenceRow.next,
          createdAt
        );
        db.prepare("INSERT INTO messages (id, session_id, run_id, role, content, content_type, sequence, created_at) VALUES (?, ?, ?, 'assistant', '', 'text', ?, ?)").run(
          assistantMessageId,
          input.sessionId,
          runId,
          sequenceRow.next + 1,
          createdAt
        );
        db.prepare("INSERT INTO agent_runs (id, session_id, user_message_id, assistant_message_id, agent_id, trace_id, status, model_provider, model_name, created_at) VALUES (?, ?, ?, ?, ?, ?, 'queued', ?, ?, ?)").run(
          runId,
          input.sessionId,
          userMessageId,
          assistantMessageId,
          input.agentId,
          traceId,
          input.modelProvider,
          input.model,
          createdAt
        );
        db.prepare("INSERT INTO jobs (id, run_id, agent_id, status, payload_json, created_at) VALUES (?, ?, ?, 'pending', ?, ?)").run(
          jobId,
          runId,
          input.agentId,
          JSON.stringify({
            userText: input.content,
            sessionId: input.sessionId,
            userMessageId,
            assistantMessageId,
            traceId,
            modelProvider: input.modelProvider,
            model: input.model
          }),
          createdAt
        );
      });
      tx();

      return { sessionId: input.sessionId, userMessageId, assistantMessageId, runId, jobId, traceId, status: "queued" };
    }
  };
}
