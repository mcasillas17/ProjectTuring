package approval

import (
	"crypto/hmac"
	"crypto/sha256"
	"encoding/base64"
	"encoding/hex"
	"encoding/json"
	"net/http"
	"testing"
	"time"
)

func TestValidateChecksClaimsAndConsumesOnce(t *testing.T) {
	consumeCount := 0
	consumer := Consumer{
		OrchestratorBaseURL: "http://orchestrator/internal",
		InternalToken:       "internal",
		JWTSecret:           "secret",
		HTTPClient: &http.Client{Transport: roundTripFunc(func(req *http.Request) (*http.Response, error) {
			consumeCount++
			if req.URL.Path != "/internal/approvals/appr_1/consume" || req.Header.Get("Authorization") != "Bearer internal" {
				t.Fatalf("unexpected consume request: %s %s", req.Method, req.URL.Path)
			}
			return &http.Response{StatusCode: http.StatusOK, Body: http.NoBody}, nil
		})},
	}
	args := map[string]any{"content": "hello", "path": "note.txt"}
	token := signTestToken(t, "secret", Claims{Sub: "general_assistant", Aud: "mcp-files", JTI: "appr_1", Tool: "files.create", ArgsHash: hashArgs(t, args), Exp: time.Now().Add(time.Minute).Unix(), Iat: time.Now().Unix()})

	if err := consumer.Validate(token, "files.create", args, "general_assistant"); err != nil {
		t.Fatalf("expected valid approval: %v", err)
	}
	if consumeCount != 1 {
		t.Fatalf("expected one consume call, got %d", consumeCount)
	}
}

func TestValidateRejectsMismatchedApprovalBinding(t *testing.T) {
	args := map[string]any{"content": "hello", "path": "note.txt"}
	base := Claims{Sub: "general_assistant", Aud: "mcp-files", JTI: "appr_1", Tool: "files.create", ArgsHash: hashArgs(t, args), Exp: time.Now().Add(time.Minute).Unix(), Iat: time.Now().Unix()}
	cases := []struct {
		name   string
		claims Claims
		tool   string
		args   map[string]any
		agent  string
	}{
		{"audience", withClaim(base, func(c *Claims) { c.Aud = "other" }), "files.create", args, "general_assistant"},
		{"subject", withClaim(base, func(c *Claims) { c.Sub = "other_agent" }), "files.create", args, "general_assistant"},
		{"tool", withClaim(base, func(c *Claims) { c.Tool = "files.update" }), "files.create", args, "general_assistant"},
		{"args_hash", base, "files.create", map[string]any{"content": "changed", "path": "note.txt"}, "general_assistant"},
	}
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			consumer := Consumer{OrchestratorBaseURL: "http://orchestrator/internal", InternalToken: "internal", JWTSecret: "secret", HTTPClient: &http.Client{Transport: roundTripFunc(func(req *http.Request) (*http.Response, error) {
				t.Fatalf("consume must not be called for invalid binding")
				return nil, nil
			})}}
			if err := consumer.Validate(signTestToken(t, "secret", tc.claims), tc.tool, tc.args, tc.agent); err == nil {
				t.Fatalf("expected validation failure")
			}
		})
	}
}

func TestValidateRejectsConsumeReplayConflict(t *testing.T) {
	args := map[string]any{"content": "hello", "path": "note.txt"}
	consumer := Consumer{OrchestratorBaseURL: "http://orchestrator/internal", InternalToken: "internal", JWTSecret: "secret", HTTPClient: &http.Client{Transport: roundTripFunc(func(req *http.Request) (*http.Response, error) {
		return &http.Response{StatusCode: http.StatusConflict, Body: http.NoBody}, nil
	})}}
	token := signTestToken(t, "secret", Claims{Sub: "general_assistant", Aud: "mcp-files", JTI: "appr_1", Tool: "files.create", ArgsHash: hashArgs(t, args), Exp: time.Now().Add(time.Minute).Unix(), Iat: time.Now().Unix()})
	if err := consumer.Validate(token, "files.create", args, "general_assistant"); err == nil {
		t.Fatalf("expected replay/consume conflict")
	}
}

func TestCanonicalArgsHashMatchesTypeScriptFixture(t *testing.T) {
	if got := hashArgs(t, map[string]any{"B": float64(1), "a": float64(2)}); got != "sha256:812e5e7fb7bb816dc477e91a136430192eadcf83ff303881298146e106ae0161" {
		t.Fatalf("unexpected canonical hash %s", got)
	}
}

type roundTripFunc func(*http.Request) (*http.Response, error)

func (f roundTripFunc) RoundTrip(req *http.Request) (*http.Response, error) {
	return f(req)
}

func signTestToken(t *testing.T, secret string, claims Claims) string {
	t.Helper()
	header := base64.RawURLEncoding.EncodeToString([]byte(`{"alg":"HS256","typ":"JWT"}`))
	payloadBytes, err := json.Marshal(claims)
	if err != nil {
		t.Fatal(err)
	}
	payload := base64.RawURLEncoding.EncodeToString(payloadBytes)
	input := header + "." + payload
	mac := hmac.New(sha256.New, []byte(secret))
	mac.Write([]byte(input))
	return input + "." + base64.RawURLEncoding.EncodeToString(mac.Sum(nil))
}

func hashArgs(t *testing.T, args map[string]any) string {
	t.Helper()
	canonical, err := canonicalJSON(args)
	if err != nil {
		t.Fatal(err)
	}
	sum := sha256.Sum256([]byte(canonical))
	return "sha256:" + hex.EncodeToString(sum[:])
}

func withClaim(claims Claims, mutate func(*Claims)) Claims {
	mutate(&claims)
	return claims
}
