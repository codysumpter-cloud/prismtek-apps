# Prismtek Porting Kits

This folder is the source of truth for setting up local porting environments for Prismtek games and apps.

The repo should keep **manifests, downloader scripts, setup receipts, and instructions**. It should not vendor large third-party SDKs, installers, emulators, or copyrighted console/runtime assets.

## What this kit covers

| Target | Primary path | Repo status | Kit doc |
| --- | --- | --- | --- |
| Web browser | Existing static/browser game builds | Supported by current game folders | [`web-and-itch.md`](web-and-itch.md) |
| itch.io / downloadable ZIP | Static ZIP packaging + Butler upload | Scriptable once release artifacts exist | [`web-and-itch.md`](web-and-itch.md) |
| Windows desktop | Tauri wrapper around existing web build | Setup documented; packaging pending per game | [`desktop-tauri.md`](desktop-tauri.md) |
| macOS desktop | Tauri wrapper around existing web build | Setup documented; packaging/signing pending per game | [`desktop-tauri.md`](desktop-tauri.md) |
| Linux / Steam Deck | Tauri/AppImage or static ZIP/browser | Setup documented; device receipts pending | [`desktop-tauri.md`](desktop-tauri.md) |
| Android / RGDS Android mode | Capacitor or Tauri Android wrapper | Setup documented; APK receipts pending | [`android-rgds.md`](android-rgds.md) |
| RGDS Linux mode | Static browser build, launcher, or Linux package | Setup documented; device receipts pending | [`android-rgds.md`](android-rgds.md) |
| Nintendo DS homebrew | devkitPro/libnds first, DS Game Maker optional | DS source exists for active games; `.nds` receipts pending | [`nintendo-ds.md`](nintendo-ds.md) |

## Fast setup

From the repo root:

```bash
npm run porting-kits:download
npm run porting-kits:verify
```

Or run the scripts directly:

```bash
node tools/porting-kits/verify-porting-kits.mjs
bash tools/porting-kits/download-porting-kits.sh
pwsh tools/porting-kits/download-porting-kits.ps1
```

Downloaded third-party files go into `.porting-kits/`, which is gitignored.

## Repository rules

1. Keep this repo clean: do not commit third-party SDK binaries, downloaded installers, emulators, ROMs, copyrighted assets, or generated `.nds`/desktop/mobile build outputs.
2. Keep downloads reproducible: add every source to `tools/porting-kits/porting-kits.manifest.json` before using it.
3. Keep claims honest: a target is not **Verified** until a real artifact has been built and tested on that target.
4. Prefer official sources. Community mirrors can be documented, but should be marked manual/review-required unless they are clearly safe to automate.
5. Treat Nintendo DS as a homebrew/demake target. Do not distribute proprietary Nintendo SDKs, BIOS files, commercial ROMs, or copied franchise content.

## Recommended order

1. Verify the existing browser game build.
2. Generate a self-contained web ZIP.
3. Wrap the same static build for desktop/mobile only after the web ZIP is stable.
4. Build `.nds` outputs from each game's `ds-homebrew/` folder only on a local machine with devkitPro/libnds installed.
5. Add receipts back to the relevant game docs after testing.

## Receipts to add after local setup

For each machine/device, capture:

- date tested
- host OS/device
- tool versions
- command used
- output artifact path
- screenshot or run note
- pass/fail result
- known limitations

Receipt docs belong near the game they validate, not in this global setup folder.
