# TuringAgent v1.0 — Design

**Status:** Approved through brainstorming on 2026-05-09. Supersedes `docs/Project_Turing_Tech_Spec_Codex.md`.

## 1. Problem & Goals

TuringAgent is a local-first personal AI orchestration platform that runs primarily on a Mac Mini and provides a private AI assistant layer across desktop and mobile. The v1.0 release establishes the foundation: a client-agnostic backend, one production client, one tool server, and the security primitives needed for v1.1's filesystem and approval-bearing tools.

**Mental model.** *One brain* (the Node/TypeScript orchestrator), *many faces* (Flutter first, native macOS/Windows/Android later), *several hands* (MCP servers, native bridges later).

**v1.0 goals**

- Local-first, client-agnostic Node/TypeScript orchestrator on the Mac Mini.
- SQLite as the canonical local database.
- Local Ollama as the only model provider.
- WebSocket streaming for real-time UX; REST for setup, history, and out-of-band actions.
- Flutter client (macOS + Android) as the first face.
- One Go MCP server (`mcp-system`) with safe read-only tools, proving the tool pipeline end-to-end.
- API-key auth, per-agent capability scoping, audit log, and a dormant-but-wired approval flow ready for v1.1.

**Non-goals for v1.0**

- Files MCP, semantic/vector memory, native macOS bridge PoC, approval UI cards in Flutter.
- Native macOS app, native Windows app, native Android app.
- Google/Microsoft MCPs, OAuth flows.
- Vision/voice/IoT/RTSP/dog-body-language services.
- Multi-agent routing (>1 agent), LangGraph executor.
- Redis, BullMQ, NATS, OpenTelemetry, Tempo, Grafana.
- Multi-user support, per-client API key rotation.

## 2. Locked Decisions Summary

| Decision | Choice |
|---|---|
| Spec authority | This document supersedes the older `Project_Turing_Tech_Spec_Codex.md` |
| Process model | **Approach B**: split processes — orchestrator + agent-runtime |
| Inter-process queue | **SQLite-backed jobs table**, orchestrator-owned, agent-runtime accesses via internal HTTP |
| MCP call path | **Layered Option C**: agent-runtime calls MCP servers directly, with Docker network isolation + per-agent bearer tokens + audit beacons + (v1.1) approval JWTs |
| Secrets | `.env` files at the backend root, gitignored. Revisit (likely keytar or Vault) post-v1.0 |
| First client | Flutter, target macOS desktop + Android |
| Repo layout | `turing-backend/` + `turing-client/{flutter_app, macos_app, windows_app, android_app}` |
| v1.0 scope | Phases 0–5 below. Files MCP, semantic memory, macOS PoC → v1.1 |
| Auth model | Single API key for clients, separate internal token for orchestrator↔runtime, per-agent MCP tokens |
| MCP transport | Streamable HTTP (JSON-RPC) per current MCP spec |
| ID format | ULIDs everywhere, prefixed (`sess_`, `msg_`, `run_`, `job_`, `evt_`, `tool_`, `appr_`, `ev_`) |
| Approval JWT | HS256 (symmetric), shared `TURING_APPROVAL_JWT_SECRET`, 60s TTL, args-bound, single-use |

## 3. System Architecture

### 3.1 Components

```
┌─────────────────────────────────────────────────────────┐    Host (Mac Mini)
│  Docker networks (capability-isolated):                 │    ┌──────────────────┐
│   net-system   {agent-runtime-general, mcp-system,      │    │  Ollama (host)   │
│                 orchestrator}                           │ ──▶│  :11434          │
│                                                         │    └──────────────────┘
│  ┌─────────────────────┐                                │
│  │ turing-orchestrator │ ◀── :3000 ─────────────────────┼──┐ Clients (LAN/Tailscale)
│  │ Node/TS             │                                │  │ ┌──────────────────┐
│  │ • REST + WS (3000)  │                                │  └▶│ Flutter app      │
│  │ • Internal API      │                                │    │ (macOS+Android)  │
│  │   (3001, internal)  │                                │    └──────────────────┘
│  │ • Auth (API key)    │                                │
│  │ • Owns SQLite       │ ◀──┐                           │
│  │ • Issues MCP tokens │    │ internal HTTP             │
│  │ • Audit log writer  │    │ (jobs, audit beacons,     │
│  │ • Approval gate     │    │  approval requests)       │
│  └─────────────────────┘    │                           │
│                             │                           │
│  ┌─────────────────────┐    │   ┌────────────────────┐  │
│  │ turing-agent-       │    │   │ turing-mcp-system  │  │
│  │ runtime-general     │────┘   │ Go, MCP HTTP :7100 │  │
│  │ Node/TS             │──────▶ │ Bearer-token auth  │  │
│  │ • Polls jobs        │ POST   │ system.health      │  │
│  │ • Calls Ollama      │ /mcp   │ system.time        │  │
│  │ • Calls MCPs direct │        │ system.echo        │  │
│  │   (with tokens)     │        │ system.info        │  │
│  │ • Audit-beacons     │        └────────────────────┘  │
│  └─────────────────────┘                                │
│         │                                               │
│         └──── Ollama (host.docker.internal:11434) ───── │
└─────────────────────────────────────────────────────────┘
                                │
                  SQLite: ./data/turing.db
                  (orchestrator-only writes)
```

