# Stage 1: Build the Go Binary
FROM golang:1.23-alpine AS builder
WORKDIR /app

# Install git (sometimes needed for dependencies)
RUN apk add --no-cache git

# Handle dependencies
COPY go.mod ./
# (Uncomment the next line if you have generated a go.sum file)
# COPY go.sum ./
RUN go mod download

# Copy Source and Build
COPY . .
# CGO_ENABLED=0 creates a static binary (no external C libraries needed)
# We name the binary 'server' for consistency across all your containers
RUN CGO_ENABLED=0 GOOS=linux go build -o server main.go

# Stage 2: The Final Image
FROM alpine:latest
WORKDIR /root/

# Copy only the compiled binary from Stage 1
COPY --from=builder /app/server .

# Expose the internal port
EXPOSE 8080

# Run it
CMD ["./server"]