#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
LOG_PRETTY=1 docker compose -f infra/docker-compose.yml up --build
