package mcp

import (
	"context"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
)

func TestCallToolReturnsJSONRPCErrorMessage(t *testing.T) {
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("content-type", "application/json")
		w.Write([]byte(`{"jsonrpc":"2.0","id":1,"error":{"code":-32000,"message":"denied"}}`))
	}))
	t.Cleanup(server.Close)
	client := NewClient(server.URL, "token", server.Client())
	_, err := client.CallTool(context.Background(), "files.read", map[string]any{"path": "note.txt"})
	if err == nil || !strings.Contains(err.Error(), "denied") {
		t.Fatalf("CallTool error = %v, want denied", err)
	}
}
