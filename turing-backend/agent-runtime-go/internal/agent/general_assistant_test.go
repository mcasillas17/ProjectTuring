package agent

import (
	"context"
	"testing"

	turingv1 "github.com/mcasillas17/TuringAgent/gen/turing/v1/go/turing/v1"
	"github.com/mcasillas17/TuringAgent/turing-backend/agent-runtime-go/internal/llm"
)

func TestGeneralAssistantStreamsDeltasAndCompletesRun(t *testing.T) {
	provider := &scriptedProvider{events: []llm.StreamEvent{{Type: "delta", Text: "Hel"}, {Type: "delta", Text: "lo"}, {Type: "completed", FinishReason: "stop"}}}
	assistant := NewGeneralAssistant(map[turingv1.ModelProvider]llm.Provider{turingv1.ModelProvider_MODEL_PROVIDER_OLLAMA: provider}, fakeMessageClient{messages: []llm.ChatMessage{{Role: "system", Content: "Be helpful"}}}, nil)
	updates := collectUpdates(t, assistant, testJob())

	if updates[0].GetEvent().Type != turingv1.TuringEventType_TURING_EVENT_TYPE_MESSAGE_STARTED {
		t.Fatalf("first update = %+v, want message.started", updates[0])
	}
	if updates[1].GetEvent().Type != turingv1.TuringEventType_TURING_EVENT_TYPE_MESSAGE_DELTA || updates[1].GetEvent().Payload.AsMap()["delta"] != "Hel" {
		t.Fatalf("second update = %+v, want first delta", updates[1])
	}
	if updates[3].GetEvent().Type != turingv1.TuringEventType_TURING_EVENT_TYPE_MESSAGE_COMPLETED {
		t.Fatalf("message completion update = %+v", updates[3])
	}
	if completed := updates[4].GetRunCompleted(); completed == nil || completed.Content != "Hello" || completed.AssistantMessageId != "msg_assistant" {
		t.Fatalf("terminal update = %+v, want run_completed content", updates[4])
	}
	if len(provider.requests) != 1 || len(provider.requests[0].Messages) != 2 || provider.requests[0].Messages[1].Content != "hi" {
		t.Fatalf("provider requests = %+v", provider.requests)
	}
}

func TestGeneralAssistantEmitsRunFailedForProviderError(t *testing.T) {
	provider := &scriptedProvider{events: []llm.StreamEvent{{Type: "error", Code: "model_bad_chunk", Message: "bad chunk"}}}
	assistant := NewGeneralAssistant(map[turingv1.ModelProvider]llm.Provider{turingv1.ModelProvider_MODEL_PROVIDER_OLLAMA: provider}, fakeMessageClient{}, nil)
	updates := collectUpdates(t, assistant, testJob())
	failed := updates[len(updates)-1].GetRunFailed()
	if failed == nil || failed.Code != "model_bad_chunk" || failed.Message != "bad chunk" {
		t.Fatalf("last update = %+v, want run_failed", updates[len(updates)-1])
	}
}

func collectUpdates(t *testing.T, assistant *GeneralAssistant, job *turingv1.AgentJob) []*turingv1.RuntimeUpdate {
	t.Helper()
	var updates []*turingv1.RuntimeUpdate
	if err := assistant.Execute(context.Background(), job, func(update *turingv1.RuntimeUpdate) error {
		updates = append(updates, update)
		return nil
	}); err != nil {
		t.Fatalf("Execute returned error: %v", err)
	}
	return updates
}

func testJob() *turingv1.AgentJob {
	return &turingv1.AgentJob{
		JobId:              "job_1",
		RunId:              "run_1",
		SessionId:          "sess_1",
		UserMessageId:      "msg_user",
		AssistantMessageId: "msg_assistant",
		TraceId:            "trace_1",
		ModelProvider:      turingv1.ModelProvider_MODEL_PROVIDER_OLLAMA,
		Model:              "llama3.2",
		UserText:           "hi",
	}
}

type scriptedProvider struct {
	events   []llm.StreamEvent
	requests []llm.ChatRequest
}

func (p *scriptedProvider) ID() string { return "ollama" }

func (p *scriptedProvider) StreamChat(ctx context.Context, req llm.ChatRequest) (<-chan llm.StreamEvent, error) {
	p.requests = append(p.requests, req)
	out := make(chan llm.StreamEvent, len(p.events))
	go func() {
		defer close(out)
		for _, event := range p.events {
			out <- event
		}
	}()
	return out, nil
}

type fakeMessageClient struct{ messages []llm.ChatMessage }

func (c fakeMessageClient) FetchMessages(ctx context.Context, sessionID string) ([]llm.ChatMessage, error) {
	return c.messages, nil
}
