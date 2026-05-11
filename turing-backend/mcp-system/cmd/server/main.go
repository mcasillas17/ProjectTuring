package main

import (
	"encoding/json"
	"log"
	"net/http"
	"os"

	"github.com/project-turing/mcp-system/internal/auth"
	"github.com/project-turing/mcp-system/internal/jsonrpc"
	"github.com/project-turing/mcp-system/internal/tools"
)

func main() {
	addr := ":" + envOrDefault("PORT", "7100")
	log.Printf("starting mcp-system on %s", addr)
	if err := http.ListenAndServe(addr, newHandler(os.Getenv("MCP_SYSTEM_TOKEN_GENERAL"))); err != nil {
		log.Fatal(err)
	}
}

func newHandler(token string) http.Handler {
	mux := http.NewServeMux()
	mux.Handle("/mcp", auth.RequireBearer(token, http.HandlerFunc(handleMCP)))
	return mux
}

func handleMCP(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
		return
	}

	var req jsonrpc.Request
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "bad request", http.StatusBadRequest)
		return
	}

	switch req.Method {
	case "tools/list":
		writeJSONRPC(w, jsonrpc.Response{JSONRPC: "2.0", ID: req.ID, Result: map[string]any{"tools": tools.List()}})
	case "tools/call":
		name, _ := req.Params["name"].(string)
		args, _ := req.Params["arguments"].(map[string]any)
		if args == nil {
			args = map[string]any{}
		}
		result, err := tools.Call(name, args)
		if err != nil {
			writeJSONRPC(w, jsonrpc.Response{JSONRPC: "2.0", ID: req.ID, Error: map[string]any{"code": -32000, "message": err.Error()}})
			return
		}
		writeJSONRPC(w, jsonrpc.Response{JSONRPC: "2.0", ID: req.ID, Result: result})
	default:
		writeJSONRPC(w, jsonrpc.Response{JSONRPC: "2.0", ID: req.ID, Error: map[string]any{"code": -32601, "message": "method not found"}})
	}
}

func writeJSONRPC(w http.ResponseWriter, res jsonrpc.Response) {
	w.Header().Set("content-type", "application/json")
	if err := json.NewEncoder(w).Encode(res); err != nil {
		http.Error(w, "failed to encode response", http.StatusInternalServerError)
	}
}

func envOrDefault(name string, fallback string) string {
	if value := os.Getenv(name); value != "" {
		return value
	}
	return fallback
}
