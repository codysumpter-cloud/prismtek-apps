#!/usr/bin/env bash
set -euo pipefail

MODE="${1:-on}"
GOVERNOR="${PRISMDS_CPU_GOVERNOR:-performance}"
NICE_VALUE="${PRISMDS_NICE:- -5}"

printf 'PrismDS performance helper: %s\n' "$MODE"

set_governor() {
  local gov="$1"
  local changed=0
  for policy in /sys/devices/system/cpu/cpufreq/policy*; do
    [[ -e "$policy/scaling_governor" ]] || continue
    if [[ -w "$policy/scaling_governor" ]]; then
      printf '%s' "$gov" > "$policy/scaling_governor" || true
      changed=$((changed + 1))
    fi
  done
  printf 'Governor targets updated: %s\n' "$changed"
}

case "$MODE" in
  on)
    set_governor "$GOVERNOR"
    printf 'Suggested launch wrapper: nice -n %s ionice -c2 -n0 <command>\n' "$NICE_VALUE"
    ;;
  off)
    set_governor "schedutil"
    ;;
  status)
    for policy in /sys/devices/system/cpu/cpufreq/policy*; do
      [[ -e "$policy/scaling_governor" ]] || continue
      printf '%s: ' "$policy"
      cat "$policy/scaling_governor"
    done
    ;;
  *)
    printf 'Usage: %s [on|off|status]\n' "$0" >&2
    exit 2
    ;;
esac
