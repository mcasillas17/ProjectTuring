#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
if [[ ! -f .env ]]; then
  echo ".env missing; run scripts/init.sh first" >&2
  exit 1
fi
new_key="tk_$(openssl rand -hex 32)"
sed -i.bak "s|^TURING_CLIENT_API_KEY=.*|TURING_CLIENT_API_KEY=${new_key}|" .env
rm -f .env.bak
printf 'New Flutter client API key: %s\n' "$new_key"
