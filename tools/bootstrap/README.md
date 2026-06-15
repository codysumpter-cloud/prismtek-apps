# Repo-local Node bootstrap

This folder lets Prismtek Apps use a portable Node.js toolchain stored inside the repo checkout instead of requiring a system-wide Node install.

The downloaded runtime lives in `.prismtek-tools/`, which is ignored by git.

## macOS or Linux

```bash
./tools/bootstrap/bootstrap-node.sh
./tools/bootstrap/npm.sh install
./tools/bootstrap/npm.sh run platforms:validate
./tools/bootstrap/npm.sh run games:validate-support
```

## Windows PowerShell

```powershell
pwsh tools/bootstrap/bootstrap-node.ps1
pwsh tools/bootstrap/npm.ps1 install
pwsh tools/bootstrap/npm.ps1 run platforms:validate
pwsh tools/bootstrap/npm.ps1 run games:validate-support
```

## What gets bundled

- Node and npm are downloaded into `.prismtek-tools/` for this repo checkout.
- The player-facing game builds still should not require Node.
- The local toolchain is for building, validating, and packaging the repo.

## Version

The pinned version is in `tools/bootstrap/node-version.txt`.
