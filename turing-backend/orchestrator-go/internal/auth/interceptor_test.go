package auth

import (
	"context"
	"testing"

	"google.golang.org/grpc/metadata"
)

func TestTokenFromMetadata(t *testing.T) {
	ctx := metadata.NewIncomingContext(context.Background(), metadata.Pairs("authorization", "Bearer secret"))
	got, ok := TokenFromMetadata(ctx)
	if !ok || got != "secret" {
		t.Fatalf("TokenFromMetadata = %q/%v", got, ok)
	}
}

func TestConstantTimeTokenMatch(t *testing.T) {
	if !TokenMatches("secret", "secret") {
		t.Fatal("same token did not match")
	}
	if TokenMatches("secret", "different") {
		t.Fatal("different tokens matched")
	}
}
