package sessions

import (
	"context"
	"time"

	turingv1 "github.com/mcasillas17/TuringAgent/gen/turing/v1/go/turing/v1"
	"github.com/mcasillas17/TuringAgent/turing-backend/orchestrator-go/internal/config"
	"github.com/mcasillas17/TuringAgent/turing-backend/orchestrator-go/internal/repository"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
	"google.golang.org/protobuf/types/known/timestamppb"
)

type Server struct {
	turingv1.UnimplementedSessionServiceServer
	repo *repository.Repository
	cfg  config.Config
}

func New(repo *repository.Repository, cfg config.Config) *Server {
	return &Server{repo: repo, cfg: cfg}
}

func (s *Server) CreateSession(ctx context.Context, req *turingv1.CreateSessionRequest) (*turingv1.CreateSessionResponse, error) {
	if req == nil {
		return nil, status.Error(codes.InvalidArgument, "request is required")
	}
	session, err := s.repo.CreateSession(ctx, req.Title)
	if err != nil {
		return nil, status.Error(codes.Internal, "create session failed")
	}
	return &turingv1.CreateSessionResponse{SessionId: session.SessionID, CreatedAt: parseTimestamp(session.CreatedAt)}, nil
}

func (s *Server) ListMessages(ctx context.Context, req *turingv1.ListMessagesRequest) (*turingv1.ListMessagesResponse, error) {
	if req == nil || req.SessionId == "" {
		return nil, status.Error(codes.InvalidArgument, "session_id is required")
	}
	messages, err := s.repo.ListMessages(ctx, req.SessionId, int(req.Limit))
	if err != nil {
		return nil, status.Error(codes.Internal, "list messages failed")
	}
	out := make([]*turingv1.Message, 0, len(messages))
	for _, message := range messages {
		out = append(out, mapMessage(req.SessionId, message))
	}
	return &turingv1.ListMessagesResponse{Messages: out}, nil
}

func (s *Server) GetConfig(context.Context, *turingv1.GetConfigRequest) (*turingv1.GetConfigResponse, error) {
	providers := []*turingv1.ProviderConfig{
		{Provider: turingv1.ModelProvider_MODEL_PROVIDER_OLLAMA, Enabled: s.cfg.OllamaModel != "", DefaultModel: s.cfg.OllamaModel},
		{Provider: turingv1.ModelProvider_MODEL_PROVIDER_OPENAI_COMPATIBLE, Enabled: s.cfg.OpenAIAPIKey != "", DefaultModel: s.cfg.OpenAIModel},
	}
	return &turingv1.GetConfigResponse{
		Providers:        providers,
		ApprovalsEnabled: s.cfg.ApprovalJWTSecret != "",
		FilesMcpEnabled:  s.cfg.MCPFilesTokenGeneral != "",
	}, nil
}

func (s *Server) ListAgents(context.Context, *turingv1.ListAgentsRequest) (*turingv1.ListAgentsResponse, error) {
	agents := []*turingv1.AgentDescriptor{{Id: turingv1.AgentId_AGENT_ID_GENERAL_ASSISTANT, DisplayName: "General Assistant"}}
	return &turingv1.ListAgentsResponse{Agents: agents}, nil
}

func (s *Server) ListTools(context.Context, *turingv1.ListToolsRequest) (*turingv1.ListToolsResponse, error) {
	tools := []*turingv1.ToolDescriptor{
		{ServerName: "system", ToolName: "system.time", Policy: turingv1.ToolPolicy_TOOL_POLICY_SAFE},
		{ServerName: "files", ToolName: "files.create", Policy: turingv1.ToolPolicy_TOOL_POLICY_APPROVAL_REQUIRED},
	}
	return &turingv1.ListToolsResponse{Tools: tools}, nil
}

func mapMessage(sessionID string, message repository.Message) *turingv1.Message {
	return &turingv1.Message{
		MessageId:   message.MessageID,
		SessionId:   sessionID,
		Role:        mapRole(message.Role),
		Content:     message.Content,
		ContentType: message.ContentType,
		Sequence:    message.Sequence,
		CreatedAt:   parseTimestamp(message.CreatedAt),
	}
}

func mapRole(role string) turingv1.MessageRole {
	switch role {
	case "system":
		return turingv1.MessageRole_MESSAGE_ROLE_SYSTEM
	case "user":
		return turingv1.MessageRole_MESSAGE_ROLE_USER
	case "assistant":
		return turingv1.MessageRole_MESSAGE_ROLE_ASSISTANT
	case "tool":
		return turingv1.MessageRole_MESSAGE_ROLE_TOOL
	default:
		return turingv1.MessageRole_MESSAGE_ROLE_UNSPECIFIED
	}
}

func parseTimestamp(value string) *timestamppb.Timestamp {
	t, err := time.Parse(time.RFC3339Nano, value)
	if err != nil {
		return nil
	}
	return timestamppb.New(t)
}
