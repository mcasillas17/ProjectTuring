import { describe, expect, it } from "vitest";
import { buildInternalServerForTest, seedQueuedJob } from "./testServer.js";

describe("internal API", () => {
  it("requires the internal token", async () => {
    const app = await buildInternalServerForTest();
    const response = await app.inject({ method: "GET", url: "/internal/jobs/next?agent=general_assistant" });
    expect(response.statusCode).toBe(401);
  });

  it("claims a queued job and appends a run event", async () => {
    const { app, db } = await buildInternalServerForTest();
    const seeded = seedQueuedJob(db);
    const headers = { authorization: "Bearer internal" };

    const claim = await app.inject({ method: "GET", url: "/internal/jobs/next?agent=general_assistant", headers });
    expect(claim.statusCode).toBe(200);
    expect(claim.json()).toMatchObject({ jobId: seeded.jobId, runId: seeded.runId });

    const event = await app.inject({
      method: "POST",
      url: `/internal/runs/${seeded.runId}/events`,
      headers,
      payload: {
        event: {
          sessionId: seeded.sessionId,
          runId: seeded.runId,
          traceId: seeded.traceId,
          type: "message.delta",
          payload: { messageId: seeded.assistantMessageId, delta: "hi" }
        }
      }
    });

    expect(event.statusCode).toBe(200);
    expect(event.json()).toMatchObject({ sequence: 2 });
  });
});
