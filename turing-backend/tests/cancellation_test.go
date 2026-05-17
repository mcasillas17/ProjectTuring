package tests

import (
	"context"
	"testing"
	"time"

	turingv1 "github.com/mcasillas17/TuringAgent/gen/turing/v1/go/turing/v1"
)

func TestClientCancellationStopsRuntimeAndModel(t *testing.T) {
	harness := newGRPCHarness(t, withBlockingModel())
	defer harness.close()

	sessionID := harness.createSession(t, "cancellation")
	ctx, cancel := context.WithCancel(harness.clientContext())
	stream, err := harness.chat.SendMessage(ctx, &turingv1.SendMessageRequest{
		SessionId:     sessionID,
		Content:       "hello",
		ContentType:   "text",
		AgentId:       turingv1.AgentId_AGENT_ID_GENERAL_ASSISTANT,
		ModelProvider: turingv1.ModelProvider_MODEL_PROVIDER_OPENAI_COMPATIBLE,
		Model:         "fake-model",
	})
	if err != nil {
		t.Fatal(err)
	}
	first, err := stream.Recv()
	if err != nil {
		t.Fatal(err)
	}
	runID := first.GetRunQueued().GetRunId()
	if runID == "" {
		t.Fatalf("first event = %T, want run_queued with run_id", first.GetEvent())
	}
	select {
	case <-harness.fakeModel.started:
	case <-time.After(5 * time.Second):
		t.Fatal("model request did not start")
	}
	cancel()

	select {
	case <-harness.fakeModel.cancelled:
	case <-time.After(2 * time.Second):
		t.Fatal("model request was not cancelled")
	}
	run, err := harness.repo.GetRun(context.Background(), runID)
	if err != nil {
		t.Fatal(err)
	}
	if run.Status != "cancelled" {
		t.Fatalf("run status = %q, want cancelled", run.Status)
	}
}