### 3.2 Process responsibilities

**`turing-orchestrator`** (Node/TS, Docker)
- Public REST + WebSocket on port 3000 (only host-published port).
- Internal HTTP on port 3001 (Docker network only, never published to host).
- Owns SQLite — only writer.
- API-key auth, internal-token auth, audit log, tool registry, approval gate, JWT signing.
- Broadcasts events from `events` table to subscribed WS clients.

**`turing-agent-runtime-general`** (Node/TS, Docker)
- Long-polls `GET /internal/jobs/next?agent=general_assistant`.
- Loads agent definition (config-driven, TS).
- Builds prompt from session history (fetched via `/internal/sessions/.../messages`).
- Calls Ollama at `host.docker.internal:11434`, streams tokens.
- Calls MCP servers directly with its bearer token; beacons audit to orchestrator before/after each call.
- Posts events to `/internal/runs/{run_id}/events` for streaming and persistence.
- One container per agent in the long term; v1.0 has one agent, one container.

**`turing-mcp-system`** (Go, Docker)
- Streamable HTTP MCP endpoint at `POST /mcp` on port 7100.
- Bearer-token auth (validates `Authorization: Bearer <token>` against allowlist).
- Approval JWT verifier wired up but dormant (no v1.0 tools require approval).
- Tools (all read-only/safe): `system.health`, `system.time`, `system.echo`, `system.info`.

**Ollama** (host process, not Docker)
- Runs on `localhost:11434` on the Mac Mini host.
- Containers reach it via `host.docker.internal:11434` (compose `extra_hosts: ["host.docker.internal:host-gateway"]`).

### 3.3 Network isolation

Docker networks are scoped by capability. v1.0 has one network because there's one capability domain (`net-system`). When v1.1's `mcp-files` arrives, it gets its own network (`net-files`); a future `mcp-google` gets `net-google`; etc.

```yaml
networks:
  net-system:

services:
  orchestrator:
    networks: [net-system]            # sees all networks (joins each as added)
    ports: ["3000:3000"]              # ONLY host-published port
  agent-runtime-general:
    networks: [net-system]            # only mcp-system reachable
    # no host port published
  mcp-system:
    networks: [net-system]
    expose: ["7100"]                  # internal only
```

**Why this matters:** if an agent process is compromised or buggy, it cannot make HTTP requests to MCP servers it has no business reaching — DNS resolution simply fails. This is kernel-level enforcement, not application allowlist code.

### 3.4 Module boundaries (orchestrator)

```
orchestrator/src/
  server.ts          process entry, public + internal listeners
  api/               public REST handlers (/api/*)
  ws/                WebSocket gateway (/ws)
  internal/          /internal/* API for agent-runtime
  agents/            registry (config-driven), AgentExecutor interface
  jobs/              queue write/poll/reaper
  tools/             tool registry, allowlist, JWT signing
  llm/               provider interface (Ollama only in v1.0)
  db/                SQLite + migrations
  security/          API-key + internal-token middleware, audit writer
  logging/           Pino + correlation IDs
  config.ts          env var loading + validation
```

The `AgentExecutor` interface lets us swap implementations later (e.g., a LangGraph-backed executor) without touching the API or persistence.

## 4. Data Flow & Inter-Process Contract

### 4.1 Internal HTTP API (orchestrator exposes; agent-runtime calls)

All endpoints under `/internal/*` on **port 3001**. Auth: `Authorization: Bearer ${TURING_INTERNAL_TOKEN}`. Bound to Docker network — **never published to host**.

| Endpoint | Purpose |
|---|---|
| `GET /internal/jobs/next?agent=<id>` | Long-poll (~30s). Atomically claims and returns next pending job for that `agent_id`, marking it `in_progress`. Returns 204 on timeout. |
| `POST /internal/runs/{run_id}/events` | Append a streaming event. Persisted to `events` table, then broadcast to WS subscribers. |
| `POST /internal/runs/{run_id}/audit/tool-call` | Audit beacon: agent posts `{phase: "before"\|"after", tool, args, result_summary?, status?, duration_ms?}`. Persisted in `audit_log` and `tool_calls`. |
| `POST /internal/runs/{run_id}/approval-request` | Agent requests approval for a sensitive tool (v1.1+). Returns 202 with `approval_id`; agent polls `/internal/approvals/{id}` until `decided` or `expired`. |
| `GET /internal/approvals/{id}` | Returns approval status + (when approved) signed JWT. |
| `POST /internal/runs/{run_id}/complete` | Mark run succeeded with final assistant message. |
| `POST /internal/runs/{run_id}/fail` | Mark run failed with error. |
| `GET /internal/sessions/{id}/messages?limit=N` | Fetch recent messages for prompt context. |

