package auth

import (
	"errors"
	"net/http"
)

func AgentFromBearer(r *http.Request, systemToken string) (string, error) {
	if systemToken == "" || r.Header.Get("Authorization") != "Bearer "+systemToken {
		return "", errors.New("unauthorized")
	}
	// v1.0 has one runtime/MCP token for the general assistant; v1.1 should
	// replace this with a token-to-agent map.
	return "general_assistant", nil
}
