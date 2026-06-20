# Native Prismcade

`apps/prismcade-native/` is the native macOS/iOS Prismcade app. It keeps the existing web Prismcade paths intact:

- `apps/prismcade/`
- `apps/prismcade-creator/`

The native app uses SwiftUI for the Prismcade hub and SpriteKit for game runtime scenes.

## Built

- Native Prismcade hub with cards for Flappy Pixel, Prismtek Dino Dash, and Buck Borris Mini-Game.
- macOS target: `PrismcadeMac`.
- iOS target: `PrismcadeiOS`.
- Curated local assets copied into `Shared/Resources/Art`.
- Runtime verification receipts for all three game scenes.

## Site Reference Pass

`/Users/prismtek/Prismtek/prismtek-site` was present for the final verification pass after cloning it locally. The search found:

- `src/arcade/games/FlappyPixelGame.tsx`, the current web Flappy Pixel React/canvas implementation.
- `memory-wall-react/pixel-games/flappy-pixel/flappy-runtime.js` and `flappy-core.js`, an older full Flappy Pixel runtime with tuning, progression, cosmetics, leaderboards, and challenge hooks.
- `src/data/game-catalog.js`, shared Flappy Pixel catalog and scoring metadata.
- `docs/prismcade/*`, `functions/lib/prismcade.js`, and Prismcade API/player shell files documenting the manifest-first web creator direction.

The native app does not replace its curated local sprites with site assets because the site pass did not reveal safer or better bird, dinosaur, or Buck Borris art. The Flappy tuning and Prismcade metadata are kept as reference material for future native score-platform integration.

## Build Status

- macOS: passed with `macosx27.0`.
- iOS simulator: passed with `iphonesimulator27.0`.

## Known Limitations

- Screenshots from macOS `screencapture` were black in this agent desktop environment; app-side SpriteKit scene snapshots were used instead.
- Native Prismcade does not yet read `data/prismcade/game-manifests.json` dynamically.
- Native Prismcade does not yet submit runs to the web Prismcade/Arcade score APIs found in `prismtek-site`.
- Audio is not wired yet.
