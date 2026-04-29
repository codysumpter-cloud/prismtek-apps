#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_FILE="$ROOT_DIR/mlc-package-config.json"

cd "$ROOT_DIR"

if ! command -v mlc_llm >/dev/null 2>&1; then
  cat >&2 <<'EOF'
::error title=Missing mlc_llm::Install MLC LLM in the active Python environment before packaging.
Suggested setup:
  python3 -m pip install --upgrade pip
  python3 -m pip install --pre -U mlc-llm -f https://mlc.ai/wheels
EOF
  exit 127
fi

if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "::error title=Missing MLC package config::$CONFIG_FILE not found." >&2
  exit 66
fi

mlc_llm package --package-config "$CONFIG_FILE"

"$ROOT_DIR/scripts/verify-mlc-runtime-artifacts.sh" "$ROOT_DIR/dist/lib" "$ROOT_DIR/dist/bundle"

cat <<'EOF'

MLC package complete.
Next:
  ./scripts/enable-mlc-runtime-link.sh
  xcodegen generate
  xcodebuild -project BeMoreAgent.xcodeproj -scheme BeMoreAgent -configuration Debug -destination 'generic/platform=iOS' CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO build
EOF
