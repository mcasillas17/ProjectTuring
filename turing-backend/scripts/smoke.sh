#!/usr/bin/env bash
set -euo pipefail

# smoke.sh
#
# End-to-end Docker smoke test for Project Turing v1.0.
# Part of Task 16: End-to-end Docker smoke and local documentation.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/.."

echo "[Smoke] Starting Project Turing smoke test..."

# 0. Check prerequisites
if [[ ! -f scripts/init.sh ]]; then
  echo "[Error] scripts/init.sh not found. Upstream Task 1 might not be merged."
  exit 1
fi

if [[ ! -f infra/docker-compose.yml ]]; then
  echo "[Error] infra/docker-compose.yml not found. Upstream Task 1 might not be merged."
  exit 1
fi

# 1. Initialize backend secrets
echo "[Smoke] Initializing backend secrets..."
mkdir -p .runtime
./scripts/init.sh > .runtime/turing-init.log

# 2. Start Docker Compose
echo "[Smoke] Starting Docker Compose..."
docker compose -f infra/docker-compose.yml up --build -d

# Cleanup on exit
trap "docker compose -f infra/docker-compose.yml down" EXIT

# 3. Wait for orchestrator to be healthy
echo "[Smoke] Waiting for orchestrator to be healthy..."
MAX_RETRIES=30
RETRY_COUNT=0
while ! curl -s http://localhost:3000/health > /dev/null; do
  if [[ $RETRY_COUNT -eq $MAX_RETRIES ]]; then
    echo "[Error] Orchestrator failed to become healthy within 30 seconds."
    docker compose -f infra/docker-compose.yml logs turing-orchestrator
    exit 1
  fi
  sleep 1
  ((RETRY_COUNT++))
done
echo "[Smoke] Orchestrator is healthy."

# 4. Extract API key
api_key="$(grep '^TURING_CLIENT_API_KEY=' .env | cut -d= -f2-)"

# 5. Check REST API endpoints
echo "[Smoke] Checking /api/config..."
curl --fail -s -H "Authorization: Bearer ${api_key}" http://localhost:3000/api/config | grep -q "providers"

echo "[Smoke] Creating a session..."
session_json="$(curl --fail -s -H "Authorization: Bearer ${api_key}" -H "content-type: application/json" -d '{"title":"Smoke Test Session"}' http://localhost:3000/api/sessions)"
session_id="$(node -e "console.log(JSON.parse(process.argv[1]).sessionId)" "$session_json")"
echo "[Smoke] Created session: ${session_id}"

echo "[Smoke] Sending a message..."
message_json="$(curl --fail -s \
  -H "Authorization: Bearer ${api_key}" \
  -H "content-type: application/json" \
  -d '{"content":"Say hello from Project Turing smoke test","modelProvider":"ollama"}' \
  "http://localhost:3000/api/sessions/${session_id}/messages")"
run_id="$(node -e "console.log(JSON.parse(process.argv[1]).runId)" "$message_json")"
echo "[Smoke] Queued run: ${run_id}"

# 6. Run WebSocket smoke test
echo "[Smoke] Running WebSocket smoke test..."
# Ensure ws is installed for the smoke script
if [[ ! -d node_modules/ws ]]; then
  echo "[Smoke] Installing 'ws' dependency for smoke test..."
  npm install ws --no-save
fi
node scripts/smoke-ws.mjs "${api_key}" "${session_id}" "${run_id}"

# 7. Check Audit and Tool-calls
echo "[Smoke] Checking /api/audit..."
curl --fail -s -H "Authorization: Bearer ${api_key}" "http://localhost:3000/api/audit" | node -e "const data = JSON.parse(require('fs').readFileSync(0, 'utf8')); if (!data.entries) throw new Error('No entries in audit'); console.log('Audit endpoint OK')"

echo "[Smoke] Checking /api/tool-calls..."
curl --fail -s -H "Authorization: Bearer ${api_key}" "http://localhost:3000/api/tool-calls" | node -e "const data = JSON.parse(require('fs').readFileSync(0, 'utf8')); if (!data.toolCalls) throw new Error('No toolCalls in response'); console.log('Tool-call endpoint OK')"

echo "[Smoke] SUCCESS: Smoke test completed for session ${session_id}"
