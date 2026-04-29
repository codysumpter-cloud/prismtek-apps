#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MODEL_ID="gemma-2-2b-it-q4f16_1-MLC"
REPO_ID="mlc-ai/gemma-2-2b-it-q4f16_1-MLC"
DEST_DIR="$ROOT_DIR/BundledModels/$MODEL_ID"
TMP_DIR="${RUNNER_TEMP:-${TMPDIR:-/tmp}}"
FILE_LIST="$TMP_DIR/bemoreagent-mlc-model-files.txt"

mkdir -p "$DEST_DIR" "$TMP_DIR"

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
] + [f"params_shard_{index}.bin" for index in range(42)]

try:
    with urllib.request.urlopen(api_url, timeout=30) as response:
        items = json.load(response)
    files = sorted(
        item["path"]
        for item in items
        if item.get("type", "file") == "file"
        and "/" not in item.get("path", "")
        and (
            item["path"] in {
                "mlc-chat-config.json",
                "tensor-cache.json",
                "tokenizer.json",
                "tokenizer.model",
                "tokenizer_config.json",
            }
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

while IFS= read -r filename; do
  test -n "$filename" || continue
  target="$DEST_DIR/$filename"
  url="https://huggingface.co/$REPO_ID/resolve/main/$filename"
  mkdir -p "$(dirname "$target")"
  if [[ -s "$target" ]]; then
    echo "Bundled model file already present: $filename"
    continue
  fi
  echo "Downloading bundled model file: $filename"
  curl --fail --location --retry 5 --retry-delay 2 --continue-at - --output "$target" "$url"
done < "$FILE_LIST"

for required in mlc-chat-config.json tokenizer.json tokenizer.model tokenizer_config.json params_shard_0.bin; do
  test -f "$DEST_DIR/$required"
done

echo "Prepared bundled MLC model at $DEST_DIR"
