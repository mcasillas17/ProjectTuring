import type { AgentId, ModelProviderId } from "./jobs.js";

export type SendMessageRequest = {
  content: string;
  contentType?: "text";
  agentId?: AgentId;
  modelProvider?: ModelProviderId;
  model?: string;
  idempotencyKey?: string;
};

export type SendMessageResponse = {
  sessionId: string;
  userMessageId: string;
  assistantMessageId: string;
  runId: string;
  jobId: string;
  traceId: string;
  status: "queued";
};

export type ApiError = {
  error: {
    code: string;
    message: string;
    requestId: string;
    details?: unknown;
  };
};
