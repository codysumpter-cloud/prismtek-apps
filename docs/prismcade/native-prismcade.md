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

## Build Status

- macOS: passed with `macosx27.0`.
- iOS simulator: passed with `iphonesimulator27.0`.

## Known Limitations

- Screenshots from macOS `screencapture` were black in this agent desktop environment; app-side SpriteKit scene snapshots were used instead.
- Native Prismcade does not yet read `data/prismcade/game-manifests.json` dynamically.
- Audio is not wired yet.

