# TuringAgent

TuringAgent is a local-first personal AI orchestration platform. It coordinates a Flutter client with a Go gRPC orchestrator that manages sessions, agent runs, runtime events, and MCP tool calls.

## TuringAgent v1.0 local runtime

> **Status:** v1.0 foundation is integrated on `pturing-v1-base`. The local stack includes the Go orchestrator, SQLite persistence, the Go general agent runtime, Go MCP servers, Ollama routing, public gRPC streaming, and the Flutter client shell.

### Prerequisites

- **Docker and Docker Compose**: Required for running the orchestrator, agent runtime, and MCP servers.
- **Go 1.23+**: Required for local Go tests and the gRPC smoke client.
- **Ollama**: Must be running on your host machine for model-backed chat. TuringAgent expects Ollama to be reachable at `http://host.docker.internal:11434` from within Docker.
- **Flutter**: Required for building and running the client application.

### Backend setup

Initialize local secrets and start the full v1 backend stack:

```bash
cd turing-backend
./scripts/init.sh
./scripts/dev.sh
```

`init.sh` creates `.env`, generates local-only secrets, creates `data/` and
`sandbox/`, and prints `TURING_CLIENT_API_KEY`. Save that key for local clients.
`dev.sh` runs `docker compose -f infra/docker-compose.yml up --build`.

The default Compose stack starts:

| Service | Purpose | Network exposure |
|---|---|---|
| `turing-orchestrator` | Public gRPC API, internal runtime gRPC API, SQLite persistence | Publishes gRPC port `3000`; exposes internal gRPC port `3001` only to Docker networks |
| `turing-agent-runtime-general` | Connects to the orchestrator over internal gRPC, calls model providers, streams runtime events back to the orchestrator | Internal Docker networks only |
| `turing-mcp-system` | Safe system MCP tools | Internal `net-system` network only |
| `turing-mcp-files` | Sandboxed file MCP tools with approval-gated writes | Internal `net-files` network only |

Important `.env` values:

| Variable | Purpose |
|---|---|
| `TURING_CLIENT_API_KEY` | Bearer token for public gRPC clients |
| `TURING_INTERNAL_TOKEN` | Bearer token for orchestrator internal gRPC APIs and MCP approval consumption |
| `MCP_SYSTEM_TOKEN_GENERAL` / `MCP_FILES_TOKEN_GENERAL` | Per-server runtime-to-MCP bearer tokens |
| `TURING_APPROVAL_JWT_SECRET` | HS256 signing secret shared by the orchestrator and Files MCP server |
| `ORCHESTRATOR_GRPC_ADDR` | Internal runtime gRPC address, normally `turing-orchestrator:3001` |
| `FILES_SANDBOX_ROOT` | Files MCP sandbox root inside the container, normally `/sandbox` |
| `OLLAMA_BASE_URL` / `OLLAMA_MODEL` | Local model endpoint and default model |

Public gRPC calls must include metadata:

```text
authorization: Bearer <TURING_CLIENT_API_KEY>
```

For approval-gated filesystem writes, the orchestrator creates approval records,
signs a short-lived JWT after user approval, and the Files MCP server validates
and consumes that approval before touching disk. See the [MCP Security and
Integration Guide](docs/mcp-security-and-integration.md) for the full flow.

### Smoke Testing

Run the end-to-end gRPC smoke path after Docker is available:

```bash
cd turing-backend
./scripts/smoke-grpc.sh
```

The smoke script initializes secrets, builds and starts the Compose stack, checks
`HealthService.Check`, creates a session, calls `ChatService.SendMessage`, waits
for a token delta plus a terminal run event, and verifies replay with
`EventService.ListEvents(after_sequence = 0)`.

Script syntax/build checks:

```bash
bash -n turing-backend/scripts/smoke-grpc.sh
cd turing-backend && go run ./scripts/grpc-smoke-client.go -health-only
```

#### Full `smoke-grpc.sh` flow:

1. **Initialization**: Runs `./scripts/init.sh` to create local secrets.
2. **Orchestration**: Uses `docker compose -f infra/docker-compose.yml up --build -d` to ensure a clean, up-to-date environment.
3. **Health Check**: Polls public gRPC `HealthService.Check` on `localhost:${ORCHESTRATOR_PUBLIC_PORT:-3000}`.
4. **gRPC Validation**:
   - Creates a test session with `SessionService.CreateSession`.
   - Sends a deterministic `/tool system.time` message with `ChatService.SendMessage`.
   - Waits for a streamed token delta and `run_completed` event.
   - Replays persisted events with `EventService.ListEvents`.

### Flutter Client Setup

See the [Flutter client integration guide](turing-client/turing_app/README.md)
for run commands, shell integration details, settings behavior, and current
backend-dependent limitations. The client is available now, but end-to-end chat
requires the backend orchestrator, runtime, and event stream to be running.

### Troubleshooting

- **Backend not healthy**: If `HealthService.Check` does not respond on port 3000, check that the orchestrator container built successfully and that no other local service is using the port.
- **gRPC auth/config failures**: `Unauthenticated` responses usually mean `TURING_CLIENT_API_KEY` is missing, mismatched, or not loaded from `.env`.
- **Ollama Connection Refused**: Ensure Ollama is running on your host. On macOS, ensure Docker can reach it through `host.docker.internal`.
- **gRPC Smoke Timeout**: If `smoke-grpc.sh` times out, check the `turing-orchestrator` and `turing-agent-runtime-general` logs for auth failures, runtime crashes, missing events, or an incorrect `session_id`/`run_id`.
- **Missing `.env`**: Run `scripts/init.sh` first. Do not commit your `.env` file.
- **Database Locked**: If you encounter SQLite `BUSY` errors during high-concurrency smoke tests, ensure you are using the WAL journal mode (managed by the orchestrator).
- **Wrong Ports**: Default ports are 3000 (public gRPC) and 3001 (internal gRPC). If these conflict with other local services, update your `.env` and restart the backend services.

### Documentation

- [Technical Specification](docs/superpowers/specs/2026-05-09-project-turing-v1-design-copilot.md)
- [Implementation Plan](docs/superpowers/plans/2026-05-10-project-turing-v1-hybrid-runtime.md)
- [Integration Checklist](docs/superpowers/integration-checklist.md)
