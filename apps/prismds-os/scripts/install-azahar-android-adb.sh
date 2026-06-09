#!/usr/bin/env bash
set -euo pipefail

APK_PATH="${1:-}"
PACKAGE_HINT="${AZAHAR_PACKAGE_HINT:-io.github.azahar_emu.azahar}"

if [[ -z "$APK_PATH" ]]; then
  printf 'Usage: %s /path/to/Azahar.apk\n' "$0" >&2
  exit 2
fi

if [[ ! -f "$APK_PATH" ]]; then
  printf 'APK not found: %s\n' "$APK_PATH" >&2
  exit 1
fi

if ! command -v adb >/dev/null 2>&1; then
  printf 'adb is required but was not found in PATH.\n' >&2
  exit 1
fi

printf 'Checking connected Android devices...\n'
adb devices

printf 'Installing APK: %s\n' "$APK_PATH"
adb install -r "$APK_PATH"

cat <<EOF
Azahar install command completed.

Useful follow-up commands:
  adb shell pm list packages | grep -i azahar
  adb shell monkey -p $PACKAGE_HINT 1

This helper does not download APKs and does not install games.
EOF
