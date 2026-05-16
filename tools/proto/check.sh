#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
before="$(git -C "$ROOT" status --porcelain -- gen proto)"
"$ROOT/tools/proto/generate.sh"
after="$(git -C "$ROOT" status --porcelain -- gen proto)"

if [[ "$before" != "$after" ]]; then
  echo "generated proto output is not deterministic or not committed" >&2
  git -C "$ROOT" --no-pager status --short -- gen proto >&2
  exit 1
fi
