# Prismcade Native

Native macOS/iOS Prismcade launcher and runtime built with SwiftUI + SpriteKit.

## Games

- Flappy Pixel: one-button score chase with 50 right-facing playable birds, a clean bird-select grid, a pixel mountain stage, and score-driven weather.
- Prismtek Dino Dash: four-character dinosaur runner (`DinoSprites`), clean saguaro-cactus + rock obstacles, layered pixel hills, and score-driven weather.
- Beat Em Up Buck: native SpriteKit beat-em-up — uniform 24×24 Buck (consistent size across states), multi-enemy waves, an energy-wave projectile (L/E) on an energy meter, a dragon-mount power, a desert Mummy enemy, and a desert arena.

## Platform features (current, truthful)

- **Catalog-driven hub** reading the canonical `data/prismcade/prismcade-catalog.json` (32 games; native-playable launch, others shown as planned parity targets).
- **Local profile + local scores/receipts** (`PrismcadePlatform`), with a portable **leaderboard export** (`LeaderboardService`) for the shared Prismcade API.
- **Weather/season system** (shared `WeatherSystem`): starts Clear/Spring, escalates Wind→Rain→Storm→Autumn→Snow with score; affects physics and scoring in Flappy + Dino.
- **Audio**: `AudioManager` looping BGM per game + event SFX (incl. Dino jump).
- **App icon**: a clean pixel-arcade `AppIcon` asset catalog wired for macOS + iOS. *(Temporary brand icon generated from safe in-repo motifs; replace with final art when available.)*
- **Game Center readiness** (`GameCenterService`): optional authentication with offline fallback and staged per-game score submission. *Not yet live — needs the Game Center entitlement + App Store Connect leaderboards (IDs staged in `GameCenterService.leaderboardIDs`); gameplay never blocks if unavailable.*
- **Future**: portable avatar / UGC creator (manifest-first), remote leaderboard sync.

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

`/Users/prismtek/Prismtek/prismtek-site` was cloned locally before the final merge pass and searched for Flappy Pixel, Dino, Buck/Borris/Boris, Prismcade, and image/source references. The site contains useful Flappy Pixel React/canvas source and Prismcade platform metadata. The native app keeps the curated local Garden Birds, Onocentaur birds, DinoSprites, Buck Borris, Background Hills, Weather Effects, desert arena, and CraftPix Mummy enemy assets because they are the best safe native assets found.

## Follow-up references

See:

```text
docs/prismcade/NATIVE_POLISH_HANDOFF.md
docs/prismcade/NATIVE_POLISH_TODO.md
docs/games/beat-em-up-buck.md
```

Do not call the native Prismcade launch set polished until Flappy Pixel, Prismtek Dino Dash, and Beat Em Up Buck pass the runtime gates in those docs.
