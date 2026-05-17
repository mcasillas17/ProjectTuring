package llm

import (
	"context"
	"fmt"
	"net/http"
	"net/http/httptest"
	"testing"
)

func TestOpenAICompatibleStreamChatParsesSSEDeltaAndCompletion(t *testing.T) {
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("content-type", "text/event-stream")
		fmt.Fprint(w, `data: {"choices":[{"delta":{"content":"Hi"}}]}`+"\n\n")
		fmt.Fprint(w, "data: [DONE]\n\n")
	}))
	t.Cleanup(server.Close)
	provider := NewOpenAICompatible(server.URL, "test-key", server.Client())
	events, err := provider.StreamChat(context.Background(), ChatRequest{Model: "gpt-4o-mini", Messages: []ChatMessage{{Role: "user", Content: "hi"}}})
	if err != nil {
		t.Fatal(err)
	}
	got := collectEvents(events)
	if got[0].Text != "Hi" || got[1].Type != "completed" {
		t.Fatalf("events = %+v", got)
	}
}