### 4.2 Run lifecycle

```
agent_run:    pending ──→ in_progress ──→ succeeded
                              └──→ failed

job:          pending ──→ in_progress ──→ completed
                              └──→ failed (after N attempts)
```

A reaper sweep every 60s reclaims jobs in `in_progress > 5min` (re-marks `pending`, attempts++). Max 3 attempts → `failed`.

### 4.3 Streaming flow (hot path)

```
agent-runtime              orchestrator                  WS client
     │                          │                            │
     │ GET /internal/jobs/next  │                            │
     ├─────────────────────────▶│                            │
     │ ◀──── job ───────────────┤                            │
     │  call Ollama (stream)    │                            │
     │ POST /events {delta}     │                            │
     ├─────────────────────────▶│ persist + broadcast        │
     │                          ├───────────────────────────▶│
     │ POST /audit/tool-call    │                            │
     │  {phase: "before"}       │                            │
     ├─────────────────────────▶│ append audit_log row       │
     │ POST /mcp (direct)       │                            │
     ├─────────────────────────▶│  ──→ mcp-system            │
     │ ◀── result ──────────────┤                            │
     │ POST /audit/tool-call    │                            │
     │  {phase: "after",        │                            │
     │   result_summary, ms}    │                            │
     ├─────────────────────────▶│ update audit_log row       │
     │ POST /events             │                            │
     │  {tool_call_complete}    │                            │
     ├─────────────────────────▶├───────────────────────────▶│
     │ POST /complete           │                            │
     ├─────────────────────────▶│ mark succeeded             │
     │                          ├──── message_complete ────▶│
```

**Persistence policy:** every event is written to the `events` table *before* being broadcast. Reconnecting clients can replay from `eventId > lastEventId`.

**Back-pressure:** orchestrator does no buffering. If a WS write fails or the kernel send-buffer fills, the connection is dropped. The client reconnects and replays from `events`. Nothing is lost.

**Performance note:** writing every Ollama token through HTTP + SQLite is fine at v1.0 scale (~50 tokens/sec from local models). If it ever becomes a bottleneck, the fix is to batch deltas every ~50ms in agent-runtime — not to add Redis.

### 4.4 Tool call path

```
agent-runtime                                    mcp-system
     │ POST http://mcp-system:7100/mcp                │
     │   Authorization: Bearer <agent's MCP token>    │
     │   { method: "tools/call",                      │
     │     params: { name: "system.time", ... } }     │
     ├───────────────────────────────────────────────▶│
     │                                                │ validate token
     │                                                │  → identity: general_assistant
     │                                                │ check tool in allowlist for token
     │                                                │ execute
     │                                                │ log to MCP-server audit
     │ ◀───────── result ─────────────────────────────┤
     │ (audit beacons orchestrator separately)
```

### 4.5 Failure modes

| Failure | Behavior |
|---|---|
| Ollama unreachable | Run fails with `model_unavailable`. WS sends `error` event. No retry. |
| MCP server 5xx | Agent-runtime retries once, then either falls back to text-only or fails the run (per tool config). |
| MCP server 401 | Run fails. `audit_log` records `security.bad_token`. Operator should regenerate `.env`. |
| Agent-runtime crashes mid-run | Job stays `in_progress`. Reaper reclaims after 5min. |
| Orchestrator restart | WS clients drop; reconnect with `lastEventId` and replay. |
| Client disconnects mid-stream | Run continues. Events accumulate in `events` table. Client gets full message on reconnect. |
| Audit beacon network failure | Agent-runtime continues (best-effort) and logs locally. v1.0 does not gate further jobs on missed beacons. |

## 5. Wire Protocols

### 5.1 Client ↔ Orchestrator: REST

Base: `http://<host>:3000/api`. Auth: `Authorization: Bearer ${TURING_CLIENT_API_KEY}` on every request.

| Method | Path | Purpose | Auth |
|---|---|---|---|
| GET | `/health` | Liveness | none |
| GET | `/version` | Build info, schema version | none |
| GET | `/api/sessions` | List sessions | API key |
| POST | `/api/sessions` | Create session, returns `{sessionId}` | API key |
| GET | `/api/sessions/:id` | Session metadata | API key |
| GET | `/api/sessions/:id/messages?limit=50&before=<id>` | Paginated message history | API key |
| POST | `/api/messages` | Synchronous fallback for non-WS clients (v1.0: stub returning 405; WS is the path) | API key |
| GET | `/api/agents` | List configured agents | API key |
| GET | `/api/tools` | List known tools and metadata | API key |
| POST | `/api/approvals/:id/decide` | Approve/deny pending approval (v1.1+) | API key |

