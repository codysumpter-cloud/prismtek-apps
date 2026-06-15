# Repo-local toolchain bootstrap

This folder lets Prismtek Apps use portable build tools stored inside the repo checkout instead of requiring system-wide installs first.

The downloaded runtime cache lives in `.prismtek-tools/`, which is ignored by git.

## One-command setup

macOS or Linux:

```bash
./tools/bootstrap/setup.sh
```

Windows PowerShell:

```powershell
pwsh tools/bootstrap/setup.ps1
```

The setup scripts bootstrap Node, prepare local toolchain folders, run `npm install`, and run the platform/game validation scripts.

## Individual commands

macOS or Linux:

```bash
./tools/bootstrap/bootstrap-node.sh
./tools/bootstrap/toolchain.sh list
./tools/bootstrap/toolchain.sh prepare all
./tools/bootstrap/toolchain.sh verify all
./tools/bootstrap/npm.sh install
```

Windows PowerShell:

```powershell
pwsh tools/bootstrap/bootstrap-node.ps1
pwsh tools/bootstrap/toolchain.ps1 list
pwsh tools/bootstrap/toolchain.ps1 prepare all
pwsh tools/bootstrap/toolchain.ps1 verify all
pwsh tools/bootstrap/npm.ps1 install
```

## Toolchains tracked

- `node` for repo-local Node, npm, and npx.
- `npm-cache` for the repo-local npm cache configured by `.npmrc`.
- `nds-devkitpro` for Nintendo DS homebrew env files and local toolchain location.
- `itch-butler` for itch.io publishing tooling.
- `android-rgds` for Android/RGDS SDK and adb tooling.
- `jdk` for Android packaging.
- `rust-tauri` for desktop packaging.
- `media-tools` for media conversion helpers.

## Policy

- Do not commit downloaded toolchains.
- Do not commit generated build outputs.
- Do not commit restricted console files or commercial game data.
- Player-facing packaged games still should not require Node.

## Version

The pinned Node version is in `tools/bootstrap/node-version.txt`.
