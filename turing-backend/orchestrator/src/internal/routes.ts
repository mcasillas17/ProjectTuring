import { createHash } from "node:crypto";
import type {
  FastifyBaseLogger,
  FastifyInstance,
  FastifyTypeProviderDefault,
  RawReplyDefaultExpression,
  RawRequestDefaultExpression,
  RawServerBase
} from "fastify";
import { isTuringEventType, type AgentId, type ToolCallBeacon, type ToolPolicyDecision, type TuringEventInput } from "@turing/shared-types";
import type { OrchestratorConfig } from "../config.js";
import type { TuringDatabase } from "../db/connection.js";
import { createAuditService } from "../audit/service.js";
import { createEventsService } from "../events/service.js";
import { createJobsService } from "../jobs/service.js";
import { createSessionsService } from "../sessions/service.js";

type BroadcastHub = { broadcast(event: unknown): void };
type RegisterInternalRoutesDeps = { db: TuringDatabase; config: OrchestratorConfig; hub?: BroadcastHub };
type RunContextRow = { session_id: string; trace_id: string; assistant_message_id: string | null; agent_id: AgentId };
type NextJobQuery = { agent?: string };
type EventBody = { event?: TuringEventInput };
type CompleteBody = { assistantMessageId?: unknown; content?: unknown };
type FailBody = { code?: unknown; message?: unknown; retryable?: unknown };
type MessagesQuery = { limit?: string };
type ReplyLike = { code(statusCode: number): { send(payload?: unknown): unknown } };

const GENERAL_ASSISTANT: AgentId = "general_assistant";

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

function badRequest(reply: ReplyLike, requestId: string, message: string) {
  return reply.code(400).send({ error: { code: "invalid_request", message, requestId } });
}

function notFound(reply: ReplyLike, requestId: string, code: string, message: string) {
  return reply.code(404).send({ error: { code, message, requestId } });
}

function numberFromQuery(value: string | undefined, fallback: number): number {
  if (!value) return fallback;
  const parsed = Number.parseInt(value, 10);
  return Number.isFinite(parsed) && parsed > 0 ? parsed : fallback;
}

function getRunContext(db: TuringDatabase, runId: string): RunContextRow | undefined {
  return db
    .prepare("SELECT session_id, trace_id, assistant_message_id, agent_id FROM agent_runs WHERE id = ?")
    .get(runId) as RunContextRow | undefined;
}

function sessionExists(db: TuringDatabase, sessionId: string): boolean {
  return Boolean(db.prepare("SELECT 1 FROM sessions WHERE id = ?").get(sessionId));
}

function isTuringEventInput(value: unknown): value is TuringEventInput {
  if (!isRecord(value)) return false;
  if (typeof value.sessionId !== "string" || typeof value.traceId !== "string") return false;
  if (value.runId !== undefined && typeof value.runId !== "string") return false;
  if (typeof value.type !== "string" || !isTuringEventType(value.type)) return false;
  if (!isRecord(value.payload)) return false;
  return value.createdAt === undefined || typeof value.createdAt === "string";
}

function isToolCallBeacon(value: unknown): value is ToolCallBeacon {
  if (!isRecord(value)) return false;
  if (value.phase !== "before" && value.phase !== "after") return false;
  if (typeof value.toolCallId !== "string" || value.agentId !== GENERAL_ASSISTANT) return false;
  if (value.serverName !== "system" && value.serverName !== "files") return false;
  if (typeof value.toolName !== "string" || typeof value.runId !== "string" || typeof value.traceId !== "string") return false;
  if (value.args !== undefined && !isRecord(value.args)) return false;
  if (value.status !== undefined && value.status !== "completed" && value.status !== "failed" && value.status !== "denied") return false;
  if (value.resultSummary !== undefined && typeof value.resultSummary !== "string") return false;
  if (value.durationMs !== undefined && typeof value.durationMs !== "number") return false;
  if (value.createdAt !== undefined && typeof value.createdAt !== "string") return false;
  if (value.error !== undefined && value.error !== null) {
    if (!isRecord(value.error) || typeof value.error.code !== "string" || typeof value.error.message !== "string") return false;
  }
  return true;
}

function argsHash(args: Record<string, unknown>) {
  return `sha256:${createHash("sha256").update(JSON.stringify(args)).digest("hex")}`;
}

export async function registerInternalRoutes<
  RawServer extends RawServerBase,
  RawRequest extends RawRequestDefaultExpression<RawServer>,
  RawReply extends RawReplyDefaultExpression<RawServer>,
  Logger extends FastifyBaseLogger
