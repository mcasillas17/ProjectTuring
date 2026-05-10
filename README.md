# Project Turing

Project Turing is a local-first personal AI orchestration platform. It coordinates a Flutter client with a Node.js orchestrator that manages sessions, agent runs, and MCP tool calls.

## Project Turing v1.0 local runtime

> **Status: Development In Progress.** The backend orchestrator and agent runtime are currently being implemented across multiple workstreams (Copilot/Claude/Codex). Some steps below are **provisional** and will become fully functional as upstream branches are merged into `pturing-v1-base`.

### Prerequisites

- **Docker and Docker Compose**: Required for running the orchestrator, agent runtime, and MCP servers.
- **Node.js 20+**: Required for local scripting and smoke tests.
- **Ollama**: Must be running on your host machine. Project Turing expects Ollama to be reachable at `http://host.docker.internal:11434` from within Docker.
- **Flutter**: Required for building and running the client application.

### Backend Setup (Provisional)

Initialize backend secrets:

```bash
cd turing-backend
./scripts/init.sh
```

This will create a `.env` file and print your `TURING_CLIENT_API_KEY`. **Save this key**—you will need it for the Flutter client.

Start the backend services:

```bash
./scripts/dev.sh
```

*Note: If the `orchestrator` or `agent-runtime` images fail to build, verify that the corresponding directories contain the expected source code. These are landed via separate backend implementation tasks.*

### Smoke Testing

The smoke test validates the end-to-end integration of the backend infrastructure. It ensures that all services can build, start, and communicate correctly.

```bash
cd turing-backend
./scripts/smoke.sh
```

#### What the smoke path validates:

| Phase | Validates Now (with Scaffolding) | Validates Later (Post-Integration) |
|---|---|---|
| **Environment** | Secrets gen, Docker Compose config | Full container networking, Volume mounts |
| **REST API** | Endpoint reachability (Fastify) | SQLite persistence, Real business logic |
| **WebSocket** | Connection handshake, Auth | Live event streaming, Session replay |
| **Audit** | JSON schema compliance | Real tool-call beacons, Policy decisions |

#### Technical Details of `smoke.sh`:

1.  **Orchestration**: Uses `docker compose up --build -d` to ensure a clean, up-to-date environment.
2.  **Health Check**: Polls `http://localhost:3000/health` until the orchestrator is ready.
3.  **REST Validation**:
    - Verifies `/api/config` returns enabled providers.
    - Creates a test session and verifies the `sessionId` format.
    - Enqueues a message and captures the `runId`.
4.  **WebSocket Validation** (via `smoke-ws.mjs`):
    - Establishes a connection with the `TURING_CLIENT_API_KEY`.
    - Sends a `hello` event for the test session.
    - Waits for a `message.completed` event for the captured `runId`.
    - Disconnects and reconnects with `lastSequence` to verify the replay buffer.
5.  **Audit Inspection**: Verifies that `/api/audit` and `/api/tool-calls` return valid JSON structures.

*Currently, `smoke.sh` may fail if the core orchestrator logic has not yet been merged into your branch. Use the [Integration Checklist](docs/superpowers/integration-checklist.md) to track readiness.*

### Flutter Client Setup

1.  Navigate to the client directory:
    ```bash
    cd turing-client/flutter_app
    ```
2.  Install dependencies:
    ```bash
    flutter pub get
    ```
3.  Run the app (e.g., on macOS):
    ```bash
    flutter run -d macos
    ```
4.  In the app's settings screen:
    - Set **Backend URL** to `http://localhost:3000` (or your Mac's LAN IP if running on a physical device).
    - Paste the **API Key** generated during the backend initialization.

### Troubleshooting

- **Ollama Connection Refused**: Ensure Ollama is running on your host. On macOS, ensure "Allow origins" or similar settings permit connections from Docker, or verify `host.docker.internal` is resolving correctly.
- **WebSocket Timeout**: If `smoke-ws.mjs` times out, check the `turing-orchestrator` logs for auth failures or runtime crashes.
- **Missing `.env`**: Always run `scripts/init.sh` first. Do not commit your `.env` file.
- **Database Locked**: If you encounter SQLite `BUSY` errors during high-concurrency smoke tests, ensure you are using the WAL journal mode (managed by the orchestrator).
- **Wrong Ports**: Default ports are 3000 (public) and 3001 (internal). If these conflict with other local services, update your `.env` and restart `scripts/dev.sh`.

### Documentation

- [Technical Specification](docs/superpowers/specs/2026-05-09-project-turing-v1-design-copilot.md)
- [Implementation Plan](docs/superpowers/plans/2026-05-10-project-turing-v1-hybrid-runtime.md)
- [Integration Checklist](docs/superpowers/integration-checklist.md)
