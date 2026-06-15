#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
if [ ! -x "$ROOT/.prismtek-tools/bin/node" ]; then
  "$ROOT/tools/bootstrap/bootstrap-node.sh"
fi
"$ROOT/.prismtek-tools/bin/node" "$ROOT/tools/bootstrap/toolchain.mjs" "$@"
