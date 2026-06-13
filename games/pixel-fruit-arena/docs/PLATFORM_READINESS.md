# Pixel Fruit Arena Platform Readiness

Pixel Fruit Arena is currently a verified local web/browser MVP. This matrix tracks only evidence-backed platform status. Do not upgrade a platform to `Verified` unless there is source, build, runtime, device, release, or artifact evidence for that exact platform.

## Status vocabulary

- `Verified` — confirmed by source/build/runtime/release/device evidence for the exact platform.
- `Partially verified` — source/build tooling exists, but one or more required platform/runtime/release receipts are missing.
- `Unverified` — likely possible or intended, but not backed by current receipts.
- `Missing` — no current implementation path exists.

## Current platform matrix

| Platform | Status | Evidence / gap |
| --- | --- | --- |
| Web browser | Verified | Merged local browser QA loaded the game over HTTP, opened menus, equipped a fruit, started `Fight CPU`, accepted keyboard input, rendered fighters/stage/VFX, and reported no console errors. Current build scripts also create `dist/` for static web hosting. |
| Windows | Partially verified | PowerShell helper scripts exist for test/build/serve, but there is no native Windows package or fresh Windows-device ZIP run receipt in this branch. |
| macOS | Unverified | Static web output should be browser-runnable, but there is no macOS runtime, package, or device/browser receipt. |
| Linux / Steam Deck | Unverified | Static web output should be browser-runnable, but there is no Linux/Steam Deck runtime, package, or device/browser receipt. |
| RGDS Android mode | Unverified | No Android WebView/browser-on-RGDS runtime receipt, touch/control mapping receipt, APK, or RGDS Android artifact exists. |
| RGDS Linux mode | Unverified | No RGDS Linux browser/runtime receipt, PortMaster package, native package, or device artifact exists. |
| itch.io / downloadable ZIP | Partially verified | ZIP packaging now builds, validates `dist/`, and creates `artifacts/pixel-fruit-arena-web.zip` with `index.html` at the archive root. A local Windows artifact receipt exists; public upload/download verification is still required before calling it verified downloadable support. |

## Local run receipt checklist

From `games/pixel-fruit-arena/`:

```bash
npm test
npm run build
npm run validate:dist
npm run package:zip
```

PowerShell-only fallback from the repository root:

```powershell
powershell -ExecutionPolicy Bypass -File games\pixel-fruit-arena\tools\test.ps1
powershell -ExecutionPolicy Bypass -File games\pixel-fruit-arena\tools\validate_sprites.ps1 games\pixel-fruit-arena\assets\characters\prismtek_placeholder_character.json
powershell -ExecutionPolicy Bypass -File games\pixel-fruit-arena\tools\package_zip.ps1
```

Expected artifact path after a successful package run:

```text
artifacts/pixel-fruit-arena-web.zip
```

The ZIP should contain the contents of `dist/` at the archive root, including `index.html`.

## Latest local artifact receipt

Date: June 13, 2026

Environment: Windows PowerShell in a real `prismtek-apps` checkout, with standalone `node`, `npm`, and Python unavailable on PATH.

Commands run:

```powershell
powershell -ExecutionPolicy Bypass -File games\pixel-fruit-arena\tools\test.ps1
powershell -ExecutionPolicy Bypass -File games\pixel-fruit-arena\tools\validate_sprites.ps1 games\pixel-fruit-arena\assets\characters\prismtek_placeholder_character.json
powershell -ExecutionPolicy Bypass -File games\pixel-fruit-arena\tools\package_zip.ps1
powershell -ExecutionPolicy Bypass -File games\pixel-fruit-arena\tools\validate_dist.ps1
git diff --check
```

Results:

- PowerShell test script passed. Its Node smoke-test branch was skipped because `node` was unavailable on PATH.
- Sprite validation passed for `assets/characters/prismtek_placeholder_character.json`.
- `dist/` validation passed with 85 files, no `assets/reference`, and no `.gif` leaks.
- `artifacts/pixel-fruit-arena-web.zip` was created with 87 entries and `index.html` at the archive root.
- ZIP SHA-256: `6A0E85D4E663A6412D7F6EFFCC3B2D20C7D0D4C12A9A0D4F86DBD648AEEE2B8C`
- `git diff --check` exited successfully. It reported line-ending warnings for touched text files, but no whitespace errors.

## Manual/device verification checklist

For each platform, capture the exact date, device/OS/browser, command/artifact used, and result.

### Web browser

- Serve `dist/` over HTTP.
- Confirm main menu renders without console errors.
- Start `Fight CPU`.
- Confirm keyboard movement/attack input works.
- Confirm fighters, stage art, HUD, and VFX render.

### Windows

- Run PowerShell test/build scripts or the npm scripts on Windows.
- Create `artifacts/pixel-fruit-arena-web.zip`.
- Extract the ZIP and serve the extracted folder over HTTP.
- Run the same browser smoke test.

### macOS

- Run npm scripts or serve the ZIP output on macOS.
- Run the browser smoke test and record browser/version.

### Linux / Steam Deck

- Run npm scripts or serve the ZIP output on Linux/Steam Deck.
- Test keyboard/controller mapping in browser.
- Record Steam Deck mode if tested.

### RGDS Android mode

- Copy/extract the ZIP to RGDS Android storage or host it locally.
- Open in the intended browser/WebView.
- Verify touch/gamepad/keyboard controls available on that device.

### RGDS Linux mode

- Copy/extract the ZIP to RGDS Linux storage or package it through the chosen launcher flow.
- Verify game startup, controls, and performance on-device.

### itch.io / downloadable ZIP

- Upload `artifacts/pixel-fruit-arena-web.zip` to itch.io or attach it to a GitHub release.
- Verify the uploaded/downloaded artifact opens with `index.html` at the root.
- Record the release/upload URL before marking downloadable status as `Verified`.

## Honest current label

Pixel Fruit Arena is a verified local web/browser MVP with a locally verified ZIP packaging path. It is not yet a fully verified cross-platform downloadable game.