### 5.2 Client ↔ Orchestrator: WebSocket

Endpoint: `ws://<host>:3000/ws`. Auth: `?token=<client_api_key>` query param at connect time, validated before upgrade. Connection rejected on bad token.

**Client → Server**

```ts
{ type: "hello", sessionId: string | null, lastEventId?: string }
{ type: "send_message", sessionId: string, text: string }
{ type: "ping", ts: number }
```

**Server → Client**

```ts
{ type: "hello_ack", sessionId: string, missedEvents?: Event[] }

{ type: "message_started", messageId: string, runId: string, role: "assistant" }
{ type: "message_delta", messageId: string, delta: string, sequence: number }
{ type: "message_complete", messageId: string }

{ type: "tool_call_started", runId: string, toolCallId: string, tool: string, args: object }
{ type: "tool_call_complete", toolCallId: string, status: "ok" | "denied" | "failed", resultSummary?: string }

{ type: "approval_requested", approvalId: string, tool: string, args: object }   // v1.1+
{ type: "run_complete", runId: string }
{ type: "run_failed", runId: string, error: string }

{ type: "error", message: string, runId?: string }
{ type: "pong", ts: number }
```

**Reconnect protocol:**

1. Client reconnects with `{type: "hello", sessionId, lastEventId}`.
2. Orchestrator queries `events WHERE session_id = ? AND id > ? ORDER BY id`.
3. Returns them inline as `hello_ack.missedEvents`, then resumes live streaming.
4. If `lastEventId` is unknown or older than 24h, orchestrator omits `missedEvents` and the client falls back to REST `/api/sessions/:id/messages`.

### 5.3 Agent-Runtime ↔ MCP Server

Transport: Streamable HTTP (JSON-RPC) per the current MCP spec. Endpoint: `POST http://mcp-system:7100/mcp`. Auth: `Authorization: Bearer ${MCP_SYSTEM_TOKEN_GENERAL}`.

**Tool list** (called once at agent-runtime startup, cached):

```json
{ "jsonrpc": "2.0", "id": 1, "method": "tools/list", "params": {} }
```

**Tool call:**

```json
{
  "jsonrpc": "2.0", "id": 42,
  "method": "tools/call",
  "params": {
    "name": "system.time",
    "arguments": {}
  }
}
```

**Approval-bound call** (v1.1+, format scaffolded in v1.0):

```json
"params": {
  "name": "files.write",
  "arguments": { "path": "...", "content": "..." },
  "_meta": { "approvalToken": "eyJhbGciOiJIUzI1NiIs..." }
}
```

The MCP server validates the JWT signature against `TURING_APPROVAL_JWT_SECRET`, checks `exp`, computes `args_hash` from received arguments, compares against the JWT's `args_hash`. Approves only if all checks pass.

### 5.4 Approval JWT format (HS256)

```ts
{
  iss: "turing.orchestrator",
  sub: "general_assistant",            // requesting agent_id
  jti: "appr_01J...",                  // approval id, single-use
  tool: "files.write",
  args_hash: "sha256:...",             // SHA-256 of canonicalized args JSON
  exp: <unix ts, iat + 60>,
  iat: <unix ts>
}
```

The MCP server tracks consumed `jti` values in a small in-memory cache (LRU, TTL = JWT TTL × 2). On consumption, the orchestrator marks the approval row `consumed`.

## 6. Persistence

### 6.1 SQLite configuration

- Single database file at `./data/turing.db`, bind-mounted into the orchestrator container only.
- WAL mode enabled at startup: `PRAGMA journal_mode=WAL; PRAGMA busy_timeout=5000;`
- Migrations are numbered SQL files under `turing-backend/orchestrator/migrations/` (`0001_initial.sql`, `0002_*.sql`...). Tracked via `schema_migrations`. Applied in order on startup; any failure causes process exit (fail-fast).

### 6.2 IDs

ULIDs (lexically sortable, time-ordered) with type prefixes:

- `sess_<26 chars>`, `msg_<...>`, `run_<...>`, `job_<...>`
- `evt_<...>`, `tool_<...>`, `appr_<...>`, `ev_<...>` (audit log)

Timestamps: ISO 8601 strings (UTC).

### 6.3 Schema (v1.0)

