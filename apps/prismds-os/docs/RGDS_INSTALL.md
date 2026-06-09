# RGDS install guide

This guide installs PrismDS as a reversible userland layer on the RGDS Linux side.

## 1. Copy repo or app folder to RGDS

From the repo root on RGDS Linux:

```bash
cd apps/prismds-os
node tools/prismds.mjs check
```

## 2. Install PrismDS layer

```bash
bash scripts/install-prismds.sh
```

Default install root:

```text
~/.local/share/prismds
```

Override it with:

```bash
PRISMDS_HOME=/path/to/prismds bash scripts/install-prismds.sh
```

## 3. Add emulator binaries

PrismDS does not bundle emulator binaries. Add your own trusted builds:

```text
~/.local/share/prismds/apps/azahar/Azahar.AppImage
~/.local/share/prismds/apps/lowlevel-3ds/emulator
```

Make them executable:

```bash
chmod +x ~/.local/share/prismds/apps/azahar/Azahar.AppImage
chmod +x ~/.local/share/prismds/apps/lowlevel-3ds/emulator
```

## 4. Add your content

```text
~/.local/share/prismds/roms/3ds/
```

For low-level lab experiments, follow the upstream emulator documentation and place local-only system files here:

```text
~/.local/share/prismds/bios/3ds/local-system-files/
```

## 5. Launch

```bash
~/.local/share/prismds/bin/prismds-launch-azahar.sh
```

With a specific file:

```bash
~/.local/share/prismds/bin/prismds-launch-azahar.sh ~/.local/share/prismds/roms/3ds/example.3ds
```

Low-level lab launcher:

```bash
~/.local/share/prismds/bin/prismds-launch-lowlevel-3ds.sh
```

## 6. Diagnose

```bash
node tools/prismds.mjs doctor
~/.local/share/prismds/bin/prismds-validate-local-3ds-lab-files.sh
```

## 7. Remove launcher layer

```bash
bash scripts/uninstall-prismds.sh
```

The uninstall script removes PrismDS launchers and configs but intentionally keeps user content, saves, states, screenshots, and local lab files.
