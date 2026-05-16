package ids

import (
	"strings"
	"testing"
)

func TestNewPrefixedID(t *testing.T) {
	got := New("run")
	if !strings.HasPrefix(got, "run_") {
		t.Fatalf("id %q missing prefix", got)
	}
	if len(got) <= len("run_") {
		t.Fatalf("id %q too short", got)
	}
}
