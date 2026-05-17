package config

import "testing"

func TestLoadFromEnvDoesNotUseLegacyHTTPOrchestratorBaseURL(t *testing.T) {
	cfg, err := LoadFromEnv(mapEnv(map[string]string{
		"TURING_INTERNAL_TOKEN":          "internal",
		"ORCHESTRATOR_INTERNAL_BASE_URL": "http://legacy-orchestrator:3001/internal",
	}))
	if err != nil {
		t.Fatalf("LoadFromEnv failed: %v", err)
	}
	if cfg.OrchestratorGRPCAddr != "turing-orchestrator:3001" {
		t.Fatalf("expected default gRPC address without legacy HTTP fallback, got %q", cfg.OrchestratorGRPCAddr)
	}
}

func TestLoadFromEnvUsesExplicitOrchestratorGRPCAddress(t *testing.T) {
	cfg, err := LoadFromEnv(mapEnv(map[string]string{
		"TURING_INTERNAL_TOKEN":  "internal",
		"ORCHESTRATOR_GRPC_ADDR": "orchestrator.internal:3001",
	}))
	if err != nil {
		t.Fatalf("LoadFromEnv failed: %v", err)
	}
	if cfg.OrchestratorGRPCAddr != "orchestrator.internal:3001" {
		t.Fatalf("expected explicit gRPC address, got %q", cfg.OrchestratorGRPCAddr)
	}
}

func mapEnv(values map[string]string) func(string) string {
	return func(name string) string {
		return values[name]
	}
}
