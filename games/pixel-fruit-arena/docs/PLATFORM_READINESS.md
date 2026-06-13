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
| itch.io / downloadable ZIP | Partially verified | `npm run package:zip` now builds, validates `dist/`, and creates `artifacts/pixel-fruit-arena-web.zip` with `index.html` at the archive root. A real artifact/release/upload receipt is still required before calling it downloadable. |

## Local run receipt checklist

From `games/pixel-fruit-arena/`:

```bash
npm test
npm run build
npm run validate:dist
npm run package:zip
```

Expected artifact path after a successful package run:

```text
artifacts/pixel-fruit-arena-web.zip
```

The ZIP should contain the contents of `dist/` at the archive root, including `index.html`.

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

Pixel Fruit Arena is a verified local web/browser MVP with a newly documented ZIP packaging path. It is not yet a fully verified cross-platform downloadable game.
