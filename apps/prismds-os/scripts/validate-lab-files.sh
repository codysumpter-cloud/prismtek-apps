#!/usr/bin/env bash
set -euo pipefail

PRISMDS_HOME="${PRISMDS_HOME:-$HOME/.local/share/prismds}"
LAB_ROOT="${PRISMDS_LAB_FILES:-$PRISMDS_HOME/data/lab-files}"
MIN_TOTAL_BYTES="${PRISMDS_MIN_LAB_BYTES:-1048576}"

mkdir -p "$LAB_ROOT"

file_count="$(find "$LAB_ROOT" -maxdepth 1 -type f | wc -l | tr -d ' ')"
total_bytes="$(find "$LAB_ROOT" -maxdepth 1 -type f -printf '%s\n' 2>/dev/null | awk '{sum += $1} END {print sum + 0}')"

printf 'PrismDS lab file check\n'
printf 'Folder: %s\n' "$LAB_ROOT"
printf 'Files: %s\n' "$file_count"
printf 'Total bytes: %s\n' "$total_bytes"

if [[ "$file_count" -eq 0 ]]; then
  printf 'No local lab files found.\n' >&2
  exit 1
fi

if [[ "$total_bytes" -lt "$MIN_TOTAL_BYTES" ]]; then
  printf 'Local lab files look incomplete: total bytes below %s.\n' "$MIN_TOTAL_BYTES" >&2
  exit 1
fi

printf 'Local lab files are present. PrismDS does not inspect or distribute them.\n'
