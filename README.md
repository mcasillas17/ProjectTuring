# Project Turing

Project Turing is a local-first personal AI orchestration platform. It coordinates a Flutter client with a Node.js orchestrator that manages sessions, agent runs, and MCP tool calls.

## Project Turing v1.0 local runtime

> **Status:** v1.0 foundation is integrated on `pturing-v1-base`. The local stack includes the Node.js orchestrator, SQLite persistence, the general agent runtime, Go MCP servers, Ollama routing, WebSocket streaming, and the Flutter client shell.

### Prerequisites

- **Docker and Docker Compose**: Required for running the orchestrator, agent runtime, and MCP servers.
- **Node.js 20+**: Required for local scripting and smoke tests.
- **Ollama**: Must be running on your host machine. Project Turing expects Ollama to be reachable at `http://host.docker.internal:11434` from within Docker.
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
| `turing-orchestrator` | Public REST/WebSocket API, internal runtime API, SQLite persistence | Publishes port `3000`; exposes internal port `3001` only to Docker networks |
| `turing-agent-runtime-general` | Polls jobs, calls model providers, streams runtime events back to the orchestrator | Internal Docker networks only |
| `turing-mcp-system` | Safe system MCP tools | Internal `net-system` network only |
| `turing-mcp-files` | Sandboxed file MCP tools with approval-gated writes | Internal `net-files` network only |

Important `.env` values:

| Variable | Purpose |
|---|---|
| `TURING_CLIENT_API_KEY` | Bearer token for REST/WebSocket clients |
| `TURING_INTERNAL_TOKEN` | Bearer token for orchestrator internal APIs and MCP approval consumption |
| `MCP_SYSTEM_TOKEN_GENERAL` / `MCP_FILES_TOKEN_GENERAL` | Per-server runtime-to-MCP bearer tokens |
| `TURING_APPROVAL_JWT_SECRET` | HS256 signing secret shared by the orchestrator and Files MCP server |
| `ORCHESTRATOR_INTERNAL_BASE_URL` | Internal runtime/MCP callback URL, normally `http://turing-orchestrator:3001/internal` |
| `FILES_SANDBOX_ROOT` | Files MCP sandbox root inside the container, normally `/sandbox` |
| `OLLAMA_BASE_URL` / `OLLAMA_MODEL` | Local model endpoint and default model |

For approval-gated filesystem writes, the orchestrator creates approval records,
signs a short-lived JWT after user approval, and the Files MCP server validates
and consumes that approval before touching disk. See the [MCP Security and
Integration Guide](docs/mcp-security-and-integration.md) for the full flow.

### Smoke Testing

Run the end-to-end smoke path after Ollama is reachable from Docker:

```bash
cd turing-backend
./scripts/smoke.sh
```

The smoke script initializes secrets, builds and starts the Compose stack, checks
the orchestrator health endpoint, exercises authenticated REST APIs, waits for a
streamed WebSocket `message.completed` event, verifies reconnect replay, and
checks audit/tool-call endpoints.

Script syntax checks:

```bash
bash -n turing-backend/scripts/smoke.sh
node --check turing-backend/scripts/smoke-ws.mjs
```

#### Full `smoke.sh` flow:

1.  **Prerequisite checks**: Requires `scripts/init.sh` and `infra/docker-compose.yml`.
2.  **Initialization**: Runs `./scripts/init.sh` to create local secrets.
3.  **Orchestration**: Uses `docker compose -f infra/docker-compose.yml up --build -d` to ensure a clean, up-to-date environment.
4.  **Health Check**: Polls `http://localhost:3000/health` until the orchestrator is ready.
5.  **REST Validation**:
    - Verifies `/api/config` returns enabled providers.
    - Creates a test session and verifies the `sessionId` format.
    - Enqueues a message and captures the `runId`.
6.  **WebSocket Validation** (via `smoke-ws.mjs`):
    - Establishes a connection with the `TURING_CLIENT_API_KEY`.
    - Sends a `hello` event for the test session.
    - Waits for a `message.completed` event for the captured `runId`.
    - Disconnects and reconnects with `lastSequence` to verify the replay buffer.
7.  **Audit Inspection**: Verifies that `/api/audit` and `/api/tool-calls` return valid JSON structures.

### Flutter Client Setup

See the [Flutter client integration guide](turing-client/turing_app/README.md)
for run commands, shell integration details, settings behavior, and current
backend-dependent limitations. The client is available now, but end-to-end chat
requires the backend orchestrator, runtime, and event stream to be running.

### Troubleshooting

- **Backend not healthy**: If `/health` does not respond on port 3000, check that the orchestrator container built successfully and that no other local service is using the port.
- **API auth/config failures**: `401` or `403` responses usually mean `TURING_CLIENT_API_KEY` is missing, mismatched, or not loaded from `.env`. `/api/config` failures can also indicate the backend has not loaded provider configuration.
- **Ollama Connection Refused**: Ensure Ollama is running on your host. On macOS, ensure "Allow origins" or similar settings permit connections from Docker, or verify `host.docker.internal` is resolving correctly.
- **WebSocket Timeout**: If `smoke-ws.mjs` times out, check the `turing-orchestrator` logs for auth failures, runtime crashes, missing events, or an incorrect `sessionId`/`runId`.
- **Missing `.env`**: Run `scripts/init.sh` first. Do not commit your `.env` file.
- **Database Locked**: If you encounter SQLite `BUSY` errors during high-concurrency smoke tests, ensure you are using the WAL journal mode (managed by the orchestrator).
- **Wrong Ports**: Default ports are 3000 (public) and 3001 (internal). If these conflict with other local services, update your `.env` and restart the backend services.

### Documentation

- [Technical Specification](docs/superpowers/specs/2026-05-09-project-turing-v1-design-copilot.md)
- [Implementation Plan](docs/superpowers/plans/2026-05-10-project-turing-v1-hybrid-runtime.md)
- [Integration Checklist](docs/superpowers/integration-checklist.md)
