package main

import (
	"encoding/json"
	"log"
	"net/http"
	"os"

	"github.com/project-turing/mcp-files/internal/approval"
	"github.com/project-turing/mcp-files/internal/auth"
	"github.com/project-turing/mcp-files/internal/jsonrpc"
	"github.com/project-turing/mcp-files/internal/tools"
)

type serverConfig struct {
	filesToken          string
	approvalJwtSecret   string
	orchestratorBaseURL string
	internalToken       string
	sandboxRoot         string
}

func main() {
	cfg := loadConfig()
	if err := os.MkdirAll(cfg.sandboxRoot, 0700); err != nil {
		log.Fatal(err)
	}

	addr := ":" + envOrDefault("PORT", "7110")
	log.Printf("starting mcp-files on %s", addr)
	if err := http.ListenAndServe(addr, newHandler(cfg)); err != nil {
		log.Fatal(err)
	}
}

func loadConfig() serverConfig {
	return serverConfig{
		filesToken:          os.Getenv("MCP_FILES_TOKEN_GENERAL"),
		approvalJwtSecret:   os.Getenv("TURING_APPROVAL_JWT_SECRET"),
		orchestratorBaseURL: envOrDefault("ORCHESTRATOR_INTERNAL_BASE_URL", "http://turing-orchestrator:3001/internal"),
		internalToken:       os.Getenv("TURING_INTERNAL_TOKEN"),
		sandboxRoot:         envOrDefault("FILES_SANDBOX_ROOT", "/sandbox"),
	}
}

func newHandler(cfg serverConfig) http.Handler {
	mux := http.NewServeMux()
	filesTools := tools.NewFilesTools(cfg.sandboxRoot).WithApprovalValidator(approval.Consumer{
		OrchestratorBaseURL: cfg.orchestratorBaseURL,
		InternalToken:       cfg.internalToken,
		JWTSecret:           cfg.approvalJwtSecret,
	})
	mux.Handle("/mcp", http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		agentID, err := auth.AgentFromBearer(r, cfg.filesToken)
		if err != nil {
			http.Error(w, "unauthorized", http.StatusUnauthorized)
			return
		}
		handleMCP(w, r, filesTools, agentID)
	}))
	return mux
}

func handleMCP(w http.ResponseWriter, r *http.Request, filesTools tools.FilesTools, agentID string) {
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
		writeJSONRPC(w, jsonrpc.Response{JSONRPC: "2.0", ID: req.ID, Result: map[string]any{"tools": listTools()}})
	case "tools/call":
		name, _ := req.Params["name"].(string)
		args, _ := req.Params["arguments"].(map[string]any)
		if args == nil {
			args = map[string]any{}
		}
		approvalToken := approvalTokenFromParams(req.Params)
		result, err := filesTools.Call(name, args, approvalToken, agentID)
		if err != nil {
			writeJSONRPC(w, jsonrpc.Response{JSONRPC: "2.0", ID: req.ID, Error: map[string]any{"code": -32000, "message": err.Error()}})
			return
		}
		writeJSONRPC(w, jsonrpc.Response{JSONRPC: "2.0", ID: req.ID, Result: result})
	default:
		writeJSONRPC(w, jsonrpc.Response{JSONRPC: "2.0", ID: req.ID, Error: map[string]any{"code": -32601, "message": "method not found"}})
	}
}

func listTools() []map[string]any {
	return []map[string]any{
		{"name": "files.list", "policy": "safe"},
		{"name": "files.search", "policy": "safe"},
		{"name": "files.read", "policy": "safe"},
		{"name": "files.create", "policy": "approval_required"},
		{"name": "files.update", "policy": "approval_required"},
		{"name": "files.delete", "policy": "disabled"},
		{"name": "files.move", "policy": "disabled"},
	}
}

func approvalTokenFromParams(params map[string]any) string {
	meta, _ := params["_meta"].(map[string]any)
	token, _ := meta["approvalToken"].(string)
	return token
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
