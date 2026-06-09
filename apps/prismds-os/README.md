# PrismDS OS for RGDS

PrismDS is an RGDS-first operating layer for turning the Anbernic RG DS into a dual-screen 3DS emulation workstation.

It is **not** a bootloader replacement and it does **not** flash firmware. It installs a structured launcher environment, emulator profiles, validation tools, frontend configuration, performance helpers, desktop/session entries, and Android helper scripts on top of the stock Linux/Android environment.

## Goals

- Make **Azahar** the practical first 3DS path on RGDS.
- Keep **3Beans** available as a low-level 3DS system-emulation lab target.
- Use the RGDS dual-screen form factor intentionally.
- Keep everything reversible and non-destructive.
- Avoid shipping copyrighted Nintendo firmware, keys, NAND, games, or BIOS files.

## What is functional now

- Installable Linux-side folder layout under `~/.local/share/prismds` by default.
- RGDS hardware profile and emulator capability metadata.
- Launch scripts for Azahar and 3Beans.
- Dump validator for 3Beans-required files.
- Root-optional performance helper.
- Android ADB helper for side-loading an Azahar APK you provide.
- EmulationStation system config for a 3DS collection.
- Desktop entries and a systemd user service template.
- Dependency-free Node CLI for `check`, `build`, `doctor`, and install-plan output.

## What this does not do yet

- It does not include Azahar or 3Beans binaries.
- It does not include ROMs, keys, NAND, firmware, or copyrighted assets.
- It does not replace the RGDS kernel, bootloader, DTB, or vendor OS image.
- It does not promise playable 3DS speed on RK3568.

## Quick start on RGDS Linux

```bash
cd apps/prismds-os
npm run check
bash scripts/install-prismds.sh
node tools/prismds.mjs doctor
```

After installing, place emulator binaries here:

```text
~/.local/share/prismds/apps/azahar/Azahar.AppImage
~/.local/share/prismds/apps/3beans/3Beans
```

Place 3DS content here:

```text
~/.local/share/prismds/roms/3ds/
~/.local/share/prismds/bios/3ds/3beans/boot9.bin
~/.local/share/prismds/bios/3ds/3beans/boot11.bin
~/.local/share/prismds/bios/3ds/3beans/nand.bin
```

Then launch:

```bash
~/.local/share/prismds/bin/prismds-launch-azahar.sh
~/.local/share/prismds/bin/prismds-launch-3beans.sh
```

## Android-side Azahar helper

From a computer with ADB and your RGDS connected:

```bash
bash scripts/install-azahar-android-adb.sh /path/to/Azahar.apk
```

The script does not download APKs. You provide the APK from a trusted source.

## Repo layout

```text
apps/prismds-os/
  configs/       frontend, systemd, desktop, udev, and PrismDS config templates
  docs/          RGDS install, architecture, compatibility, legal dump notes
  metadata/      manifest and release notes
  profiles/      RGDS and emulator capability metadata
  scripts/       Linux/Android installer, launchers, validators, perf helper
  tools/         dependency-free Node CLI
```

## Safer default

Full custom firmware comes later, after the RGDS recovery path, kernel config, DTB, display stack, touch mapping, audio, Wi-Fi/Bluetooth, suspend/resume, charging, and input stack are verified. This package gives us a working layer now without risking a brick.
