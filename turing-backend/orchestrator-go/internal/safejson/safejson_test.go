package safejson

import (
	"encoding/json"
	"math"
	"strings"
	"testing"
)

func TestDecodeObjectUsesNumber(t *testing.T) {
	dec := json.NewDecoder(strings.NewReader(`{"count":9007199254740993}`))
	got, err := DecodeObject(dec)
	if err != nil {
		t.Fatalf("DecodeObject returned error: %v", err)
	}
	if _, ok := got["count"].(json.Number); !ok {
		t.Fatalf("count type = %T, want json.Number", got["count"])
	}
}

func TestNormalizeRejectsNaN(t *testing.T) {
	_, err := Normalize(map[string]any{"bad": math.NaN()})
	if err == nil {
		t.Fatal("expected NaN rejection")
	}
}

func TestToStructConvertsObject(t *testing.T) {
	got, err := ToStruct(map[string]any{"ok": true, "nested": map[string]any{"value": "x"}})
	if err != nil {
		t.Fatalf("ToStruct returned error: %v", err)
	}
	if !got.Fields["ok"].GetBoolValue() {
		t.Fatal("ok field was not true")
	}
}

func TestSummaryLimitsBytes(t *testing.T) {
	got := Summary(map[string]any{"value": strings.Repeat("a", 100)}, 20)
	if len(got) > 20 {
		t.Fatalf("summary length = %d, want <= 20", len(got))
	}
}
