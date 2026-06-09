#!/usr/bin/env bash
set -euo pipefail

PRISMDS_HOME="${PRISMDS_HOME:-$HOME/.local/share/prismds}"
DESKTOP_FILE="$HOME/.local/share/applications/prismds.desktop"

cat <<EOF
Removing PrismDS launchers and configs.

Install root: $PRISMDS_HOME
User content is intentionally kept:
- roms/
- saves/
- states/
- screenshots/
- bios/
EOF

rm -f "$DESKTOP_FILE"
rm -f "$PRISMDS_HOME/bin/prismds-launch-azahar.sh"
rm -f "$PRISMDS_HOME/bin/prismds-launch-lowlevel-3ds.sh"
rm -f "$PRISMDS_HOME/bin/prismds-performance-mode.sh"
rm -f "$PRISMDS_HOME/bin/prismds-validate-local-3ds-lab-files.sh"
rm -f "$PRISMDS_HOME/bin/prismds-session.sh"
rm -f "$PRISMDS_HOME/configs/prismds.config.json"
rm -f "$PRISMDS_HOME/configs/emulationstation/es_systems_3ds.xml"

rmdir "$PRISMDS_HOME/configs/emulationstation" 2>/dev/null || true
rmdir "$PRISMDS_HOME/configs" 2>/dev/null || true
rmdir "$PRISMDS_HOME/bin" 2>/dev/null || true

printf 'PrismDS launcher/config uninstall complete. User content was left in place.\n'
