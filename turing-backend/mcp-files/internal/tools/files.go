package tools

import (
	"bytes"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"errors"
	"os"
	"path/filepath"
	"strings"
	"unicode/utf8"
)

const defaultReadBytes = 64 * 1024
const maxReadBytes = 512 * 1024
const defaultSearchResults = 50
const maxSearchResults = 200

type ApprovalValidator interface {
	Validate(token string, tool string, args map[string]any, agentID string) error
}

type FilesTools struct {
	root      string
	validator ApprovalValidator
}

func NewFilesTools(root string) FilesTools {
	abs, _ := filepath.Abs(root)
	// Canonicalize the sandbox root so that EvalSymlinks-based path checks
	// compare like-for-like on systems where the tmp/parent path traverses a
	// symlink (e.g. macOS, where /var is a symlink to /private/var).
	if real, err := filepath.EvalSymlinks(abs); err == nil {
		abs = real
	}
	return FilesTools{root: abs}
}

func (f FilesTools) WithApprovalValidator(validator ApprovalValidator) FilesTools {
	f.validator = validator
	return f
}

func (f FilesTools) resolve(input string) (string, error) {
	clean := filepath.Clean(strings.TrimPrefix(input, "/"))
	full := filepath.Join(f.root, clean)
	existing := full
	missing := []string{}
	for {
		if _, err := os.Lstat(existing); err == nil {
			break
		}
		parent := filepath.Dir(existing)
		if parent == existing {
			return "", errors.New("path escapes sandbox")
		}
		missing = append([]string{filepath.Base(existing)}, missing...)
		existing = parent
	}
	resolvedExisting, err := filepath.EvalSymlinks(existing)
	if err != nil {
		return "", err
	}
	resolved := filepath.Join(append([]string{resolvedExisting}, missing...)...)
	rel, err := filepath.Rel(f.root, resolved)
	if err != nil || strings.HasPrefix(rel, "..") || filepath.IsAbs(rel) {
		return "", errors.New("path escapes sandbox")
	}
	return resolved, nil
}

func (f FilesTools) Read(args map[string]any) (map[string]any, error) {
	pathValue, _ := args["path"].(string)
	limit := readLimit(args)
	full, err := f.resolve(pathValue)
	if err != nil {
		return nil, err
	}
	info, err := os.Stat(full)
	if err != nil {
		return nil, err
	}
	if info.Size() > maxReadBytes {
		return nil, errors.New("file too large")
	}
	content, err := os.ReadFile(full)
	if err != nil {
		return nil, err
	}
	if !utf8.Valid(content) {
		return nil, errors.New("unsupported media type")
	}
	truncated := len(content) > limit
	if truncated {
		content = content[:limit]
		for !utf8.Valid(content) && len(content) > 0 {
			content = content[:len(content)-1]
		}
	}
	return map[string]any{"path": pathValue, "content": string(content), "truncated": truncated}, nil
}

func (f FilesTools) List(args map[string]any) (map[string]any, error) {
	pathValue, _ := args["path"].(string)
	full, err := f.resolve(pathValue)
	if err != nil {
		return nil, err
	}
	entries, err := os.ReadDir(full)
	if err != nil {
		return nil, err
	}
	items := []map[string]any{}
	for _, entry := range entries {
		items = append(items, map[string]any{"name": entry.Name(), "isDir": entry.IsDir()})
	}
	return map[string]any{"items": items}, nil
}

func (f FilesTools) Search(args map[string]any) (map[string]any, error) {
	pathValue, _ := args["path"].(string)
	query, _ := args["query"].(string)
	if query == "" {
		return nil, errors.New("query is required")
	}
	limit := searchLimit(args)
	full, err := f.resolve(pathValue)
	if err != nil {
		return nil, err
	}
	matches := []map[string]any{}
	err = filepath.WalkDir(full, func(path string, entry os.DirEntry, walkErr error) error {
		if walkErr != nil || entry.IsDir() {
			return nil
		}
		if entry.Type()&os.ModeSymlink != 0 {
			return nil
		}
		if len(matches) >= limit {
			return filepath.SkipAll
		}
		resolved, err := filepath.EvalSymlinks(path)
		if err != nil {
			return nil
		}
		rel, err := filepath.Rel(f.root, resolved)
		if err != nil || strings.HasPrefix(rel, "..") || filepath.IsAbs(rel) {
			return nil
		}
		info, err := entry.Info()
		if err != nil || info.Size() > maxReadBytes {
			return nil
		}
		content, err := os.ReadFile(resolved)
		if err != nil {
			return nil
		}
		if !utf8.Valid(content) {
			return nil
		}
		text := string(content)
		if strings.Contains(text, query) {
			matches = append(matches, map[string]any{"path": rel, "snippet": firstSnippet(text, query)})
		}
		return nil
	})
	return map[string]any{"matches": matches}, err
}

