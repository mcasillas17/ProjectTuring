package main

import (
	"bytes"
	"net/http"
	"net/http/httptest"
	"testing"
)

func TestMcpHandlerRequiresBearerToken(t *testing.T) {
	handler := newHandler("system-token")

	req := httptest.NewRequest(http.MethodPost, "/mcp", bytes.NewBufferString(`{"jsonrpc":"2.0","id":1,"method":"tools/list"}`))
	res := httptest.NewRecorder()

	handler.ServeHTTP(res, req)

	if res.Code != http.StatusUnauthorized {
		t.Fatalf("expected unauthorized without bearer token, got %d", res.Code)
	}
}

func TestMcpHandlerListsSystemTools(t *testing.T) {
	handler := newHandler("system-token")

	req := httptest.NewRequest(http.MethodPost, "/mcp", bytes.NewBufferString(`{"jsonrpc":"2.0","id":1,"method":"tools/list"}`))
	req.Header.Set("Authorization", "Bearer system-token")
	res := httptest.NewRecorder()

	handler.ServeHTTP(res, req)

	if res.Code != http.StatusOK {
		t.Fatalf("expected OK, got %d: %s", res.Code, res.Body.String())
	}
	if !bytes.Contains(res.Body.Bytes(), []byte(`"system.health"`)) {
		t.Fatalf("expected tools/list response to include system.health, got %s", res.Body.String())
	}
}

func TestMcpHandlerCallsSystemTool(t *testing.T) {
	handler := newHandler("system-token")

	req := httptest.NewRequest(http.MethodPost, "/mcp", bytes.NewBufferString(`{"jsonrpc":"2.0","id":1,"method":"tools/call","params":{"name":"system.echo","arguments":{"text":"hello"}}}`))
	req.Header.Set("Authorization", "Bearer system-token")
	res := httptest.NewRecorder()

	handler.ServeHTTP(res, req)

	if res.Code != http.StatusOK {
		t.Fatalf("expected OK, got %d: %s", res.Code, res.Body.String())
	}
	if !bytes.Contains(res.Body.Bytes(), []byte(`"text":"hello"`)) {
		t.Fatalf("expected system.echo result, got %s", res.Body.String())
	}
}
