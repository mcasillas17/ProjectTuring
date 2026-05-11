package auth

import (
	"net/http/httptest"
	"testing"
)

func TestAgentFromBearerRejectsWrongToken(t *testing.T) {
	req := httptest.NewRequest("POST", "/mcp", nil)
	req.Header.Set("Authorization", "Bearer wrong")
	if _, err := AgentFromBearer(req, "expected"); err == nil {
		t.Fatalf("expected 401-equivalent auth error")
	}
}

func TestAgentFromBearerMapsTokenToGeneralAssistant(t *testing.T) {
	req := httptest.NewRequest("POST", "/mcp", nil)
	req.Header.Set("Authorization", "Bearer expected")
	agent, err := AgentFromBearer(req, "expected")
	if err != nil {
		t.Fatalf("unexpected auth error: %v", err)
	}
	if agent != "general_assistant" {
		t.Fatalf("unexpected agent %q", agent)
	}
}
