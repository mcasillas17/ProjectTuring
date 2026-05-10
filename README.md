# Project Turing

Project Turing is a local-first personal AI orchestration platform. It coordinates a Flutter client with a Node.js orchestrator that manages sessions, agent runs, and MCP tool calls.

## Project Turing v1.0 local runtime

### Prerequisites

- Docker and Docker Compose
- Node.js 20+
- Ollama (running on host)
- Flutter (for the client)

### Backend Setup

Initialize backend secrets:

```bash
cd turing-backend
./scripts/init.sh
```

This will create a `.env` file and print your `TURING_CLIENT_API_KEY`. **Save this key** as you will need it for the Flutter client.

Start the backend services:

```bash
./scripts/dev.sh
```

The orchestrator will be available at `http://localhost:3000`.

### Smoke Testing

To verify the end-to-end flow (Docker, REST API, WebSocket, and Audit):

```bash
cd turing-backend
./scripts/smoke.sh
```

### Flutter Client Setup

1.  Navigate to the client directory:
    ```bash
    cd turing-client/turing_app
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

See the [Flutter client integration guide](turing-client/turing_app/README.md) for shell integration details, settings behavior, and current backend-dependent limitations.

### Documentation

- [Technical Specification](docs/superpowers/specs/2026-05-09-project-turing-v1-design-copilot.md)
- [Implementation Plan](docs/superpowers/plans/2026-05-10-project-turing-v1-hybrid-runtime.md)
