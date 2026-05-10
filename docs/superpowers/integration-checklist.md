# Project Turing v1.0 Integration Checklist

Use this checklist to validate the integration of Tasks 1-15 as they are merged.

## 1. Foundation (Task 1-2)
- [ ] `turing-backend/scripts/init.sh` exists and generates `.env`.
- [ ] `turing-backend/infra/docker-compose.yml` exists and uses the new service names.
- [ ] `turing-backend/shared-types` exists and `npm run build` succeeds.
- [ ] `turing-client/flutter_app` is the new home of the Flutter client.

## 2. Orchestrator (Task 3-6)
- [ ] `turing-orchestrator` starts and listens on 3000 (public) and 3001 (internal).
- [ ] SQLite migrations apply on startup (`data/turing.db` created).
- [ ] `GET /health` and `GET /api/config` work with `TURING_CLIENT_API_KEY`.
- [ ] Internal API can claim jobs and post events.

## 3. Agent Runtime & Streaming (Task 7-10)
- [ ] `turing-agent-runtime-general` starts and connects to orchestrator.
- [ ] Sending a message to `/api/sessions/:id/messages` triggers a job.
- [ ] WebSocket `/ws` streams live events (e.g., `message.delta`).
- [ ] Event replay via `lastSequence` works on reconnect.

## 4. MCP & Tools (Task 11-14)
- [ ] `turing-mcp-system` and `turing-mcp-files` are running and reachable by agent runtime.
- [ ] Safe tools (e.g., `system.time`) work without user approval.
- [ ] Sensitive tools (e.g., `files.create`) trigger `approval.requested` event.
- [ ] Audit logs and tool-call records are created for every MCP call.

## 5. Flutter Client (Task 15)
- [ ] App starts at settings if no API key is set.
- [ ] Chat screen displays live streaming bubbles.
- [ ] Approval cards appear for approval-required tools.
- [ ] Tapping "Approve" allows the tool call to proceed.

## 6. End-to-End (Task 16)
- [ ] `turing-backend/scripts/smoke.sh` passes successfully in a clean environment.
- [ ] `README.md` instructions are accurate and easy to follow.
