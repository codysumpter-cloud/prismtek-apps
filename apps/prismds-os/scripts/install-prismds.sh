#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PRISMDS_HOME="${PRISMDS_HOME:-$HOME/.local/share/prismds}"
BIN_DIR="$PRISMDS_HOME/bin"
CONFIG_DIR="$PRISMDS_HOME/configs"
DESKTOP_DIR="$HOME/.local/share/applications"

runtime_dirs=(
  "apps/azahar"
  "apps/lab"
  "data/lab-files"
  "bin"
  "configs/emulationstation"
  "logs/prismds"
  "roms/3ds"
  "saves/3ds"
  "screenshots/3ds"
  "states/3ds"
  "tmp"
)

printf 'Installing PrismDS layer to %s\n' "$PRISMDS_HOME"
for dir in "${runtime_dirs[@]}"; do
  mkdir -p "$PRISMDS_HOME/$dir"
done
mkdir -p "$DESKTOP_DIR"

cp "$APP_DIR/configs/prismds.config.json" "$CONFIG_DIR/prismds.config.json"
cp "$APP_DIR/configs/emulationstation/es_systems_3ds.xml" "$CONFIG_DIR/emulationstation/es_systems_3ds.xml"
cp "$APP_DIR/configs/desktop/prismds.desktop" "$DESKTOP_DIR/prismds.desktop"

install -m 0755 "$APP_DIR/scripts/launch-azahar.sh" "$BIN_DIR/prismds-launch-azahar.sh"
install -m 0755 "$APP_DIR/scripts/launch-lab.sh" "$BIN_DIR/prismds-launch-lab.sh"
install -m 0755 "$APP_DIR/scripts/performance-mode.sh" "$BIN_DIR/prismds-performance-mode.sh"
install -m 0755 "$APP_DIR/scripts/validate-lab-files.sh" "$BIN_DIR/prismds-validate-lab-files.sh"

cat > "$BIN_DIR/prismds-session.sh" <<'SESSION'
#!/usr/bin/env bash
set -euo pipefail
PRISMDS_HOME="${PRISMDS_HOME:-$HOME/.local/share/prismds}"
if command -v emulationstation >/dev/null 2>&1; then
  emulationstation --systems "$PRISMDS_HOME/configs/emulationstation/es_systems_3ds.xml"
else
  printf 'EmulationStation not found. Use prismds-launch-azahar.sh directly.\n' >&2
fi
SESSION
chmod 0755 "$BIN_DIR/prismds-session.sh"

printf 'PrismDS installed.\n'
printf 'Add Azahar at: %s\n' "$PRISMDS_HOME/apps/azahar/Azahar.AppImage"
printf 'Add game files at: %s\n' "$PRISMDS_HOME/roms/3ds"
printf 'Optional lab executable: %s\n' "$PRISMDS_HOME/apps/lab/emulator"
