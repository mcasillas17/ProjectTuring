package tools

import "testing"

func TestPolicyForKnownTools(t *testing.T) {
	cases := map[string]Policy{
		"system.time":  PolicySafe,
		"system.echo":  PolicySafe,
		"files.create": PolicyApprovalRequired,
		"files.update": PolicyApprovalRequired,
	}
	for name, want := range cases {
		got, ok := GetPolicy(name)
		if !ok || got != want {
			t.Fatalf("GetPolicy(%q) = %q/%v, want %q/true", name, got, ok, want)
		}
	}
}

func TestUnknownToolHasNoPolicy(t *testing.T) {
	if _, ok := GetPolicy("system.shell"); ok {
		t.Fatal("unknown tool should not have a policy")
	}
}
