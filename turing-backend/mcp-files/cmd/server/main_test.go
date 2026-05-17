package main

import (
	"bytes"
	"net/http"
	"net/http/httptest"
	"os"
	"path/filepath"
	"testing"
)

func TestMcpHandlerRejectsUnauthorizedRequests(t *testing.T) {
	handler := newHandler(serverConfig{
		filesToken:           "files-token",
		approvalJwtSecret:    "jwt-secret",
		orchestratorGRPCAddr: "orchestrator:3001",
		internalToken:        "internal-token",
		sandboxRoot:          t.TempDir(),
	})

	req := httptest.NewRequest(http.MethodPost, "/mcp", bytes.NewBufferString(`{"jsonrpc":"2.0","id":1,"method":"tools/list"}`))
	res := httptest.NewRecorder()

	handler.ServeHTTP(res, req)

	if res.Code != http.StatusUnauthorized {
		t.Fatalf("expected unauthorized without bearer token, got %d", res.Code)
	}
}

func TestMcpHandlerListsFilesTools(t *testing.T) {
	handler := newHandler(serverConfig{
		filesToken:           "files-token",
		approvalJwtSecret:    "jwt-secret",
		orchestratorGRPCAddr: "orchestrator:3001",
		internalToken:        "internal-token",
		sandboxRoot:          t.TempDir(),
	})

	req := httptest.NewRequest(http.MethodPost, "/mcp", bytes.NewBufferString(`{"jsonrpc":"2.0","id":1,"method":"tools/list"}`))
	req.Header.Set("Authorization", "Bearer files-token")
	res := httptest.NewRecorder()

	handler.ServeHTTP(res, req)

	if res.Code != http.StatusOK {
		t.Fatalf("expected OK, got %d: %s", res.Code, res.Body.String())
	}
	if !bytes.Contains(res.Body.Bytes(), []byte(`"files.read"`)) {
		t.Fatalf("expected tools/list response to include files.read, got %s", res.Body.String())
	}
}

func TestMcpHandlerCallsFilesReadTool(t *testing.T) {
	sandbox := t.TempDir()
	if err := os.WriteFile(filepath.Join(sandbox, "note.txt"), []byte("hello"), 0600); err != nil {
		t.Fatal(err)
	}
	handler := newHandler(serverConfig{
		filesToken:           "files-token",
		approvalJwtSecret:    "jwt-secret",
		orchestratorGRPCAddr: "orchestrator:3001",
		internalToken:        "internal-token",
		sandboxRoot:          sandbox,
	})

	req := httptest.NewRequest(http.MethodPost, "/mcp", bytes.NewBufferString(`{"jsonrpc":"2.0","id":1,"method":"tools/call","params":{"name":"files.read","arguments":{"path":"note.txt"}}}`))
	req.Header.Set("Authorization", "Bearer files-token")
	res := httptest.NewRecorder()

	handler.ServeHTTP(res, req)

	if res.Code != http.StatusOK {
		t.Fatalf("expected OK, got %d: %s", res.Code, res.Body.String())
	}
	if !bytes.Contains(res.Body.Bytes(), []byte(`"content":"hello"`)) {
		t.Fatalf("expected files.read result, got %s", res.Body.String())
	}
}
