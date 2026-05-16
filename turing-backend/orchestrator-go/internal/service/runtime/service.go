package runtime

import (
	"context"
	"database/sql"
	"encoding/json"
	"sync"

	turingv1 "github.com/mcasillas17/TuringAgent/gen/turing/v1/go/turing/v1"
	"github.com/mcasillas17/TuringAgent/turing-backend/orchestrator-go/internal/repository"
	"github.com/mcasillas17/TuringAgent/turing-backend/orchestrator-go/internal/service/events"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

type Server struct {
	turingv1.UnimplementedRuntimeServiceServer
	repo    *repository.Repository
	bus     *events.Bus
	mu      sync.Mutex
	workers map[string]chan *turingv1.RuntimeCommand
}

func New(repo *repository.Repository, buses ...*events.Bus) *Server {
	var bus *events.Bus
	if len(buses) > 0 {
		bus = buses[0]
	}
	return &Server{repo: repo, bus: bus, workers: map[string]chan *turingv1.RuntimeCommand{}}
}

func (s *Server) ConnectWorker(stream turingv1.RuntimeService_ConnectWorkerServer) error {
	ctx := stream.Context()
	first, err := stream.Recv()
	if err != nil {
		return err
	}
	ready := first.GetWorkerReady()
	if ready == nil || ready.WorkerId == "" || ready.AgentId != turingv1.AgentId_AGENT_ID_GENERAL_ASSISTANT {
		return status.Error(codes.InvalidArgument, "worker_ready is required")
	}
	commands := make(chan *turingv1.RuntimeCommand, 8)
	s.mu.Lock()
	if _, ok := s.workers[ready.WorkerId]; ok {
		s.mu.Unlock()
		return status.Error(codes.AlreadyExists, "worker already connected")
	}
	s.workers[ready.WorkerId] = commands
	s.mu.Unlock()
	defer func() {
		s.mu.Lock()
		delete(s.workers, ready.WorkerId)
		close(commands)
		s.mu.Unlock()
	}()
	if err := stream.Send(&turingv1.RuntimeCommand{Command: &turingv1.RuntimeCommand_WorkerAccepted{WorkerAccepted: &turingv1.RuntimeWorkerAccepted{WorkerId: ready.WorkerId}}}); err != nil {
		return err
	}
	if job, err := s.repo.ClaimNextJob(ctx, "general_assistant", ready.WorkerId); err == nil && job.JobID != "" {
		commands <- &turingv1.RuntimeCommand{Command: &turingv1.RuntimeCommand_RunAssigned{RunAssigned: mapJob(job)}}
	}
	recvErr := make(chan error, 1)
	go func() {
		for {
			update, err := stream.Recv()
			if err != nil {
				recvErr <- err
				return
			}
			if err := s.applyUpdate(ctx, update); err != nil {
				recvErr <- err
				return
			}
		}
	}()
	for {
		select {
		case <-ctx.Done():
			return status.Error(codes.Canceled, "worker stream cancelled")
		case err := <-recvErr:
			return err
		case cmd := <-commands:
			if err := stream.Send(cmd); err != nil {
				return err
			}
		}
	}
}

func (s *Server) CancelRun(ctx context.Context, runID string, reason string) {
	command := &turingv1.RuntimeCommand{Command: &turingv1.RuntimeCommand_RunCancelled{RunCancelled: &turingv1.RuntimeRunCancelled{RunId: runID, Reason: reason}}}
	s.mu.Lock()
	defer s.mu.Unlock()
	for _, commands := range s.workers {
		select {
		case commands <- command:
		default:
		}
	}
}

func (s *Server) applyUpdate(ctx context.Context, update *turingv1.RuntimeUpdate) error {
	if update == nil {
		return status.Error(codes.InvalidArgument, "runtime update is required")
	}
	switch value := update.Update.(type) {
	case *turingv1.RuntimeUpdate_Heartbeat:
		return nil
	case *turingv1.RuntimeUpdate_Event:
		event, err := s.repo.AppendRuntimeEvent(ctx, value.Event)
		if err != nil {
			return err
		}
		s.publishEvent(event)
		return nil
	case *turingv1.RuntimeUpdate_ToolBeacon:
		_, err := s.handleToolBeacon(ctx, value.ToolBeacon)
		return err
	case *turingv1.RuntimeUpdate_RunCompleted:
		return s.handleRunCompleted(ctx, value.RunCompleted)
	case *turingv1.RuntimeUpdate_RunFailed:
		return s.handleRunFailed(ctx, value.RunFailed)
	case *turingv1.RuntimeUpdate_RunCancelledAck:
		return nil
	default:
		return status.Error(codes.InvalidArgument, "unsupported runtime update")
	}
}

func (s *Server) handleRunCompleted(ctx context.Context, completed *turingv1.RuntimeRunCompleted) error {
	if completed == nil || completed.RunId == "" {
		return status.Error(codes.InvalidArgument, "run_completed is required")
	}
	payloadJSON, err := encodePayload(map[string]any{"assistantMessageId": completed.AssistantMessageId})
	if err != nil {
		return err
	}
	event, err := s.repo.CompleteRunWithEvent(ctx, completed.RunId, completed.AssistantMessageId, completed.Content, payloadJSON)
	if err != nil {
		return err
	}
	s.publishEvent(event)
	return nil
}

func (s *Server) handleRunFailed(ctx context.Context, failed *turingv1.RuntimeRunFailed) error {
	if failed == nil || failed.RunId == "" {
		return status.Error(codes.InvalidArgument, "run_failed is required")
	}
	payloadJSON, err := encodePayload(map[string]any{"code": failed.Code, "message": failed.Message, "retryable": failed.Retryable})
	if err != nil {
		return err
	}
	event, err := s.repo.FailRunWithEvent(ctx, failed.RunId, failed.Code, failed.Message, payloadJSON)
	if err != nil {
		return err
	}
	s.publishEvent(event)
	return nil
}

func encodePayload(payload map[string]any) (string, error) {
	data, err := json.Marshal(payload)
	if err != nil {
		return "", err
	}
	return string(data), nil
}

func (s *Server) handleToolBeacon(ctx context.Context, beacon *turingv1.ToolCallBeacon) (*turingv1.ToolPolicyDecision, error) {
	if beacon == nil {
		return nil, status.Error(codes.InvalidArgument, "tool_beacon is required")
	}
	return &turingv1.ToolPolicyDecision{Decision: turingv1.ToolPolicyDecision_DECISION_ALLOW, ToolCallId: beacon.ToolCallId}, nil
}

func (s *Server) publishEvent(event repository.Event) {
	if s.bus == nil {
		return
	}
	s.bus.Publish(events.Event{
		EventID:     event.EventID,
		SessionID:   event.SessionID,
		RunID:       nullString(event.RunID),
		TraceID:     event.TraceID,
		Sequence:    event.Sequence,
		Type:        event.Type,
		CreatedAt:   event.CreatedAt,
		PayloadJSON: event.PayloadJSON,
	})
}

func nullString(value sql.NullString) string {
	if value.Valid {
		return value.String
	}
	return ""
}

func mapJob(job repository.Job) *turingv1.AgentJob {
	provider := turingv1.ModelProvider_MODEL_PROVIDER_UNSPECIFIED
	if job.ModelProvider == "ollama" {
		provider = turingv1.ModelProvider_MODEL_PROVIDER_OLLAMA
	}
	if job.ModelProvider == "openai_compatible" {
		provider = turingv1.ModelProvider_MODEL_PROVIDER_OPENAI_COMPATIBLE
	}
	return &turingv1.AgentJob{
		JobId:              job.JobID,
		RunId:              job.RunID,
		SessionId:          job.SessionID,
		UserMessageId:      job.UserMessageID,
		AssistantMessageId: job.AssistantMessageID,
		AgentId:            turingv1.AgentId_AGENT_ID_GENERAL_ASSISTANT,
		TraceId:            job.TraceID,
		ModelProvider:      provider,
		Model:              job.Model,
		UserText:           job.UserText,
		Attempt:            int32(job.Attempt),
	}
}