```sql
CREATE TABLE sessions (
  id          TEXT PRIMARY KEY,
  title       TEXT,
  created_at  TEXT NOT NULL,
  updated_at  TEXT NOT NULL
);

CREATE TABLE messages (
  id            TEXT PRIMARY KEY,
  session_id    TEXT NOT NULL REFERENCES sessions(id),
  run_id        TEXT REFERENCES agent_runs(id),
  role          TEXT NOT NULL CHECK (role IN ('user','assistant','system')),
  content       TEXT NOT NULL,
  content_type  TEXT NOT NULL DEFAULT 'text',
  sequence      INTEGER NOT NULL,
  created_at    TEXT NOT NULL
);
CREATE INDEX idx_messages_session_created ON messages(session_id, created_at);

CREATE TABLE agent_runs (
  id              TEXT PRIMARY KEY,
  session_id      TEXT NOT NULL REFERENCES sessions(id),
  user_message_id TEXT NOT NULL REFERENCES messages(id),
  agent_id        TEXT NOT NULL,
  status          TEXT NOT NULL CHECK (status IN ('pending','in_progress','succeeded','failed')),
  started_at      TEXT,
  finished_at     TEXT,
  error           TEXT,
  created_at      TEXT NOT NULL
);
CREATE INDEX idx_runs_session ON agent_runs(session_id, created_at);

CREATE TABLE jobs (
  id              TEXT PRIMARY KEY,
  run_id          TEXT NOT NULL REFERENCES agent_runs(id),
  agent_id        TEXT NOT NULL,
  status          TEXT NOT NULL CHECK (status IN ('pending','in_progress','completed','failed')),
  attempt         INTEGER NOT NULL DEFAULT 1,
  payload_json    TEXT NOT NULL,
  picked_up_at    TEXT,
  finished_at     TEXT,
  error           TEXT,
  created_at      TEXT NOT NULL
);
CREATE INDEX idx_jobs_pickup ON jobs(agent_id, status, created_at);
CREATE INDEX idx_jobs_reaper ON jobs(status, picked_up_at);

CREATE TABLE events (
  id            TEXT PRIMARY KEY,
  session_id    TEXT NOT NULL,
  run_id        TEXT,
  sequence      INTEGER NOT NULL,
  event_type    TEXT NOT NULL,
  payload_json  TEXT NOT NULL,
  created_at    TEXT NOT NULL
);
CREATE INDEX idx_events_session ON events(session_id, id);

CREATE TABLE tool_calls (
  id              TEXT PRIMARY KEY,
  run_id          TEXT NOT NULL REFERENCES agent_runs(id),
  agent_id        TEXT NOT NULL,
  mcp_server      TEXT NOT NULL,
  tool_name       TEXT NOT NULL,
  args_json       TEXT NOT NULL,
  result_summary  TEXT,
  status          TEXT NOT NULL CHECK (status IN ('ok','failed','denied')),
  duration_ms     INTEGER,
  approval_id     TEXT REFERENCES approvals(id),
  created_at      TEXT NOT NULL
);
CREATE INDEX idx_tool_calls_run ON tool_calls(run_id, created_at);

CREATE TABLE approvals (
  id            TEXT PRIMARY KEY,
  run_id        TEXT NOT NULL REFERENCES agent_runs(id),
  agent_id      TEXT NOT NULL,
  tool          TEXT NOT NULL,
  args_json     TEXT NOT NULL,
  args_hash     TEXT NOT NULL,
  status        TEXT NOT NULL CHECK (status IN ('pending','approved','denied','expired','consumed')),
  decided_at    TEXT,
  consumed_at   TEXT,
  created_at    TEXT NOT NULL
);
CREATE INDEX idx_approvals_status ON approvals(status, created_at);

CREATE TABLE audit_log (
  id            TEXT PRIMARY KEY,
  actor_type    TEXT NOT NULL,
  actor_id      TEXT,
  action        TEXT NOT NULL,
  target        TEXT,
  payload_json  TEXT,
  created_at    TEXT NOT NULL
);
CREATE INDEX idx_audit_action ON audit_log(action, created_at);

CREATE TABLE schema_migrations (
  version       TEXT PRIMARY KEY,
  applied_at    TEXT NOT NULL
);
```

### 6.4 Tables explicitly NOT in v1.0

- **`users`** — single-user system. v2.0 concern.
- **`agents`** — config-driven (TS registry). Adding/removing an agent is a code change, not a schema change.
- **`tools`** — discovered at startup via MCP `tools/list`, cached in memory.
- **`api_keys`** — single key from `.env`. v1.1+ per-client keys with rotation.
- **`attachments`** — no file uploads in v1.0.

### 6.5 Retention

For v1.0 with one user, no retention policy is needed. Schema decisions keep retention easy when it matters: ULID PKs are time-ordered, so cleanup is `DELETE WHERE id < <ulid_for_cutoff>`. Add a periodic prune job in v1.1 if the `events` table grows large.

## 7. Security Model

### 7.1 Auth tokens (sourced from `.env`)

| Token | Used by | Rotated by |
|---|---|---|
| `TURING_CLIENT_API_KEY` | Flutter → orchestrator (REST + WS) | `scripts/rotate-client-key.sh`; clients re-paste |
| `TURING_INTERNAL_TOKEN` | agent-runtime → orchestrator `/internal/*` | manual `.env` edit + restart |
| `MCP_SYSTEM_TOKEN_GENERAL` | agent-runtime-general → mcp-system | manual `.env` edit + restart |
| `TURING_APPROVAL_JWT_SECRET` | orchestrator (signs) ↔ MCP servers (verify) | manual `.env` edit + restart (forces all in-flight approvals to fail) |

