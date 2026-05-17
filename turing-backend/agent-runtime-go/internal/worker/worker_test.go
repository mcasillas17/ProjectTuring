package worker

import (
	"context"
	"errors"
	"testing"
	"time"

	turingv1 "github.com/mcasillas17/TuringAgent/gen/turing/v1/go/turing/v1"
	"github.com/mcasillas17/TuringAgent/turing-backend/agent-runtime-go/internal/llm"
)

type blockingProvider struct {
	started   chan struct{}
	cancelled chan struct{}
}

func (p *blockingProvider) ID() string { return "ollama" }

func (p *blockingProvider) StreamChat(ctx context.Context, req llm.ChatRequest) (<-chan llm.StreamEvent, error) {
	close(p.started)
	out := make(chan llm.StreamEvent)
	go func() {
		defer close(out)
		<-ctx.Done()
		close(p.cancelled)
	}()
	return out, nil
}

func TestWorkerCancelsActiveRunAndAcknowledges(t *testing.T) {
	provider := &blockingProvider{started: make(chan struct{}), cancelled: make(chan struct{})}
	stream := newFakeStream()
	worker := New(Options{WorkerID: "worker-1", MaxConcurrentRuns: 1}, &fakeRuntimeClient{stream: stream}, providerExecutor{provider: provider})
	ctx, cancel := context.WithCancel(context.Background())
	done := make(chan error, 1)
	go func() { done <- worker.Run(ctx) }()

	ready := nextSent(t, stream)
	if ready.GetWorkerReady() == nil || ready.GetWorkerReady().WorkerId != "worker-1" {
		t.Fatalf("first update = %+v, want worker_ready", ready)
	}

	stream.recv <- &turingv1.RuntimeCommand{Command: &turingv1.RuntimeCommand_RunAssigned{RunAssigned: &turingv1.AgentJob{JobId: "job_1", RunId: "run_1", Model: "llama3.2"}}}
	select {
	case <-provider.started:
	case <-time.After(time.Second):
		t.Fatal("provider did not start")
	}

	stream.recv <- &turingv1.RuntimeCommand{Command: &turingv1.RuntimeCommand_RunCancelled{RunCancelled: &turingv1.RuntimeRunCancelled{RunId: "run_1", Reason: "client_cancelled"}}}
	select {
	case <-provider.cancelled:
	case <-time.After(time.Second):
		t.Fatal("provider context was not cancelled")
	}
	ack := nextSent(t, stream)
	if ack.GetRunCancelledAck() == nil || ack.GetRunCancelledAck().RunId != "run_1" {
		t.Fatalf("cancel update = %+v, want run_cancelled_ack", ack)
	}

	cancel()
	if err := <-done; err != nil && !errors.Is(err, context.Canceled) {
		t.Fatalf("Run returned %v", err)
	}
}

func TestWorkerDoesNotSendDerivedMessageCompletedEvent(t *testing.T) {
	stream := newFakeStream()
	worker := New(Options{WorkerID: "worker-1", MaxConcurrentRuns: 1}, &fakeRuntimeClient{stream: stream}, terminalExecutor{})
	ctx, cancel := context.WithCancel(context.Background())
	done := make(chan error, 1)
	go func() { done <- worker.Run(ctx) }()
	_ = nextSent(t, stream)

	stream.recv <- &turingv1.RuntimeCommand{Command: &turingv1.RuntimeCommand_RunAssigned{RunAssigned: &turingv1.AgentJob{JobId: "job_1", RunId: "run_1", AssistantMessageId: "msg_assistant"}}}
	update := nextSent(t, stream)
	if update.GetEvent() != nil && update.GetEvent().Type == turingv1.TuringEventType_TURING_EVENT_TYPE_MESSAGE_COMPLETED {
		t.Fatalf("worker sent derived message.completed event: %+v", update)
	}
	if update.GetRunCompleted() == nil {
		t.Fatalf("update = %+v, want run_completed", update)
	}

	cancel()
	if err := <-done; err != nil && !errors.Is(err, context.Canceled) {
		t.Fatalf("Run returned %v", err)
	}
}

type providerExecutor struct{ provider llm.Provider }

func (e providerExecutor) Execute(ctx context.Context, job *turingv1.AgentJob, emit func(*turingv1.RuntimeUpdate) error) error {
	events, err := e.provider.StreamChat(ctx, llm.ChatRequest{Model: job.Model})
	if err != nil {
		return err
	}
	for range events {
	}
	return ctx.Err()
}

type terminalExecutor struct{}

func (terminalExecutor) Execute(ctx context.Context, job *turingv1.AgentJob, emit func(*turingv1.RuntimeUpdate) error) error {
	if err := emit(&turingv1.RuntimeUpdate{Update: &turingv1.RuntimeUpdate_Event{Event: &turingv1.TuringEvent{RunId: job.GetRunId(), Type: turingv1.TuringEventType_TURING_EVENT_TYPE_MESSAGE_COMPLETED}}}); err != nil {
		return err
	}
	return emit(&turingv1.RuntimeUpdate{Update: &turingv1.RuntimeUpdate_RunCompleted{RunCompleted: &turingv1.RuntimeRunCompleted{RunId: job.GetRunId(), AssistantMessageId: job.GetAssistantMessageId(), Content: "done"}}})
}

type fakeRuntimeClient struct{ stream *fakeStream }

func (c *fakeRuntimeClient) ConnectWorker(ctx context.Context) (RuntimeStream, error) {
	c.stream.ctx = ctx
	return c.stream, nil
}

type fakeStream struct {
	ctx  context.Context
	sent chan *turingv1.RuntimeUpdate
	recv chan *turingv1.RuntimeCommand
}

func newFakeStream() *fakeStream {
	return &fakeStream{sent: make(chan *turingv1.RuntimeUpdate, 8), recv: make(chan *turingv1.RuntimeCommand, 8)}
}

func (s *fakeStream) Send(update *turingv1.RuntimeUpdate) error {
	s.sent <- update
	return nil
}

func (s *fakeStream) Recv() (*turingv1.RuntimeCommand, error) {
	select {
	case cmd := <-s.recv:
		return cmd, nil
	case <-s.ctx.Done():
		return nil, s.ctx.Err()
	}
}

func (s *fakeStream) CloseSend() error { return nil }

func nextSent(t *testing.T, stream *fakeStream) *turingv1.RuntimeUpdate {
	t.Helper()
	select {
	case update := <-stream.sent:
		return update
	case <-time.After(time.Second):
		t.Fatal("timed out waiting for runtime update")
	}
	return nil
}
