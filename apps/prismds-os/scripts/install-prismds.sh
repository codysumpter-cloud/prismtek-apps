#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PRISMDS_HOME="${PRISMDS_HOME:-$HOME/.local/share/prismds}"
BIN_DIR="$PRISMDS_HOME/bin"
CONFIG_DIR="$PRISMDS_HOME/configs"
DESKTOP_DIR="$HOME/.local/share/applications"
SYSTEMD_USER_DIR="$HOME/.config/systemd/user"

runtime_dirs=(
  "apps/azahar"
  "apps/lowlevel-3ds"
  "bios/3ds/local-system-files"
  "bin"
  "configs/emulationstation"
  "logs/prismds"
  "roms/3ds"
  "saves/3ds"
  "screenshots/3ds"
  "states/3ds"
  "tmp"
)

printf 'Installing PrismDS OS layer to %s\n' "$PRISMDS_HOME"
for dir in "${runtime_dirs[@]}"; do
  mkdir -p "$PRISMDS_HOME/$dir"
done
mkdir -p "$DESKTOP_DIR" "$SYSTEMD_USER_DIR"

cp "$APP_DIR/configs/prismds.config.json" "$CONFIG_DIR/prismds.config.json"
cp "$APP_DIR/configs/emulationstation/es_systems_3ds.xml" "$CONFIG_DIR/emulationstation/es_systems_3ds.xml"
cp "$APP_DIR/configs/desktop/prismds.desktop" "$DESKTOP_DIR/prismds.desktop"
cp "$APP_DIR/configs/systemd/prismds-session.service" "$SYSTEMD_USER_DIR/prismds-session.service"

install -m 0755 "$APP_DIR/scripts/launch-azahar.sh" "$BIN_DIR/prismds-launch-azahar.sh"
install -m 0755 "$APP_DIR/scripts/launch-lowlevel-3ds.sh" "$BIN_DIR/prismds-launch-lowlevel-3ds.sh"
install -m 0755 "$APP_DIR/scripts/performance-mode.sh" "$BIN_DIR/prismds-performance-mode.sh"
install -m 0755 "$APP_DIR/scripts/validate-local-3ds-lab-files.sh" "$BIN_DIR/prismds-validate-local-3ds-lab-files.sh"

cat > "$BIN_DIR/prismds-session.sh" <<'SESSION'
#!/usr/bin/env bash
set -euo pipefail
PRISMDS_HOME="${PRISMDS_HOME:-$HOME/.local/share/prismds}"
if command -v emulationstation >/dev/null 2>&1; then
  exec emulationstation --systems "$PRISMDS_HOME/configs/emulationstation/es_systems_3ds.xml"
fi
printf 'EmulationStation not found. Launching Azahar fallback.\n' >&2
exec "$PRISMDS_HOME/bin/prismds-launch-azahar.sh"
SESSION
chmod 0755 "$BIN_DIR/prismds-session.sh"

if command -v systemctl >/dev/null 2>&1; then
  systemctl --user daemon-reload || true
fi

cat <<EOF
PrismDS installed.

Next steps:
1. Put Azahar at: $PRISMDS_HOME/apps/azahar/Azahar.AppImage
2. Put your 3DS content at: $PRISMDS_HOME/roms/3ds
3. Optional low-level lab binary: $PRISMDS_HOME/apps/lowlevel-3ds/emulator
4. Run: $BIN_DIR/prismds-launch-azahar.sh

This installer does not flash firmware and does not install copyrighted content.
EOF
