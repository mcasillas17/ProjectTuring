# Project Turing v1.0 Integration Checklist

Use this checklist to validate the integration of Tasks 1-15 as they are merged into `pturing-v1-base`.

## 1. Foundation (Task 1-2)
- [ ] `turing-backend/scripts/init.sh` exists and generates a valid `.env` with random secrets.
- [ ] `turing-backend/infra/docker-compose.yml` is valid (`docker compose config`) and defines the 4 core services.
- [ ] `turing-backend/shared-types` exists and `npm run build` generates `dist/` with valid type declarations.
- [ ] `turing-client/flutter_app` contains the migrated Flutter source and `pubspec.yaml` uses the new package name.

## 2. Orchestrator (Task 3-6)
- [ ] `turing-orchestrator` container builds and starts without immediate crash.
- [ ] Orchestrator logs show "WAL mode" and migration application for `0001_initial.sql`.
- [ ] `GET /health` returns `{ ok: true }`.
- [ ] `POST /api/sessions` requires valid `Bearer` auth and persists to SQLite.
- [ ] Internal port 3001 is reachable from other containers but NOT published to host.

## 3. Agent Runtime & Streaming (Task 7-10)
- [ ] `turing-agent-runtime-general` container logs show successful job polling from orchestrator.
- [ ] Enqueuing a message results in an `agent_runs` entry with status `running`.
- [ ] WebSocket connection remains open during agent execution.
- [ ] `message.delta` events contain cumulative text chunks that match the model output.
- [ ] Replay handshake (`hello` with `lastSequence`) correctly serves missed events from the database.

## 4. MCP & Tools (Task 11-14)
- [ ] MCP servers (`system` and `files`) validate the per-agent bearer token.
- [ ] Files MCP correctly rejects path traversal (e.g., `../../etc/passwd`).
- [ ] Safe tools complete successfully and emit `tool.call.completed`.
- [ ] Approval-required tools (e.g., `files.update`) block execution and emit `approval.requested`.
- [ ] Orchestrator signs a valid HS256 JWT for approved tools.
- [ ] `audit_logs` table contains entries for `auth.failed`, `tool.call.before`, and `tool.call.after`.

## 5. Flutter Client (Task 15)
- [ ] Flutter app correctly persists the API key and URL in secure storage.
- [ ] Chat UI displays a loading state while waiting for the first `message.started`.
- [ ] Approval cards display the correct tool name and arguments.
- [ ] Tapping "Approve" triggers a REST call that moves the run state to `running`.

## 6. End-to-End (Task 16)
- [ ] `turing-backend/scripts/smoke.sh` passes 100% in a clean Docker environment.
- [ ] All `README.md` setup steps result in a working system.
- [ ] Verification scripts (`smoke-ws.mjs`) correctly handle network timeouts and retries.

---

## Verification Best Practices

- **Log Monitoring**: Always keep a terminal open with `docker compose logs -f` during integration tests.
- **Database Inspection**: Use `sqlite3 turing-backend/data/turing.db` to verify that tables are being populated as expected.
- **Network Isolation**: Verify that `turing-agent-runtime-general` cannot reach MCP servers it is not authorized for by checking Docker network configurations.
- **Ollama Mocking**: If Ollama is unavailable, verify that the runtime fails gracefully with a `model_unavailable` error code rather than an unhandled exception.
- **Clean Starts**: Frequently use `scripts/reset.sh` to ensure that migrations and initialization work from a zero-state.
