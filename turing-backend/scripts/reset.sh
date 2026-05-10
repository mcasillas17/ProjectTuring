#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
read -r -p "Delete Project Turing local data and regenerate .env? Type RESET: " answer
if [[ "$answer" != "RESET" ]]; then
  echo "Reset cancelled."
  exit 1
fi
docker compose -f infra/docker-compose.yml down --remove-orphans || true
rm -rf data .runtime .env
mkdir -p data sandbox
./scripts/init.sh
