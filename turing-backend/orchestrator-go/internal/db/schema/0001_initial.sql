CREATE TABLE IF NOT EXISTS schema_migrations (
  version TEXT PRIMARY KEY,
  applied_at TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS settings (
  key TEXT PRIMARY KEY,
  value_json TEXT NOT NULL,
  updated_at TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS sessions (
  id TEXT PRIMARY KEY,
  title TEXT,
  status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active','archived')),
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_sessions_updated ON sessions(updated_at);

CREATE TABLE IF NOT EXISTS messages (
  id TEXT PRIMARY KEY,
  session_id TEXT NOT NULL REFERENCES sessions(id) ON DELETE CASCADE,
  run_id TEXT,
  role TEXT NOT NULL CHECK (role IN ('user','assistant','system','tool')),
  content TEXT NOT NULL,
  content_type TEXT NOT NULL DEFAULT 'text',
  sequence INTEGER NOT NULL,
  created_at TEXT NOT NULL,
  UNIQUE(session_id, sequence)
);
CREATE INDEX IF NOT EXISTS idx_messages_session_created ON messages(session_id, created_at);

CREATE TABLE IF NOT EXISTS agent_runs (
  id TEXT PRIMARY KEY,
  session_id TEXT NOT NULL REFERENCES sessions(id) ON DELETE CASCADE,
  user_message_id TEXT NOT NULL REFERENCES messages(id),
  assistant_message_id TEXT REFERENCES messages(id),
  agent_id TEXT NOT NULL,
  trace_id TEXT NOT NULL,
  status TEXT NOT NULL CHECK (status IN ('queued','running','waiting_approval','completed','failed','cancelled')),
  model_provider TEXT NOT NULL,
  model_name TEXT NOT NULL,
  error_code TEXT,
  error_message TEXT,
  created_at TEXT NOT NULL,
  started_at TEXT,
  finished_at TEXT
);
CREATE INDEX IF NOT EXISTS idx_runs_session_created ON agent_runs(session_id, created_at);
CREATE INDEX IF NOT EXISTS idx_runs_status ON agent_runs(status, created_at);

CREATE TABLE IF NOT EXISTS agent_run_steps (
  id TEXT PRIMARY KEY,
  run_id TEXT NOT NULL REFERENCES agent_runs(id) ON DELETE CASCADE,
  step_index INTEGER NOT NULL,
  kind TEXT NOT NULL CHECK (kind IN ('model','tool','approval','system')),
  status TEXT NOT NULL CHECK (status IN ('started','completed','failed','denied','expired')),
  summary TEXT,
  payload_json TEXT,
  created_at TEXT NOT NULL,
  completed_at TEXT,
  UNIQUE(run_id, step_index)
);

CREATE TABLE IF NOT EXISTS jobs (
  id TEXT PRIMARY KEY,
  run_id TEXT NOT NULL REFERENCES agent_runs(id) ON DELETE CASCADE,
  agent_id TEXT NOT NULL,
  status TEXT NOT NULL CHECK (status IN ('pending','in_progress','completed','failed','cancelled')),
  attempt INTEGER NOT NULL DEFAULT 1,
  payload_json TEXT NOT NULL,
  picked_up_at TEXT,
  finished_at TEXT,
  error_code TEXT,
  error_message TEXT,
  created_at TEXT NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_jobs_claim ON jobs(agent_id, status, created_at);
CREATE INDEX IF NOT EXISTS idx_jobs_reaper ON jobs(status, picked_up_at);

CREATE TABLE IF NOT EXISTS events (
  id TEXT PRIMARY KEY,
  session_id TEXT NOT NULL REFERENCES sessions(id) ON DELETE CASCADE,
  run_id TEXT REFERENCES agent_runs(id) ON DELETE CASCADE,
  trace_id TEXT NOT NULL,
  sequence INTEGER NOT NULL,
  type TEXT NOT NULL,
  payload_json TEXT NOT NULL,
  created_at TEXT NOT NULL,
  UNIQUE(session_id, sequence)
);
CREATE INDEX IF NOT EXISTS idx_events_replay ON events(session_id, sequence);
CREATE INDEX IF NOT EXISTS idx_events_run ON events(run_id, sequence);

CREATE TABLE IF NOT EXISTS tools (
  id TEXT PRIMARY KEY,
  server_name TEXT NOT NULL,
  tool_name TEXT NOT NULL,
  policy TEXT NOT NULL CHECK (policy IN ('safe','approval_required','disabled')),
  schema_json TEXT NOT NULL,
  enabled INTEGER NOT NULL DEFAULT 1,
  discovered_at TEXT NOT NULL,
  UNIQUE(server_name, tool_name)
);

CREATE TABLE IF NOT EXISTS tool_calls (
  id TEXT PRIMARY KEY,
  run_id TEXT NOT NULL REFERENCES agent_runs(id) ON DELETE CASCADE,
  step_id TEXT REFERENCES agent_run_steps(id),
  agent_id TEXT NOT NULL,
  server_name TEXT NOT NULL,
  tool_name TEXT NOT NULL,
  args_json TEXT NOT NULL,
  args_hash TEXT NOT NULL,
  status TEXT NOT NULL CHECK (status IN ('requested','allowed','approval_required','completed','failed','denied')),
  result_summary TEXT,
  error_code TEXT,
  error_message TEXT,
  approval_id TEXT,
  duration_ms INTEGER,
  created_at TEXT NOT NULL,
  completed_at TEXT
);
CREATE INDEX IF NOT EXISTS idx_tool_calls_run ON tool_calls(run_id, created_at);

CREATE TABLE IF NOT EXISTS approvals (
  id TEXT PRIMARY KEY,
  run_id TEXT NOT NULL REFERENCES agent_runs(id) ON DELETE CASCADE,
  tool_call_id TEXT REFERENCES tool_calls(id),
  agent_id TEXT NOT NULL,
  tool_name TEXT NOT NULL,
  args_json TEXT NOT NULL,
  args_hash TEXT NOT NULL,
  status TEXT NOT NULL CHECK (status IN ('pending','approved','denied','expired','consumed')),
  approval_jti TEXT,
  approval_token TEXT,
  expires_at TEXT NOT NULL,
  decided_at TEXT,
  consumed_at TEXT,
  created_at TEXT NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_approvals_status ON approvals(status, expires_at);
CREATE UNIQUE INDEX IF NOT EXISTS idx_approvals_tool_call ON approvals(tool_call_id) WHERE tool_call_id IS NOT NULL;

CREATE TABLE IF NOT EXISTS audit_logs (
  id TEXT PRIMARY KEY,
  correlation_id TEXT,
  actor_type TEXT NOT NULL CHECK (actor_type IN ('client','runtime','mcp','system')),
  actor_id TEXT,
  action TEXT NOT NULL,
  target TEXT,
  payload_json TEXT,
  created_at TEXT NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_audit_action ON audit_logs(action, created_at);
CREATE INDEX IF NOT EXISTS idx_audit_correlation ON audit_logs(correlation_id, created_at);
