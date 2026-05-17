FROM golang:1.23-alpine AS builder
WORKDIR /src
COPY go.mod go.sum ./
COPY gen ./gen
COPY turing-backend/mcp-files/go.mod turing-backend/mcp-files/go.sum ./turing-backend/mcp-files/
WORKDIR /src/turing-backend/mcp-files
RUN go mod download
COPY turing-backend/mcp-files ./
RUN CGO_ENABLED=0 GOOS=linux go build -o /server ./cmd/server

FROM alpine:3.20
WORKDIR /app
COPY --from=builder /server ./server
EXPOSE 7110
CMD ["./server"]
