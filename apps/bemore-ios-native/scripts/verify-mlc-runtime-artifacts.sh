#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LIB_DIR="${1:-$ROOT_DIR/dist/lib}"
BUNDLE_DIR="${2:-$ROOT_DIR/dist/bundle}"
CONFIG_FILE="$ROOT_DIR/Config/MLCRuntime.xcconfig"

required_libs=(
  libmodel_iphone.a
  libmlc_llm.a
  libtvm_runtime.a
  libtokenizers_cpp.a
  libtokenizers_c.a
  libsentencepiece.a
)

missing=0
for lib in "${required_libs[@]}"; do
  if [[ ! -f "$LIB_DIR/$lib" ]]; then
    echo "::error title=Missing MLC runtime library::$LIB_DIR/$lib is required. Run mlc_llm package from apps/bemore-ios-native." >&2
    missing=1
  fi
done

if [[ ! -f "$BUNDLE_DIR/mlc-app-config.json" ]]; then
  echo "::warning title=Missing MLC bundle config::$BUNDLE_DIR/mlc-app-config.json was not found. This is acceptable only if weights are downloaded at runtime and app config is not bundled."
fi

if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "::error title=Missing MLC xcconfig::$CONFIG_FILE was not found." >&2
  missing=1
fi

if [[ "$missing" -ne 0 ]]; then
  exit 66
fi

echo "MLC runtime artifacts verified in $LIB_DIR"
