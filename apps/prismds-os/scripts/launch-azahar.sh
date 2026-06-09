#!/usr/bin/env bash
set -euo pipefail

PRISMDS_HOME="${PRISMDS_HOME:-$HOME/.local/share/prismds}"
AZAHAR_BIN="${AZAHAR_BIN:-$PRISMDS_HOME/apps/azahar/Azahar.AppImage}"
LOG_DIR="$PRISMDS_HOME/logs/prismds"
mkdir -p "$LOG_DIR"

if [[ ! -x "$AZAHAR_BIN" ]]; then
  printf 'Azahar executable not found: %s\n' "$AZAHAR_BIN" >&2
  printf 'Place the executable there or set AZAHAR_BIN.\n' >&2
  exit 1
fi

export PRISMDS_HOME
export XDG_DATA_HOME="${XDG_DATA_HOME:-$PRISMDS_HOME}"
"$AZAHAR_BIN" "$@" 2>&1 | tee -a "$LOG_DIR/azahar.log"
