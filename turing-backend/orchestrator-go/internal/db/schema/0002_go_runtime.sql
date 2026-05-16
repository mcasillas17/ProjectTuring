ALTER TABLE agent_runs ADD COLUMN cancellation_reason TEXT;
ALTER TABLE agent_runs ADD COLUMN worker_id TEXT;
ALTER TABLE jobs ADD COLUMN lease_owner TEXT;
ALTER TABLE jobs ADD COLUMN lease_expires_at TEXT;

CREATE INDEX IF NOT EXISTS idx_jobs_lease ON jobs(status, lease_expires_at);
