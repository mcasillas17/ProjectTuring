export const TURING_EVENT_TYPES = [
  "message.started",
  "message.delta",
  "message.completed",
  "agent.run.queued",
  "agent.run.started",
  "agent.run.step",
  "agent.run.completed",
  "agent.run.failed",
  "tool.call.started",
  "tool.call.completed",
  "tool.call.failed",
  "tool.call.denied",
  "approval.requested",
  "approval.approved",
  "approval.denied",
  "approval.expired",
  "approval.consumed",
  "error",
  "system"
] as const;

export type TuringEventType = (typeof TURING_EVENT_TYPES)[number];

export type TuringEvent = {
  eventId: string;
  sessionId: string;
  runId?: string;
  traceId: string;
  sequence: number;
  type: TuringEventType;
  createdAt: string;
  payload: Record<string, unknown>;
};

export type TuringEventInput = Omit<TuringEvent, "eventId" | "sequence" | "createdAt"> & {
  createdAt?: string;
};

export function isTuringEventType(value: string): value is TuringEventType {
  return (TURING_EVENT_TYPES as readonly string[]).includes(value);
}
