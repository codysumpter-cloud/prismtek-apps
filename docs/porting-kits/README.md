# Prismtek Porting Kits

This folder documents local setup for packaging Prismtek games across web, desktop, Android/RGDS, and Nintendo DS homebrew targets.

The repo keeps manifests, setup notes, validators, and source contracts. It does not commit third-party installers or generated platform artifacts.

## Validate

```bash
npm run platforms:validate
```

Or run the pieces directly:

```bash
npm run porting-kits:verify
npm run dual-screen:validate
npm run dual-screen:smoke
```

## Targets

| Target | Status |
| --- | --- |
| Web / itch.io ZIP | Existing static game builds and ZIP scripts are the first release path. |
| Desktop | Tauri/Rust wrapper path documented for Windows, macOS, Linux, and Steam Deck. |
| Android / RGDS Android | Android SDK and ADB required for APK/device receipts. |
| Android dual-screen | Shared config files live in each game under `platforms/android-dual-screen.json`. |
| Nintendo DS | devkitPro/libnds is the preferred local build path. |

## Receipt rule

Do not mark a platform verified until there is a real artifact and device/runtime test note.
