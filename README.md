# Project Turing

Project Turing is a local-first personal AI orchestration platform. It coordinates a Flutter client with a Node.js orchestrator that manages sessions, agent runs, and MCP tool calls.

## Project Turing v1.0 local runtime

> **Status: Development In Progress.** The backend orchestrator and agent runtime are currently being implemented across multiple workstreams (Copilot/Claude/Codex). Some steps below are **provisional** and will become fully functional as upstream branches are merged into `pturing-v1-base`.

### Prerequisites

- **Docker and Docker Compose**: Required for running the orchestrator, agent runtime, and MCP servers.
- **Node.js 20+**: Required for local scripting and smoke tests.
- **Ollama**: Must be running on your host machine. Project Turing expects Ollama to be reachable at `http://host.docker.internal:11434` from within Docker.
- **Flutter**: Required for building and running the client application.

### Backend setup status

The full v1 backend setup is **pending backend integration**. The current branch
contains the smoke-test harness, but the backend foundation branch still needs to
land the generated secrets script and v1 Docker Compose layout:

- `turing-backend/scripts/init.sh`
- `turing-backend/scripts/dev.sh`
- `turing-backend/infra/docker-compose.yml`

Once those backend artifacts land, the expected local startup flow is:

```bash
cd turing-backend
./scripts/init.sh
./scripts/dev.sh
```

`init.sh` is expected to create `.env` and print `TURING_CLIENT_API_KEY`. Save
that key for local clients. Until the backend foundation lands, do not treat the
commands above as runnable setup steps.

### Smoke Testing

The smoke-test harness is present now, but the full end-to-end smoke run is
**pending backend integration**. Today it can be syntax-checked and reviewed for
the expected flow. After the backend foundation lands, it will validate that
services build, start, authenticate, stream events, and expose audit/tool-call
state.

Current validation:

```bash
bash -n turing-backend/scripts/smoke.sh
node --check turing-backend/scripts/smoke-ws.mjs
```

Expected full smoke run once backend integration lands:

```bash
cd turing-backend
./scripts/smoke.sh
```

#### What the smoke path validates:

| Phase | Validates now | Validates after backend integration |
|---|---|---|
| **Environment** | Smoke script syntax and explicit missing-backend guards | Secrets generation, `infra/docker-compose.yml`, full container networking, volume mounts |
| **REST API** | Expected endpoint sequence is documented in the script | `/health`, `/api/config`, session creation, message enqueueing, SQLite persistence |
| **WebSocket** | `smoke-ws.mjs` syntax and timeout cleanup | Authenticated handshake, live event streaming, reconnect replay |
| **Audit** | Expected audit/tool-call checks are documented in the script | Real audit entries, tool-call records, policy decisions |

#### Expected full `smoke.sh` flow:

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

Currently, `smoke.sh` is expected to fail fast if the backend foundation has not
yet landed. Use the [Integration Checklist](docs/superpowers/integration-checklist.md)
to track readiness before running the full smoke path.

### Flutter Client Setup

See the [Flutter client guide](turing-client/turing_app/README.md). The client
is available now, but end-to-end chat requires the backend orchestrator,
runtime, and event stream to be running.

### Troubleshooting

- **Missing backend artifacts**: If `scripts/init.sh`, `scripts/dev.sh`, or `infra/docker-compose.yml` are missing, the backend foundation branch has not been merged yet. Only syntax-check the smoke scripts until those files exist.
- **Backend not healthy**: If `/health` does not respond on port 3000, check that the orchestrator container built successfully and that no other local service is using the port.
- **API auth/config failures**: `401` or `403` responses usually mean `TURING_CLIENT_API_KEY` is missing, mismatched, or not loaded from `.env`. `/api/config` failures can also indicate the backend has not loaded provider configuration.
- **Ollama Connection Refused**: Ensure Ollama is running on your host. On macOS, ensure "Allow origins" or similar settings permit connections from Docker, or verify `host.docker.internal` is resolving correctly.
- **WebSocket Timeout**: If `smoke-ws.mjs` times out, check the `turing-orchestrator` logs for auth failures, runtime crashes, missing events, or an incorrect `sessionId`/`runId`.
- **Missing `.env`**: Once the backend foundation lands, run `scripts/init.sh` first. Do not commit your `.env` file.
- **Database Locked**: If you encounter SQLite `BUSY` errors during high-concurrency smoke tests, ensure you are using the WAL journal mode (managed by the orchestrator).
- **Wrong Ports**: Default ports are 3000 (public) and 3001 (internal). If these conflict with other local services, update your `.env` and restart the backend services.

### Documentation

- [Technical Specification](docs/superpowers/specs/2026-05-09-project-turing-v1-design-copilot.md)
- [Implementation Plan](docs/superpowers/plans/2026-05-10-project-turing-v1-hybrid-runtime.md)
- [Integration Checklist](docs/superpowers/integration-checklist.md)
