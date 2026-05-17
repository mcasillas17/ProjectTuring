package audit

import (
	"context"

	"github.com/mcasillas17/TuringAgent/turing-backend/orchestrator-go/internal/repository"
	"github.com/mcasillas17/TuringAgent/turing-backend/orchestrator-go/internal/safejson"
)

type Server struct {
	repo *repository.Repository
}

func New(repo *repository.Repository) *Server {
	return &Server{repo: repo}
}

func (s *Server) Record(ctx context.Context, correlationID string, actorType string, actorID string, action string, target string, payload map[string]any) error {
	payloadJSON := ""
	if payload != nil {
		data, err := safejson.MarshalCanonical(payload)
		if err != nil {
			return err
		}
		payloadJSON = string(data)
	}
	return s.repo.RecordAudit(ctx, correlationID, actorType, actorID, action, target, payloadJSON)
}
