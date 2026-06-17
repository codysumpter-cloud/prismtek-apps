#!/usr/bin/env bash
set -euo pipefail

PRISMDS_HOME="${PRISMDS_HOME:-$HOME/.local/share/prismds}"
LAB_BIN="${PRISMDS_LAB_BIN:-$PRISMDS_HOME/apps/lab/emulator}"
LOG_DIR="$PRISMDS_HOME/logs/prismds"
mkdir -p "$LOG_DIR"

if [[ ! -x "$LAB_BIN" ]]; then
  printf 'Lab executable not found: %s\n' "$LAB_BIN" >&2
  printf 'Place a compatible build there or set PRISMDS_LAB_BIN.\n' >&2
  exit 1
fi

export PRISMDS_HOME
"$LAB_BIN" "$@" 2>&1 | tee -a "$LOG_DIR/lab.log"
