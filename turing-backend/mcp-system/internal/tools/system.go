package tools

import (
	"errors"
	"runtime"
	"time"
)

func List() []map[string]any {
	return []map[string]any{
		{"name": "system.health", "policy": "safe"},
		{"name": "system.time", "policy": "safe"},
		{"name": "system.echo", "policy": "safe"},
		{"name": "system.info", "policy": "safe"},
	}
}

func Call(name string, args map[string]any) (map[string]any, error) {
	switch name {
	case "system.health":
		return map[string]any{"ok": true, "service": "turing-mcp-system"}, nil
	case "system.time":
		now := time.Now().UTC()
		return map[string]any{"iso": now.Format(time.RFC3339Nano), "unixMs": now.UnixMilli(), "timezone": "UTC"}, nil
	case "system.echo":
		text, _ := args["text"].(string)
		return map[string]any{"text": text}, nil
	case "system.info":
		return map[string]any{"os": runtime.GOOS, "arch": runtime.GOARCH, "runtime": runtime.Version()}, nil
	default:
		return nil, errors.New("unknown tool")
	}
}
