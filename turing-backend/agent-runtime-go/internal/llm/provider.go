package llm

import "context"

type ChatMessage struct {
	Role    string
	Content string
}

type ChatRequest struct {
	Model       string
	Messages    []ChatMessage
	Temperature float64
	MaxTokens   int
}

type StreamEvent struct {
	Type         string
	Text         string
	FinishReason string
	Code         string
	Message      string
}

type Provider interface {
	ID() string
	StreamChat(ctx context.Context, req ChatRequest) (<-chan StreamEvent, error)
}
