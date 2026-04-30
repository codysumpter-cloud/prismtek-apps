#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MODEL_ID="gemma-4-E2B-it-q4f16_1-MLC"
REPO_ID="welcoma/gemma-4-E2B-it-q4f16_1-MLC"
DEST_DIR="$ROOT_DIR/BundledModels/$MODEL_ID"
CACHE_ROOT="${BEMORE_MODEL_CACHE_DIR:-${HOME:-/tmp}/.cache/bemoreagent/models}"
CACHE_DIR="$CACHE_ROOT/$MODEL_ID"
TMP_DIR="${RUNNER_TEMP:-${TMPDIR:-/tmp}}"
FILE_LIST="$TMP_DIR/bemoreagent-gemma4-mlc-model-files.txt"

mkdir -p "$DEST_DIR" "$CACHE_DIR" "$TMP_DIR"

python3 - "$REPO_ID" "$FILE_LIST" <<'PY'
import json
import sys
import urllib.request

repo_id, output_path = sys.argv[1], sys.argv[2]
api_url = f"https://huggingface.co/api/models/{repo_id}/tree/main"
fallback = [
    "mlc-chat-config.json",
    "tensor-cache.json",
    "tokenizer.json",
    "tokenizer.model",
    "tokenizer_config.json",
    "release-manifest.json",
] + [f"params_shard_{index}.bin" for index in range(42)]

package_files = {
    "mlc-chat-config.json",
    "tensor-cache.json",
    "tokenizer.json",
    "tokenizer.model",
    "tokenizer_config.json",
    "release-manifest.json",
}

try:
    with urllib.request.urlopen(api_url, timeout=30) as response:
        items = json.load(response)
    files = sorted(
        item["path"]
        for item in items
        if item.get("type", "file") == "file"
        and "/" not in item.get("path", "")
        and (
            item["path"] in package_files
            or (item["path"].startswith("params_shard_") and item["path"].endswith(".bin"))
        )
    )
except Exception as error:
    print(f"warning: could not resolve Hugging Face tree, using fallback list: {error}", file=sys.stderr)
    files = fallback

if not files:
    files = fallback

with open(output_path, "w", encoding="utf-8") as handle:
    handle.write("\n".join(files))
    handle.write("\n")
PY

missing_count=0
while IFS= read -r filename; do
  test -n "$filename" || continue
  cached="$CACHE_DIR/$filename"
  if [[ ! -s "$cached" ]]; then
    missing_count=$((missing_count + 1))
  fi
done < "$FILE_LIST"

echo "Bundled Gemma 4 persistent cache: $CACHE_DIR"
echo "Bundled Gemma 4 cache check: $missing_count missing file(s)."

while IFS= read -r filename; do
  test -n "$filename" || continue
  cached="$CACHE_DIR/$filename"
  partial="$cached.partial"
  url="https://huggingface.co/$REPO_ID/resolve/main/$filename"
  mkdir -p "$(dirname "$cached")"

  if [[ -s "$cached" ]]; then
    echo "Cached model file already present: $filename"
    continue
  fi

  echo "Downloading bundled Gemma 4 model file to persistent cache: $filename"
  rm -f "$partial"
  curl \
    --fail \
    --location \
    --retry 10 \
    --retry-delay 5 \
    --retry-max-time 1200 \
    --connect-timeout 30 \
    --max-time 2400 \
    --speed-time 120 \
    --speed-limit 1024 \
    --output "$partial" \
    "$url"

  test -s "$partial"
  mv "$partial" "$cached"
done < "$FILE_LIST"

rm -rf "$DEST_DIR"
mkdir -p "$DEST_DIR"
while IFS= read -r filename; do
  test -n "$filename" || continue
  cached="$CACHE_DIR/$filename"
  target="$DEST_DIR/$filename"
  test -s "$cached"
  mkdir -p "$(dirname "$target")"
  cp "$cached" "$target"
done < "$FILE_LIST"

for required in mlc-chat-config.json tokenizer.json tokenizer.model tokenizer_config.json params_shard_0.bin; do
  test -f "$DEST_DIR/$required"
  test -f "$CACHE_DIR/$required"
done

echo "Prepared bundled Gemma 4 MLC model at $DEST_DIR"
