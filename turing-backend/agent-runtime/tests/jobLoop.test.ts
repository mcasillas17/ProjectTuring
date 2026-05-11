import { describe, expect, it } from "vitest";
import type { AgentJob } from "@turing/shared-types";
import { runOneJob } from "../src/executor/jobLoop.js";
import type { AgentExecutor } from "../src/executor/types.js";

const job: AgentJob = {
  jobId: "job_1",
  runId: "run_1",
  sessionId: "sess_1",
  userMessageId: "msg_user",
  assistantMessageId: "msg_assistant",
  agentId: "general_assistant",
  traceId: "trace_1",
  modelProvider: "ollama",
  model: "llama3.2",
  payload: { userText: "hello" },
  attempt: 1
};

describe("runOneJob", () => {
  it("posts events and completion from an AgentExecutor", async () => {
    const calls: string[] = [];
    const executor: AgentExecutor = {
      agentId: "general_assistant",
      async *execute() {
        yield { type: "event", event: { sessionId: "sess_1", runId: "run_1", traceId: "trace_1", type: "message.delta", payload: { messageId: "msg_assistant", delta: "hi" } } };
        yield { type: "complete", content: "hi" };
      }
    };

    await runOneJob(job, executor, {
      fetchMessages: async () => [],
      postEvent: async () => { calls.push("event"); },
      completeRun: async () => { calls.push("complete"); },
      failRun: async () => { calls.push("fail"); }
    });

    expect(calls).toEqual(["event", "complete"]);
  });
});
