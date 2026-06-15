#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
VERSION="$(tr -d '[:space:]' < "$ROOT/tools/bootstrap/node-version.txt")"
TOOLS_DIR="$ROOT/.prismtek-tools"
NODE_HOME="$TOOLS_DIR/node-v$VERSION"
BIN_DIR="$TOOLS_DIR/bin"

machine="$(uname -m)"
os="$(uname -s)"
case "$os:$machine" in
  Darwin:arm64) platform="darwin-arm64" ;;
  Darwin:x86_64) platform="darwin-x64" ;;
  Linux:aarch64|Linux:arm64) platform="linux-arm64" ;;
  Linux:x86_64) platform="linux-x64" ;;
  *) echo "Unsupported platform: $os $machine" >&2; exit 1 ;;
esac

archive="node-v$VERSION-$platform.tar.xz"
url="https://nodejs.org/dist/v$VERSION/$archive"
mkdir -p "$TOOLS_DIR" "$BIN_DIR"

if [ ! -x "$NODE_HOME/bin/node" ]; then
  tmp="$TOOLS_DIR/$archive"
  echo "Downloading Node.js v$VERSION for $platform..."
  if command -v curl >/dev/null 2>&1; then
    curl -fL "$url" -o "$tmp"
  elif command -v wget >/dev/null 2>&1; then
    wget -O "$tmp" "$url"
  else
    echo "curl or wget is required to bootstrap repo-local Node." >&2
    exit 1
  fi
  rm -rf "$NODE_HOME" "$TOOLS_DIR/node-v$VERSION-$platform"
  tar -xJf "$tmp" -C "$TOOLS_DIR"
  mv "$TOOLS_DIR/node-v$VERSION-$platform" "$NODE_HOME"
  rm -f "$tmp"
fi

cat > "$BIN_DIR/node" <<EOF
#!/usr/bin/env bash
exec "$NODE_HOME/bin/node" "\$@"
EOF
cat > "$BIN_DIR/npm" <<EOF
#!/usr/bin/env bash
exec "$NODE_HOME/bin/npm" "\$@"
EOF
cat > "$BIN_DIR/npx" <<EOF
#!/usr/bin/env bash
exec "$NODE_HOME/bin/npx" "\$@"
EOF
chmod +x "$BIN_DIR/node" "$BIN_DIR/npm" "$BIN_DIR/npx"

echo "Repo-local Node ready: $($BIN_DIR/node -v)"
echo "Repo-local npm ready: $($BIN_DIR/npm -v)"
echo "Use: ./tools/bootstrap/npm.sh install"
