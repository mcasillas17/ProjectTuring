package auth

import (
	"context"
	"crypto/subtle"
	"strings"

	"google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/metadata"
	"google.golang.org/grpc/status"
)

func TokenFromMetadata(ctx context.Context) (string, bool) {
	md, ok := metadata.FromIncomingContext(ctx)
	if !ok {
		return "", false
	}
	values := md.Get("authorization")
	if len(values) == 0 {
		return "", false
	}
	raw := values[0]
	if !strings.HasPrefix(raw, "Bearer ") {
		return "", false
	}
	token := strings.TrimPrefix(raw, "Bearer ")
	return token, token != ""
}

func TokenMatches(got, want string) bool {
	if got == "" || want == "" {
		return false
	}
	return subtle.ConstantTimeCompare([]byte(got), []byte(want)) == 1
}

func UnaryInterceptor(requiredToken string) grpc.UnaryServerInterceptor {
	return func(ctx context.Context, req any, info *grpc.UnaryServerInfo, handler grpc.UnaryHandler) (any, error) {
		token, ok := TokenFromMetadata(ctx)
		if !ok || !TokenMatches(token, requiredToken) {
			return nil, status.Error(codes.Unauthenticated, "invalid bearer token")
		}
		return handler(ctx, req)
	}
}

func StreamInterceptor(requiredToken string) grpc.StreamServerInterceptor {
	return func(srv any, stream grpc.ServerStream, info *grpc.StreamServerInfo, handler grpc.StreamHandler) error {
		token, ok := TokenFromMetadata(stream.Context())
		if !ok || !TokenMatches(token, requiredToken) {
			return status.Error(codes.Unauthenticated, "invalid bearer token")
		}
		return handler(srv, stream)
	}
}
