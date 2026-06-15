#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
if [ ! -x "$ROOT/.prismtek-tools/bin/node" ]; then
  "$ROOT/tools/bootstrap/bootstrap-node.sh"
fi
export PATH="$ROOT/.prismtek-tools/bin:$PATH"
exec "$ROOT/.prismtek-tools/bin/node" "$@"
