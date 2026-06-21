# Prismcade Native

Native macOS/iOS Prismcade launcher and runtime built with SwiftUI + SpriteKit.

## Games

- Flappy Pixel: one-button score chase with 50 playable bird characters, visible flapping, no spin, and a pixel mountain stage.
- Prismtek Dino Dash: four-character dinosaur runner using `DinoSprites` sheets and a layered pixel hills environment.
- Beat Em Up Buck: tiny native Buck Borris lane brawler with attacks, health bars, knockback, KO scoring, an original Training Bruiser enemy, and a pixel street backdrop.

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
- Flappy Pixel: choose a bird with click/tap, arrows/Tab, or Space; click, tap, or Space to flap/restart.
- Dino Dash: click/tap a dino or press 1-4 on macOS; click, tap, or Space to jump/restart.
- Beat Em Up Buck: arrows/WASD move, Space/J attacks, K jumps; on iOS the left side moves and the right side attacks/jumps.

## Catalog parity

The native hub should stay aligned with the canonical Prismcade catalog and replacement rules in:

```text
docs/prismcade/game-catalog-parity.md
```

The near-term target is one Prismcade catalog shared across website, Windows/HTML, macOS, and iOS. If an older web/HTML entry shares a canonical identity with a newer native game, the newer canonical entry should replace the old duplicate.

## Verification

Runtime receipts and scene snapshots are in:

```text
apps/prismcade-native/verification-screenshots/
```

Desktop `screencapture` returned black in this Codex desktop context, so each SpriteKit scene writes its own macOS runtime snapshot during gated verification.

This polish pass verified the launch set with app-side SpriteKit snapshots:

- Flappy Pixel: `flappy-runtime-verification.json`
- Prismtek Dino Dash: `dino-runtime-verification.json`
- Beat Em Up Buck: `buck-runtime-verification.json`

`/Users/prismtek/Prismtek/prismtek-site` was cloned locally before the final merge pass and searched for Flappy Pixel, Dino, Buck/Borris/Boris, Prismcade, and image/source references. The site contains useful Flappy Pixel React/canvas source and Prismcade platform metadata, but the native app keeps the curated local Garden Birds, Onocentaur birds, DinoSprites, Buck Borris, Background Hills, and RTB backdrop assets because they are the best safe native assets found.

## Follow-up references

See:

```text
docs/prismcade/NATIVE_POLISH_HANDOFF.md
docs/prismcade/NATIVE_POLISH_TODO.md
docs/games/beat-em-up-buck.md
```

Do not call the native Prismcade launch set polished until Flappy Pixel, Prismtek Dino Dash, and Beat Em Up Buck pass the runtime gates in those docs.
