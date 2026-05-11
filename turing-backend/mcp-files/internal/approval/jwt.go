package approval

import (
	"bytes"
	"crypto/hmac"
	"crypto/sha256"
	"encoding/base64"
	"encoding/hex"
	"encoding/json"
	"errors"
	"fmt"
	"net/http"
	"strings"
	"time"
)

type Claims struct {
	Iss      string `json:"iss"`
	Sub      string `json:"sub"`
	Aud      string `json:"aud"`
	JTI      string `json:"jti"`
	Tool     string `json:"tool"`
	ArgsHash string `json:"args_hash"`
	Exp      int64  `json:"exp"`
	Iat      int64  `json:"iat"`
}

func VerifyHS256(token string, secret string) (Claims, error) {
	parts := strings.Split(token, ".")
	if len(parts) != 3 {
		return Claims{}, errors.New("invalid token")
	}
	headerBytes, err := base64.RawURLEncoding.DecodeString(parts[0])
	if err != nil {
		return Claims{}, err
	}
	var header struct {
		Alg string `json:"alg"`
		Typ string `json:"typ"`
	}
	if err := json.Unmarshal(headerBytes, &header); err != nil {
		return Claims{}, err
	}
	if header.Alg != "HS256" {
		return Claims{}, errors.New("invalid token algorithm")
	}
	signingInput := parts[0] + "." + parts[1]
	mac := hmac.New(sha256.New, []byte(secret))
	mac.Write([]byte(signingInput))
	expected := base64.RawURLEncoding.EncodeToString(mac.Sum(nil))
	if !hmac.Equal([]byte(expected), []byte(parts[2])) {
		return Claims{}, errors.New("invalid signature")
	}
	payload, err := base64.RawURLEncoding.DecodeString(parts[1])
	if err != nil {
		return Claims{}, err
	}
	var claims Claims
	if err := json.Unmarshal(payload, &claims); err != nil {
		return Claims{}, err
	}
	if claims.Exp < time.Now().Unix() {
		return Claims{}, errors.New("token expired")
	}
	return claims, nil
}

type Consumer struct {
	OrchestratorBaseURL string
	InternalToken       string
	JWTSecret           string
	HTTPClient          *http.Client
}

func (c Consumer) Validate(token string, tool string, args map[string]any, agentID string) error {
	claims, err := VerifyHS256(token, c.JWTSecret)
	if err != nil {
		return err
	}
	if claims.Aud != "mcp-files" {
		return errors.New("invalid approval audience")
	}
	if claims.Sub != agentID {
		return errors.New("approval subject does not match agent")
	}
	if claims.Tool != tool {
		return errors.New("approval tool does not match call")
	}
	argsHash, err := canonicalArgsHash(args)
	if err != nil {
		return err
	}
	if claims.ArgsHash != argsHash {
		return errors.New("approval args_hash does not match call")
	}
	return c.consume(claims.JTI)
}

func (c Consumer) consume(jti string) error {
	client := c.HTTPClient
	if client == nil {
		client = http.DefaultClient
	}
	req, err := http.NewRequest(http.MethodPost, fmt.Sprintf("%s/approvals/%s/consume", strings.TrimRight(c.OrchestratorBaseURL, "/"), jti), nil)
	if err != nil {
		return err
	}
	req.Header.Set("Authorization", "Bearer "+c.InternalToken)
	resp, err := client.Do(req)
	if err != nil {
		return err
	}
	defer resp.Body.Close()
	if resp.StatusCode == http.StatusOK {
		return nil
	}
	if resp.StatusCode == http.StatusConflict {
		return errors.New("approval already consumed or not approved")
	}
	return fmt.Errorf("approval consume failed: HTTP %d", resp.StatusCode)
}

func canonicalArgsHash(args map[string]any) (string, error) {
	canonical, err := canonicalJSON(args)
	if err != nil {
		return "", err
	}
	sum := sha256.Sum256([]byte(canonical))
	return "sha256:" + hex.EncodeToString(sum[:]), nil
}

func canonicalJSON(args map[string]any) (string, error) {
	var buffer bytes.Buffer
	encoder := json.NewEncoder(&buffer)
	encoder.SetEscapeHTML(false)
	if err := encoder.Encode(args); err != nil {
		return "", err
	}
	return strings.TrimSuffix(buffer.String(), "\n"), nil
}
