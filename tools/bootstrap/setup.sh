#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
"$ROOT/tools/bootstrap/bootstrap-node.sh"
"$ROOT/tools/bootstrap/npm.sh" install
"$ROOT/tools/bootstrap/npm.sh" run platforms:validate
"$ROOT/tools/bootstrap/npm.sh" run games:validate-support
