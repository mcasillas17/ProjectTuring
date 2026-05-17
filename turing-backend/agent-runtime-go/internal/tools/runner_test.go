package tools

import (
	"context"
	"errors"
	"testing"

	turingv1 "github.com/mcasillas17/TuringAgent/gen/turing/v1/go/turing/v1"
)

func TestRunPostsFailureAfterWhenPolicyDecisionWaitFailsAfterBeforeSent(t *testing.T) {
	waitErr := beaconPostedTestError{err: context.Canceled}
	var beacons []*turingv1.ToolCallBeacon
	runner := &Runner{
		PostBeacon: func(ctx context.Context, beacon *turingv1.ToolCallBeacon) (*turingv1.ToolPolicyDecision, error) {
			beacons = append(beacons, beacon)
			if beacon.GetPhase() == turingv1.ToolCallPhase_TOOL_CALL_PHASE_BEFORE {
				return nil, waitErr
			}
			return &turingv1.ToolPolicyDecision{Decision: turingv1.ToolPolicyDecision_DECISION_ALLOW, ToolCallId: beacon.GetToolCallId()}, nil
		},
	}

	_, err := runner.Run(context.Background(), RunInput{
		AgentID:    turingv1.AgentId_AGENT_ID_GENERAL_ASSISTANT,
		RunID:      "run_1",
		TraceID:    "trace_1",
		ServerName: "system",
		ToolName:   "system.echo",
		MCPClient:  fakeMCPClient{},
	})

	if !errors.Is(err, context.Canceled) {
		t.Fatalf("Run error = %v, want context.Canceled", err)
	}
	if len(beacons) != 2 {
		t.Fatalf("beacons = %d, want before and failure after", len(beacons))
	}
	if beacons[1].GetPhase() != turingv1.ToolCallPhase_TOOL_CALL_PHASE_AFTER || beacons[1].GetStatus() != turingv1.ToolCallStatus_TOOL_CALL_STATUS_FAILED {
		t.Fatalf("after beacon = %+v, want failed after beacon", beacons[1])
	}
	if beacons[1].GetError().GetCode() != "tool_policy_decision_failed" {
		t.Fatalf("after error = %+v, want tool_policy_decision_failed", beacons[1].GetError())
	}
	if beacons[1].GetToolCallId() != beacons[0].GetToolCallId() {
		t.Fatalf("after tool_call_id = %q, want %q", beacons[1].GetToolCallId(), beacons[0].GetToolCallId())
	}
}

type beaconPostedTestError struct {
	err error
}

func (e beaconPostedTestError) Error() string { return e.err.Error() }
func (e beaconPostedTestError) Unwrap() error { return e.err }
func (e beaconPostedTestError) BeaconPosted() bool {
	return true
}

type fakeMCPClient struct{}

func (fakeMCPClient) CallTool(ctx context.Context, name string, args map[string]any, approvalToken ...string) (map[string]any, error) {
	return map[string]any{"ok": true}, nil
}
