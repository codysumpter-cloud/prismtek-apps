# PrismDS for RGDS

PrismDS is an RGDS-first userland launcher layer for the Anbernic RG DS.

It is **not** a boot image, bootloader replacement, or device flasher. It installs launch folders, profiles, validation tools, frontend configuration, performance helpers, desktop entries, and Android helper scripts on top of the stock Linux/Android environment.

## Goals

- Make **Azahar** the practical first 3DS path on RGDS.
- Keep a generic **lab** path available for experimental emulator work.
- Use the RGDS dual-screen form factor intentionally.
- Keep everything reversible and non-destructive.
- Do not bundle emulators, games, platform files, or user-owned content.

## What is functional now

- Installable Linux-side folder layout under `~/.local/share/prismds` by default.
- RGDS hardware profile and emulator capability metadata.
- Launch scripts for Azahar and a locally supplied lab emulator.
- Local-file validator for the lab profile.
- Root-optional performance helper.
- Android ADB helper for side-loading an Azahar APK you provide.
- EmulationStation system config for a 3DS collection.
- Desktop launcher entry.
- Dependency-free Node CLI for `check`, `build`, `doctor`, and install-plan output.

## What this does not do yet

- It does not include emulator binaries.
- It does not include games or platform-owned assets.
- It does not replace the RGDS kernel, bootloader, DTB, or vendor OS image.
- It does not promise playable 3DS speed on RK3568.

## Quick start on RGDS Linux

```bash
cd apps/prismds-os
node tools/prismds.mjs check
bash scripts/install-prismds.sh
node tools/prismds.mjs doctor
```

After installing, place emulator binaries here:

```text
~/.local/share/prismds/apps/azahar/Azahar.AppImage
~/.local/share/prismds/apps/lab/emulator
```

Place 3DS content and local lab files here:

```text
~/.local/share/prismds/roms/3ds/
~/.local/share/prismds/data/lab-files/
```

Then launch:

```bash
~/.local/share/prismds/bin/prismds-launch-azahar.sh
~/.local/share/prismds/bin/prismds-launch-lab.sh
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
  configs/       frontend, desktop, and PrismDS config templates
  docs/          RGDS install, architecture, compatibility, legal notes
  metadata/      manifest and release notes
  profiles/      RGDS and emulator capability metadata
  scripts/       Linux/Android installer, launchers, validators, perf helper
  tools/         dependency-free Node CLI
```

## Safer default

Full custom images come later, after the RGDS recovery path, kernel config, DTB, display stack, touch mapping, audio, Wi-Fi/Bluetooth, suspend/resume, charging, and input stack are verified. This package gives us a working layer now without risking a brick.