### 7.2 Layered defenses (Layered Option C)

1. **Network isolation.** Each agent-runtime container is on a Docker network with only its allowed MCP servers. Other servers are not DNS-resolvable from that container. Kernel-level enforcement.
2. **Per-agent MCP tokens.** Each MCP server validates `Authorization: Bearer <token>`. Tokens are unique per (agent, server) pair. Compromise of an agent does not grant access to other servers.
3. **Audit beacons.** Agent-runtime posts `before` and `after` events to orchestrator's `/internal/audit/tool-call`. Best-effort but creates a tamper-evident paper trail (combined with MCP server self-logging).
4. **Approval JWTs (v1.1+, scaffolded in v1.0).** Sensitive tools require a short-lived (60s), args-bound, single-use JWT signed by the orchestrator after explicit user approval. MCP server validates signature and binding.

### 7.3 Tool policy

Tools are classified by category in the orchestrator's TS-based tool registry:

- **`safe`** — auto-execute, no approval. v1.0 examples: all `system.*` tools.
- **`requires_approval`** — orchestrator creates a pending approval, broadcasts `approval_requested` event, blocks until user decides. Issues JWT on approve. v1.0 has no tools in this category — wired but dormant.
- **`forbidden`** — orchestrator rejects the agent's request without prompting the user. Used to disable tools globally.

