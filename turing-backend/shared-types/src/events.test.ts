import { describe, expect, it } from "vitest";
import { isTuringEventType, type TuringEvent } from "./events.js";

describe("events contract", () => {
  it("recognizes supported event types", () => {
    expect(isTuringEventType("message.delta")).toBe(true);
    expect(isTuringEventType("tool.call.denied")).toBe(true);
    expect(isTuringEventType("not.real")).toBe(false);
  });

  it("allows a concrete event envelope", () => {
    const event: TuringEvent = {
      eventId: "evt_01JTEST",
      sessionId: "sess_01JTEST",
      runId: "run_01JTEST",
      traceId: "trace_01JTEST",
      sequence: 1,
      type: "message.delta",
      createdAt: "2026-05-10T00:00:00.000Z",
      payload: { messageId: "msg_01JTEST", delta: "hello" }
    };

    expect(event.sequence).toBe(1);
  });
});
