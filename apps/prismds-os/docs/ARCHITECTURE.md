# PrismDS architecture

PrismDS is a userland launcher layer, not a replacement operating system image.

## Layers

```text
RGDS vendor Linux / Android
  └─ PrismDS userland layer
      ├─ profiles/       device and emulator metadata
      ├─ configs/        frontend and desktop launcher config
      ├─ scripts/        install, launch, performance, validation helpers
      ├─ tools/          dependency-free Node validator/build/doctor CLI
      └─ runtime root    ~/.local/share/prismds
```

## Runtime root

Default:

```text
~/.local/share/prismds
```

Runtime layout:

```text
apps/azahar/           user-provided Azahar executable
apps/lab/              user-provided experimental executable
bin/                   installed PrismDS launchers
configs/               installed PrismDS config files
data/lab-files/        user-provided lab inputs
logs/prismds/          launcher logs
roms/3ds/              user-provided 3DS content
saves/3ds/             save storage target
screenshots/3ds/       screenshot target
states/3ds/            state target
tmp/                   temporary files
```

## Why userland first

A full bootable RGDS image requires verified recovery and hardware support for display, touch, input, audio, Wi-Fi/Bluetooth, suspend/resume, charging, and GPU acceleration. PrismDS starts as a reversible layer so we can ship useful behavior now without risking the device.

## Emulator strategy

- **Azahar** is the practical first path.
- **Lab profile** exists for low-level emulator experiments.
- PrismDS does not bundle emulator binaries or content.

## CI validation

The repo checker validates required files and JSON syntax. The CI job also shell-parses every PrismDS script with `bash -n`.