>(app: FastifyInstance<RawServer, RawRequest, RawReply, Logger, FastifyTypeProviderDefault>, deps: RegisterInternalRoutesDeps) {
  const jobs = createJobsService(deps.db, { jobTimeoutMs: deps.config.jobTimeoutMs, maxAttempts: deps.config.jobMaxAttempts });
  const events = createEventsService(deps.db);
  const sessions = createSessionsService(deps.db);
  const audit = createAuditService(deps.db);

  app.get<{ Querystring: NextJobQuery }>("/internal/jobs/next", async (request, reply) => {
    const agent = request.query.agent ?? GENERAL_ASSISTANT;
    if (agent !== GENERAL_ASSISTANT) return badRequest(reply, request.id, "agent must be general_assistant");

    const job = jobs.claimNext(agent);
    if (!job) return reply.code(204).send();

    const started = events.append({
      sessionId: job.sessionId,
      runId: job.runId,
      traceId: job.traceId,
      type: "agent.run.started",
      payload: { runId: job.runId, jobId: job.jobId, status: "running", agentId: job.agentId, attempt: job.attempt }
    });
    deps.hub?.broadcast(started);
    return job;
  });

  app.post<{ Params: { runId: string }; Body: EventBody }>("/internal/runs/:runId/events", async (request, reply) => {
    if (!isTuringEventInput(request.body?.event)) return badRequest(reply, request.id, "event is required");

    const run = getRunContext(deps.db, request.params.runId);
    if (!run) return notFound(reply, request.id, "run_not_found", "Run not found");
    if (request.body.event.sessionId !== run.session_id) return badRequest(reply, request.id, "event sessionId does not match run");

    const appended = events.append({ ...request.body.event, runId: request.params.runId });
    deps.hub?.broadcast(appended);
    return appended;
  });

  app.post<{ Params: { runId: string }; Body: ToolCallBeacon }>("/internal/runs/:runId/audit/tool-call", async (request, reply) => {
    if (!isToolCallBeacon(request.body)) return badRequest(reply, request.id, "valid tool call beacon is required");

    const run = getRunContext(deps.db, request.params.runId);
    if (!run) return notFound(reply, request.id, "run_not_found", "Run not found");

    const args = request.body.args ?? {};
    const now = new Date().toISOString();
    if (request.body.phase === "before") {
      deps.db
        .prepare(
          "INSERT OR IGNORE INTO tool_calls (id, run_id, agent_id, server_name, tool_name, args_json, args_hash, status, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, 'requested', ?)"
        )
        .run(request.body.toolCallId, request.params.runId, request.body.agentId, request.body.serverName, request.body.toolName, JSON.stringify(args), argsHash(args), now);

      const event = events.append({
        sessionId: run.session_id,
        runId: request.params.runId,
        traceId: run.trace_id,
        type: "tool.call.started",
        payload: request.body
      });
      deps.hub?.broadcast(event);
    } else {
      const result = deps.db
        .prepare(
          "UPDATE tool_calls SET status = ?, result_summary = ?, error_code = ?, error_message = ?, duration_ms = ?, completed_at = ? WHERE id = ?"
        )
        .run(
          request.body.status ?? "completed",
          request.body.resultSummary ?? null,
          request.body.error?.code ?? null,
          request.body.error?.message ?? null,
          request.body.durationMs ?? null,
          now,
          request.body.toolCallId
        );
      if (result.changes === 0) return notFound(reply, request.id, "tool_call_not_found", "Tool call not found");

      const type = request.body.status === "failed" ? "tool.call.failed" : request.body.status === "denied" ? "tool.call.denied" : "tool.call.completed";
      const event = events.append({
        sessionId: run.session_id,
        runId: request.params.runId,
        traceId: run.trace_id,
        type,
        payload: request.body
      });
      deps.hub?.broadcast(event);
    }

    audit.record({
      correlationId: request.params.runId,
      actorType: "runtime",
      actorId: request.body.agentId,
      action: request.body.phase === "before" ? "tool.call.before" : "tool.call.after",
      target: `${request.body.serverName}.${request.body.toolName}`,
      payload: { ...request.body, runId: request.params.runId }
    });

    const decision: ToolPolicyDecision = { decision: "allow", toolCallId: request.body.toolCallId };
    return decision;
  });

  app.get<{ Params: { sessionId: string }; Querystring: MessagesQuery }>("/internal/sessions/:sessionId/messages", async (request, reply) => {
    if (!sessionExists(deps.db, request.params.sessionId)) return notFound(reply, request.id, "session_not_found", "Session not found");
    return { messages: sessions.getMessages(request.params.sessionId, numberFromQuery(request.query.limit, 50)) };
  });

  app.post<{ Params: { runId: string }; Body: CompleteBody }>("/internal/runs/:runId/complete", async (request, reply) => {
    if (typeof request.body?.assistantMessageId !== "string" || typeof request.body.content !== "string") {
      return badRequest(reply, request.id, "assistantMessageId and content are required");
    }

    const run = getRunContext(deps.db, request.params.runId);
    if (!run) return notFound(reply, request.id, "run_not_found", "Run not found");

    jobs.completeRun(request.params.runId, request.body.assistantMessageId, request.body.content);
    const completed = events.append({
      sessionId: run.session_id,
      runId: request.params.runId,
      traceId: run.trace_id,
      type: "agent.run.completed",
      payload: { runId: request.params.runId, assistantMessageId: request.body.assistantMessageId }
    });
    deps.hub?.broadcast(completed);
    return { status: "completed" };
  });

  app.post<{ Params: { runId: string }; Body: FailBody }>("/internal/runs/:runId/fail", async (request, reply) => {
    if (typeof request.body?.code !== "string" || typeof request.body.message !== "string") {
      return badRequest(reply, request.id, "code and message are required");
    }

    const run = getRunContext(deps.db, request.params.runId);
    if (!run) return notFound(reply, request.id, "run_not_found", "Run not found");

    jobs.failRun(request.params.runId, request.body.code, request.body.message);
    const failed = events.append({
      sessionId: run.session_id,
      runId: request.params.runId,
      traceId: run.trace_id,
      type: "agent.run.failed",
      payload: { runId: request.params.runId, code: request.body.code, message: request.body.message, retryable: request.body.retryable === true }
    });
    deps.hub?.broadcast(failed);
    return { status: "failed" };
  });
}
