#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
MANIFEST="$ROOT_DIR/tools/porting-kits/porting-kits.manifest.json"
DOWNLOAD_ROOT="${PRISMTEK_PORTING_KITS_DIR:-$ROOT_DIR/.porting-kits}"
CHECKSUM_FILE="$DOWNLOAD_ROOT/SHA256SUMS.txt"

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

fetch() {
  local url="$1"
  local dest="$2"
  mkdir -p "$(dirname "$dest")"
  if command_exists curl; then
    curl -fL --retry 3 --connect-timeout 20 -o "$dest" "$url"
  elif command_exists wget; then
    wget -O "$dest" "$url"
  else
    echo "Missing curl or wget; cannot download $url" >&2
    return 1
  fi
}

sha256_one() {
  local file="$1"
  if command_exists sha256sum; then
    sha256sum "$file"
  elif command_exists shasum; then
    shasum -a 256 "$file"
  else
    echo "No sha256sum or shasum available; skipping checksum for $file" >&2
  fi
}

if ! command_exists node; then
  echo "Node.js is required to read $MANIFEST. Install Node.js LTS first." >&2
  exit 1
fi

mkdir -p "$DOWNLOAD_ROOT"
: > "$CHECKSUM_FILE"

echo "Using manifest: $MANIFEST"
echo "Download root:  $DOWNLOAD_ROOT"

node --input-type=module - "$MANIFEST" <<'NODE' | while IFS=$'\t' read -r id url destination review_required; do
import fs from 'node:fs';
const manifestPath = process.argv[2];
const manifest = JSON.parse(fs.readFileSync(manifestPath, 'utf8'));
for (const kit of manifest.kits ?? []) {
  for (const source of kit.sources ?? []) {
    if (source.automated && source.destination) {
      console.log([source.id, source.url, source.destination, source.reviewRequired ? 'review-required' : 'review-normal'].join('\t'));
    }
  }
}
NODE
  dest="$DOWNLOAD_ROOT/$destination"
  if [[ -f "$dest" ]]; then
    echo "Already downloaded: $destination"
  else
    echo "Downloading $id -> $destination"
    fetch "$url" "$dest"
  fi
  sha256_one "$dest" >> "$CHECKSUM_FILE" || true
  if [[ "$review_required" == "review-required" ]]; then
    echo "Review required before use: $destination"
  fi
done

echo "Wrote checksums: $CHECKSUM_FILE"
echo "Next: npm run porting-kits:verify"
