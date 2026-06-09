#!/usr/bin/env bash
set -euo pipefail

PRISMDS_HOME="${PRISMDS_HOME:-$HOME/.local/share/prismds}"
LAB_BIN="${LOWLEVEL_3DS_BIN:-$PRISMDS_HOME/apps/lowlevel-3ds/emulator}"
LOG_DIR="$PRISMDS_HOME/logs/prismds"
mkdir -p "$LOG_DIR"

if [[ ! -x "$LAB_BIN" ]]; then
  printf 'Low-level 3DS lab executable not found: %s\n' "$LAB_BIN" >&2
  printf 'Place a compatible emulator build there or set LOWLEVEL_3DS_BIN.\n' >&2
  exit 1
fi

export PRISMDS_HOME
export PRISMDS_LOCAL_SYSTEM_FILES="$PRISMDS_HOME/bios/3ds/local-system-files"
"$LAB_BIN" "$@" 2>&1 | tee -a "$LOG_DIR/lowlevel-3ds.log"