func (f FilesTools) Create(args map[string]any, approvalToken string, agentID string) (map[string]any, error) {
	if err := f.validateApproval("files.create", args, approvalToken, agentID); err != nil {
		return nil, err
	}
	pathValue, _ := args["path"].(string)
	content, _ := args["content"].(string)
	full, err := f.resolve(pathValue)
	if err != nil {
		return nil, err
	}
	if _, err := os.Stat(full); err == nil {
		return nil, errors.New("file already exists")
	}
	if err := os.MkdirAll(filepath.Dir(full), 0700); err != nil {
		return nil, err
	}
	if err := os.WriteFile(full, []byte(content), 0600); err != nil {
		return nil, err
	}
	return map[string]any{"path": pathValue, "sha256": contentHash(content)}, nil
}

func (f FilesTools) Update(args map[string]any, approvalToken string, agentID string) (map[string]any, error) {
	if err := f.validateApproval("files.update", args, approvalToken, agentID); err != nil {
		return nil, err
	}
	pathValue, _ := args["path"].(string)
	content, _ := args["content"].(string)
	full, err := f.resolve(pathValue)
	if err != nil {
		return nil, err
	}
	if expectedHash, ok := args["expectedHash"].(string); ok && expectedHash != "" {
		current, err := os.ReadFile(full)
		if err != nil {
			return nil, err
		}
		if contentHash(string(current)) != expectedHash {
			return nil, errors.New("expectedHash mismatch")
		}
	}
	if err := os.WriteFile(full, []byte(content), 0600); err != nil {
		return nil, err
	}
	return map[string]any{"path": pathValue, "sha256": contentHash(content)}, nil
}

func (f FilesTools) Call(name string, args map[string]any, approvalToken string, agentID string) (map[string]any, error) {
	switch name {
	case "files.list":
		return f.List(args)
	case "files.search":
		return f.Search(args)
	case "files.read":
		return f.Read(args)
	case "files.create":
		return f.Create(args, approvalToken, agentID)
	case "files.update":
		return f.Update(args, approvalToken, agentID)
	case "files.delete", "files.move":
		return nil, errors.New("tool disabled")
	default:
		return nil, errors.New("unknown tool")
	}
}

func (f FilesTools) validateApproval(tool string, args map[string]any, approvalToken string, agentID string) error {
	if f.validator == nil {
		return errors.New("approval validator not configured")
	}
	if approvalToken == "" {
		return errors.New("approval token required")
	}
	return f.validator.Validate(approvalToken, tool, args, agentID)
}

func readLimit(args map[string]any) int {
	if value, ok := args["maxBytes"].(float64); ok && value > 0 {
		if int(value) > maxReadBytes {
			return maxReadBytes
		}
		return int(value)
	}
	return defaultReadBytes
}

func searchLimit(args map[string]any) int {
	if value, ok := args["limit"].(float64); ok && value > 0 {
		if int(value) > maxSearchResults {
			return maxSearchResults
		}
		return int(value)
	}
	return defaultSearchResults
}

func firstSnippet(text string, query string) string {
	index := strings.Index(text, query)
	if index < 0 {
		return ""
	}
	start := index - 40
	if start < 0 {
		start = 0
	}
	end := index + len(query) + 40
	if end > len(text) {
		end = len(text)
	}
	return text[start:end]
}

func contentHash(content string) string {
	sum := sha256.Sum256([]byte(content))
	return "sha256:" + hex.EncodeToString(sum[:])
}

func CanonicalArgsHash(args map[string]any) (string, error) {
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
