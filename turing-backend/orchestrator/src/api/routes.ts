import type {
  FastifyBaseLogger,
  FastifyInstance,
  FastifyTypeProviderDefault,
  RawReplyDefaultExpression,
  RawRequestDefaultExpression,
  RawServerBase
} from "fastify";
import type { AgentId, ModelProviderId, TuringEvent } from "@turing/shared-types";
import type { OrchestratorConfig } from "../config.js";
import type { TuringDatabase } from "../db/connection.js";
import { listToolCalls, getSessionById } from "../db/repositories.js";
import { createAuditService } from "../audit/service.js";
import { createEventsService } from "../events/service.js";
import { createJobsService } from "../jobs/service.js";
import { createSessionsService } from "../sessions/service.js";
import { createApprovalsService } from "../approvals/service.js";

type BroadcastHub = { broadcast(event: TuringEvent): void };
type RegisterPublicRoutesDeps = { db: TuringDatabase; config: OrchestratorConfig; hub?: BroadcastHub };
type CreateSessionBody = { title?: unknown };
type SendMessageBody = { content?: unknown; modelProvider?: unknown; model?: unknown };

const GENERAL_ASSISTANT: AgentId = "general_assistant";

function isModelProvider(value: unknown): value is ModelProviderId {
  return value === "ollama" || value === "openai_compatible";
}

function numberFromQuery(value: string | undefined, fallback: number): number {
  if (!value) return fallback;
  const parsed = Number.parseInt(value, 10);
  return Number.isFinite(parsed) ? parsed : fallback;
}

export async function registerPublicRoutes<
  RawServer extends RawServerBase,
  RawRequest extends RawRequestDefaultExpression<RawServer>,
  RawReply extends RawReplyDefaultExpression<RawServer>,
  Logger extends FastifyBaseLogger
>(app: FastifyInstance<RawServer, RawRequest, RawReply, Logger, FastifyTypeProviderDefault>, deps: RegisterPublicRoutesDeps) {
  const sessions = createSessionsService(deps.db);
  const jobs = createJobsService(deps.db, { jobTimeoutMs: deps.config.jobTimeoutMs, maxAttempts: deps.config.jobMaxAttempts });
  const audit = createAuditService(deps.db);
  const events = createEventsService(deps.db);
  const approvals = createApprovalsService(deps.db, deps.config.approvalJwtSecret);

  app.post<{ Params: { approvalId: string } }>("/api/approvals/:approvalId/approve", async (request, reply) => {
    try {
      const approved = await approvals.approve(request.params.approvalId);
      if (approved.event) deps.hub?.broadcast(approved.event);
      return approved;
    } catch (error) {
      const message = error instanceof Error ? error.message : "approval failed";
      const status = /expired/i.test(message) ? 410 : 409;
      return reply.code(status).send({ error: { code: status === 410 ? "approval_expired" : "approval_not_pending", message, requestId: request.id } });
    }
  });

  app.post<{ Params: { approvalId: string } }>("/api/approvals/:approvalId/deny", async (request, reply) => {
    try {
      const denied = approvals.deny(request.params.approvalId);
      if (denied.event) deps.hub?.broadcast(denied.event);
      return denied;
    } catch (error) {
      return reply.code(409).send({ error: { code: "approval_not_pending", message: error instanceof Error ? error.message : "approval failed", requestId: request.id } });
    }
  });

  app.get("/api/config", async () => ({
    providers: {
      ollama: { enabled: true, defaultModel: deps.config.ollamaModel },
      openai_compatible: { enabled: Boolean(deps.config.openaiApiKey), defaultModel: deps.config.openaiModel }
    },
    features: { approvals: true, filesMcp: true }
  }));

  app.post<{ Body: CreateSessionBody }>("/api/sessions", async (request, reply) => {
    if (request.body?.title !== undefined && typeof request.body.title !== "string") {
      return reply.code(400).send({ error: { code: "invalid_request", message: "title must be a string", requestId: request.id } });
    }

    return reply.code(201).send(sessions.createSession({ title: request.body?.title }));
  });

  app.get("/api/sessions", async () => ({ sessions: sessions.listSessions() }));

  app.get<{ Params: { sessionId: string } }>("/api/sessions/:sessionId", async (request, reply) => {
    const session = getSessionById(deps.db, request.params.sessionId);
    if (!session) return reply.code(404).send({ error: { code: "session_not_found", message: "Session not found", requestId: request.id } });
    return session;
  });

  app.get<{ Params: { sessionId: string } }>("/api/sessions/:sessionId/messages", async (request) => ({
    messages: sessions.getMessages(request.params.sessionId)
  }));

  app.get<{ Params: { sessionId: string }; Querystring: { after?: string } }>("/api/sessions/:sessionId/events", async (request) => {
    const afterSequence = numberFromQuery(request.query.after, 0);
    const replayedEvents = events.replay(request.params.sessionId, afterSequence);
    const latestSequence = Math.max(afterSequence, events.latestSequence(request.params.sessionId));
    const lastReplayedSequence = replayedEvents.at(-1)?.sequence ?? afterSequence;
    const resyncRequired = latestSequence > lastReplayedSequence;
    return {
      events: replayedEvents,
      latestSequence,
      ...(resyncRequired ? { resyncRequired: true } : {})
    };
  });

  app.post<{ Params: { sessionId: string }; Body: SendMessageBody }>("/api/sessions/:sessionId/messages", async (request, reply) => {
    if (typeof request.body?.content !== "string" || request.body.content.length === 0) {
      return reply.code(400).send({ error: { code: "invalid_request", message: "content is required", requestId: request.id } });
    }
    if (request.body.modelProvider !== undefined && !isModelProvider(request.body.modelProvider)) {
      return reply.code(400).send({ error: { code: "invalid_request", message: "modelProvider must be ollama or openai_compatible", requestId: request.id } });
    }
    if (request.body.model !== undefined && typeof request.body.model !== "string") {
      return reply.code(400).send({ error: { code: "invalid_request", message: "model must be a string", requestId: request.id } });
    }
    if (!getSessionById(deps.db, request.params.sessionId)) {
      return reply.code(404).send({ error: { code: "session_not_found", message: "Session not found", requestId: request.id } });
    }

    const modelProvider = request.body.modelProvider ?? "ollama";
    const model = request.body.model ?? (modelProvider === "ollama" ? deps.config.ollamaModel : deps.config.openaiModel);
    const result = sessions.enqueueUserMessage({
      sessionId: request.params.sessionId,
      content: request.body.content,
      agentId: GENERAL_ASSISTANT,
      modelProvider,
      model
    });
    const queuedEvent = events.append({
      sessionId: request.params.sessionId,
      runId: result.runId,
      traceId: result.traceId,
      type: "agent.run.queued",
      payload: { runId: result.runId, jobId: result.jobId, status: "queued", agentId: GENERAL_ASSISTANT }
    });

    deps.hub?.broadcast(queuedEvent);
    jobs.reapStaleJobs();
    return reply.code(202).send(result);
  });

  app.get("/api/agents", async () => ({
    agents: [{ id: GENERAL_ASSISTANT, displayName: "General Assistant" }]
  }));

  app.get("/api/tools", async () => ({
    tools: [
      { serverName: "system", toolName: "system.time", policy: "safe" },
      { serverName: "files", toolName: "files.update", policy: "approval_required" }
    ]
  }));

  app.get("/api/audit", async () => ({ entries: audit.list(100) }));
  app.get("/api/tool-calls", async () => ({ toolCalls: listToolCalls(deps.db, 100) }));
}