Each agent has an `allowedTools` and `allowedMcps` list in its registry config. Orchestrator enforces both lists when an agent submits a tool call (via beacon's `before` phase) or requests an approval.

### 7.4 Audit log

Every entry includes `correlation_id` (= `runId` when present), `actor_type`, `actor_id`, `action`, `target`, `payload_json`, `created_at`.

v1.0 actions written:

- `auth.failed` — bad client API key, bad internal token, bad MCP token
- `tool.call.before` — agent beacon, before MCP call
- `tool.call.after` — agent beacon, after MCP call
- `tool.call.policy_denied` — orchestrator rejected (allowlist failure)
- `approval.created` / `approval.granted` / `approval.denied` / `approval.consumed` (v1.0: only `created` rows possible, but no v1.0 tools fire this)
- `security.bad_token` — MCP server rejected agent's token

Logs go to stdout (Pino JSON) AND `audit_log` table. Log aggregation deferred.

### 7.5 Internal API binding

The orchestrator runs **two HTTP listeners**:

- Port 3000: public (REST `/api/*` + WebSocket `/ws`). Published to host. Auth: `TURING_CLIENT_API_KEY`.
- Port 3001: internal (`/internal/*`). Bound to Docker network only — NOT published to host. Auth: `TURING_INTERNAL_TOKEN`.

Even if a malicious party gains LAN/Tailscale access, the internal API is not reachable.

## 8. Configuration & Secrets

### 8.1 `.env` layout

`turing-backend/.env` (gitignored), generated by `scripts/init.sh`:

```env
# Public secret: clients save this
TURING_CLIENT_API_KEY=tk_<random>

# Internal: orchestrator <-> agent-runtime
TURING_INTERNAL_TOKEN=<random>

# Per-agent MCP tokens
MCP_SYSTEM_TOKEN_GENERAL=<random>

# JWT secret for approval tokens (HS256, symmetric)
TURING_APPROVAL_JWT_SECRET=<random>

# Public config
ORCHESTRATOR_PUBLIC_PORT=3000
ORCHESTRATOR_INTERNAL_PORT=3001
OLLAMA_URL=http://host.docker.internal:11434
LOG_LEVEL=info
```

`.env.example` is committed, with empty values for each variable.

`.gitignore` includes:

```
.env
.env.*
*.env
!.env.example
.runtime/
data/turing.db*
```

### 8.2 Bootstrap scripts

- **`scripts/init.sh`** — if `.env` missing, generate one (`openssl rand -hex 32` per token), print `TURING_CLIENT_API_KEY` once for the user to save in Flutter, exit. Idempotent: refuses to overwrite an existing `.env`.
- **`scripts/dev.sh`** — `docker compose up` with `LOG_PRETTY=1`.
- **`scripts/reset.sh`** — wipe `./data/`, regenerate `.env`. Confirms before destruction.
- **`scripts/rotate-client-key.sh`** — regenerate only `TURING_CLIENT_API_KEY` in `.env`, restart orchestrator.

### 8.3 Future secrets work (post-v1.0)

`.env` is a deliberate v1.0 simplification. Revisit when:

- Deploying beyond a single Mac Mini (multi-host or cloud).
- Adding OAuth tokens for Google/Microsoft (long-lived sensitive secrets).
- Going multi-user.

Likely targets: `keytar` (cross-platform OS keychain) or HashiCorp Vault. The application reads tokens from a `SecretsBackend` interface, so swapping is mechanical.

## 9. Repo Layout

```
TuringAgent/
├── README.md
├── LICENSE
├── docs/
│   ├── superpowers/specs/
│   │   └── 2026-05-09-project-turing-v1-design.md   ← this document
│   └── Project_Turing_Tech_Spec_Codex.md            (historical, superseded)
│
├── turing-backend/
│   ├── orchestrator/                  Node/TS
│   │   ├── src/
│   │   │   ├── server.ts
│   │   │   ├── api/                   REST handlers (/api/*)
│   │   │   ├── ws/                    WebSocket gateway (/ws)
│   │   │   ├── internal/              /internal/* API
│   │   │   ├── agents/                registry, AgentExecutor interface
│   │   │   ├── jobs/                  queue + reaper
│   │   │   ├── tools/                 registry, allowlist, JWT signing
│   │   │   ├── llm/                   provider interface (Ollama only)
│   │   │   ├── db/                    SQLite + migration runner
│   │   │   ├── security/              auth + audit
│   │   │   ├── logging/
│   │   │   └── config.ts
│   │   ├── migrations/                0001_initial.sql, ...
│   │   ├── tests/
│   │   ├── Dockerfile
│   │   ├── package.json
│   │   └── tsconfig.json
│   │
│   ├── agent-runtime/                 Node/TS
│   │   ├── src/
│   │   │   ├── main.ts                worker entry
│   │   │   ├── agents/                general_assistant config
│   │   │   ├── executor/              the model loop
│   │   │   ├── llm/                   Ollama client (streaming)
│   │   │   ├── mcp/                   Streamable HTTP MCP client
│   │   │   ├── audit/                 beacon poster
│   │   │   ├── logging/
│   │   │   └── config.ts
│   │   ├── tests/
│   │   ├── Dockerfile
│   │   ├── package.json
│   │   └── tsconfig.json
│   │
│   ├── mcp-system/                    Go
│   │   ├── cmd/server/main.go
│   │   ├── internal/
│   │   │   ├── tools/
│   │   │   ├── auth/                  bearer-token middleware
│   │   │   └── jwt/                   approval JWT verifier (dormant)
│   │   ├── go.mod
│   │   └── Dockerfile
│   │
│   ├── shared-types/                  TS, shared between orchestrator + runtime
│   │   ├── src/
│   │   │   ├── events.ts
│   │   │   ├── jobs.ts
│   │   │   ├── protocol.ts
│   │   │   └── index.ts
│   │   ├── package.json
│   │   └── tsconfig.json
│   │
│   ├── infra/
│   │   └── docker-compose.yml
│   ├── scripts/
│   │   ├── init.sh
│   │   ├── dev.sh
│   │   ├── reset.sh
│   │   └── rotate-client-key.sh
│   ├── data/
│   │   └── .gitkeep
│   ├── .env.example
│   └── .gitignore
│
└── turing-client/
    ├── flutter_app/                   renamed from turing_app
    │   ├── lib/
    │   │   ├── main.dart
    │   │   ├── app.dart
    │   │   ├── constants/             existing
    │   │   ├── logic/                 existing
    │   │   ├── models/                extended with WS event types
    │   │   ├── networking/            NEW
    │   │   │   ├── api_client.dart
    │   │   │   ├── ws_client.dart
    │   │   │   └── auth_storage.dart
    │   │   ├── features/
    │   │   │   ├── chat/              streaming + reconnect
    │   │   │   ├── sessions/
    │   │   │   └── settings/          host config + API key paste
    │   │   └── ui/                    existing
    │   └── pubspec.yaml
    ├── macos_app/                     placeholder (.gitkeep)
    ├── windows_app/                   placeholder (.gitkeep)
    └── android_app/                   placeholder (.gitkeep)
```

**Cleanup at phase 0:** delete `turing-backend/services/google-mcp/` and `turing-backend/services/microsoft-mcp/` Dockerfile stubs (dead per cut-line). Replace `turing-backend/orchestrator/Dockerfile` stub with the real one. Rename `turing-client/turing_app/` → `turing-client/flutter_app/`.

## 10. Phase Plan (within v1.0)

Each phase has a demoable goal. No phase is "just refactor."

### Phase 0 — Scaffolding

**Ships:** monorepo structure created. Empty packages with Dockerfiles, package.json, tsconfig.json, go.mod. `docker-compose.yml` with all services defined. `scripts/init.sh` works. Migration runner skeleton. `shared-types` package compiles.

**Demoable goal:** `docker compose build` succeeds; `scripts/init.sh` produces `.env`.

### Phase 1 — Auth + WS pipe

**Ships:** Orchestrator runs Fastify with `/health`, `/api/sessions`, and `/ws` upgrade. API-key validated on every request. WebSocket `hello`/`ping` round-trip works. Two HTTP listeners up (3000 public, 3001 internal stub). Internal-token validation on `/internal/*`.

**Demoable goal:** Flutter connects, sends `hello`, receives `hello_ack`. Bad API key returns 401.

### Phase 2 — Ollama streaming

**Ships:** Agent-runtime container long-polls `/internal/jobs/next`. Orchestrator enqueues a job on `send_message`. Agent-runtime calls Ollama, streams tokens via `/internal/runs/.../events`. Orchestrator broadcasts `message_delta` events. Flutter renders streaming bubble.

**Demoable goal:** type "hi" → see live token stream from local Ollama in the chat UI.

### Phase 3 — Persistence + reconnect

**Ships:** Full schema migrated. Messages, runs, events all persisted. `hello {sessionId, lastEventId}` triggers replay of missed events. Flutter saves `sessionId` to `flutter_secure_storage`. Reaper sweep reclaims stale jobs every 60s.

**Demoable goal:** restart orchestrator mid-stream — Flutter reconnects, history intact, in-flight message completes from where it left off.

### Phase 4 — mcp-system + tool calls

**Ships:** mcp-system Go service implements `tools/list` + `tools/call` for `system.{health,time,echo,info}`. Bearer-token auth. Docker network `net-system` isolates it. Agent-runtime fetches tool list at startup, exposes to Ollama as function-calling, executes tool calls directly, beacons audit before/after to orchestrator. Tool events stream to Flutter.

**Demoable goal:** ask "what time is it?" → model emits tool_call → `system.time` runs → result threads back into model → final response renders.

### Phase 5 — Approval scaffold + audit polish

**Ships:** `approvals` table active. `tools/registry.ts` has `requires_approval` flag (no v1.0 tool sets it). Orchestrator can sign HS256 approval JWTs. mcp-system has the JWT verifier wired up (dormant). `audit_log` writes for `auth.failed`, `tool.call.before/after`, `tool.call.policy_denied`. REST `POST /api/approvals/:id/decide` works.

**Demoable goal:** integration test — with a synthetic `requires_approval=true` tool, agent flow correctly blocks, raises `approval_requested` event, orchestrator signs JWT after `decide`, mcp-system validates and executes.

After phase 5 → tag `v1.0.0`.

## 11. Out of Scope / Deferred

| Item | Lands in |
|---|---|
| Files MCP (sandboxed filesystem read/search/write) | v1.1 |
| Semantic / vector memory (sqlite-vec or similar) | v1.1 |
| Tiny native macOS bridge PoC (active app, send notification) | v1.1 |
| Approval UI cards in Flutter | v1.1 |
| Native macOS app (menu bar, hotkey, deep integration) | v1.1+ |
| Native Windows app/bridge | v2.0+ |
| Google MCP (Calendar, Gmail, Drive) | v1.2+ |
| Microsoft MCP (Outlook, Graph) | v1.2+ |
| Vision service (RTSP, dog body-language, OpenCV/PyTorch) | v2.0 |
| Multi-agent routing (>1 agent) | v1.2+ |
| Voice / wake word | v2.0+ |
| IoT integrations | v2.0+ |
| LangGraph executor | optional, only if custom runtime becomes too complex |
| Per-agent containers (1-per-agent) | when 3+ agents exist; same image, different env |
| Webhook ingress | v2.0+ |
| Multi-user / per-client API keys | v2.0+ |
| OAuth token storage | v1.2+ (with Google/Microsoft MCPs) |
| Per-agent SQLite databases | when an agent needs persistent state |
| OpenTelemetry / Tempo / Grafana | optional, when debugging needs it |

## 12. Open Considerations to Revisit

Not v1.0 work, but flagged so the v1.0 implementation does not paint these into a corner:

- **Secrets approach.** `.env` is a v1.0 simplification. Revisit when leaving single-user/Mac-Mini territory or when adding OAuth tokens. Migration target: `keytar` (cross-platform OS keychain) or HashiCorp Vault. App code reads from a `SecretsBackend` interface so the swap is mechanical.
- **Approval UX latency.** JWTs are 60s-lived. If users routinely take longer than 60s to approve, raise the TTL or add a "request approval, hold token up to 5min" flow.
- **`events` table growth.** Irrelevant at v1.0 scale. Add a prune job in v1.1 if the table grows large or webhooks/sensors land.
- **Internal API port separation.** Phase 1 brings up 3001 alongside 3000. If complexity grows, formalize into a separate listener with its own middleware stack.
- **Single agent-runtime image.** v1.0 has one container. When a second agent arrives, decide between (a) one runtime polling for any `agent_id` and dispatching internally, or (b) one container per `agent_id` (same image, different env).
- **OpenTelemetry.** Skipped for v1.0. The orchestrator's `correlation_id` (= `runId` when present) makes log-only debugging viable, but OTel becomes valuable when there are multiple agents and tool servers in flight simultaneously.
