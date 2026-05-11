package tools

import "testing"

func TestCallSystemTime(t *testing.T) {
	result, err := Call("system.time", map[string]any{"timezone": "UTC"})
	if err != nil {
		t.Fatalf("Call returned error: %v", err)
	}
	if result["iso"] == "" {
		t.Fatalf("expected iso timestamp")
	}
}

func TestSystemInfoDoesNotExposeSecrets(t *testing.T) {
	result, err := Call("system.info", map[string]any{})
	if err != nil {
		t.Fatalf("Call returned error: %v", err)
	}
	if _, ok := result["env"]; ok {
		t.Fatalf("system.info must not expose env")
	}
}
