# RGDS install guide

This guide installs PrismDS as a reversible userland layer on the RGDS Linux side.

## 1. Validate the repo package

From the repo root:

```bash
cd apps/prismds-os
node tools/prismds.mjs check
```

## 2. Install the PrismDS layer

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
~/.local/share/prismds/apps/lab/emulator
```

Make them executable:

```bash
chmod +x ~/.local/share/prismds/apps/azahar/Azahar.AppImage
chmod +x ~/.local/share/prismds/apps/lab/emulator
```

## 4. Add content

```text
~/.local/share/prismds/roms/3ds/
```

For lab experiments, follow the upstream emulator documentation and place local-only inputs here:

```text
~/.local/share/prismds/data/lab-files/
```

## 5. Launch

```bash
~/.local/share/prismds/bin/prismds-launch-azahar.sh
```

With a specific file:

```bash
~/.local/share/prismds/bin/prismds-launch-azahar.sh ~/.local/share/prismds/roms/3ds/example.3ds
```

Lab launcher:

```bash
~/.local/share/prismds/bin/prismds-launch-lab.sh
```

## 6. Diagnose

```bash
node tools/prismds.mjs doctor
~/.local/share/prismds/bin/prismds-validate-lab-files.sh
```

## 7. Remove launcher layer

```bash
bash scripts/uninstall-prismds.sh
```

The uninstall script removes PrismDS launchers and configs but intentionally keeps user content, saves, states, screenshots, and lab files.
