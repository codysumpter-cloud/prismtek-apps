# Prismcade Native

Native macOS/iOS Prismcade launcher and runtime built with SwiftUI + SpriteKit.

## Games

- Flappy Pixel: one-button score chase with curated Onocentaur bird frames.
- Prismtek Dino Dash: four-character dinosaur runner using `DinoSprites` sheets.
- Buck Borris Mini-Game: Buck Borris jump, dodge, and pickup mini-game using real Buck frames.

## Open

```bash
cd /Users/prismtek/Prismtek/prismtek-apps/apps/prismcade-native
xcodegen generate
open Prismcade.xcodeproj
```

Schemes:

- `PrismcadeMac`
- `PrismcadeiOS`

## Build

```bash
DEVELOPER_DIR=/Applications/Xcode-beta.app/Contents/Developer xcodebuild \
  -project Prismcade.xcodeproj \
  -scheme PrismcadeMac \
  -sdk macosx27.0 \
  CODE_SIGNING_ALLOWED=NO \
  build
```

```bash
DEVELOPER_DIR=/Applications/Xcode-beta.app/Contents/Developer xcodebuild \
  -project Prismcade.xcodeproj \
  -scheme PrismcadeiOS \
  -sdk iphonesimulator27.0 \
  CODE_SIGNING_ALLOWED=NO \
  build
```

## Controls

- Hub: choose a game card, then Play.
- Flappy Pixel: click, tap, or Space to flap/restart.
- Dino Dash: click/tap a dino or press 1-4 on macOS; click, tap, or Space to jump/restart.
- Buck Borris: click, tap, or Space to jump/restart.

## Verification

Runtime receipts and scene snapshots are in:

```text
apps/prismcade-native/verification-screenshots/
```

Desktop `screencapture` returned black in this Codex desktop context, so each SpriteKit scene writes its own macOS runtime snapshot during gated verification.

`/Users/prismtek/Prismtek/prismtek-site` was cloned locally before the final merge pass and searched for Flappy Pixel, Dino, Buck/Borris/Boris, Prismcade, and image/source references. The site contains useful Flappy Pixel React/canvas source and Prismcade platform metadata, but the native app keeps the curated local Onocentaur bird, DinoSprites, and Buck Borris assets because they are the best safe native sprites found.
