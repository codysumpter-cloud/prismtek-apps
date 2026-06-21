# Native Prismcade

`apps/prismcade-native/` is the native macOS/iOS Prismcade app. It keeps the existing web Prismcade paths intact:

- `apps/prismcade/`
- `apps/prismcade-creator/`

The native app uses SwiftUI for the Prismcade hub and SpriteKit for game runtime scenes.

## Built

- Native Prismcade hub with cards for Flappy Pixel, Prismtek Dino Dash, and Beat Em Up Buck.
- macOS target: `PrismcadeMac`.
- iOS target: `PrismcadeiOS`.
- Curated local assets copied into `Shared/Resources/Art`, including Garden Birds, Onocentaur birds, DinoSprites, Buck Borris frames, Background Hills, and the RTB street backdrop.
- Runtime verification receipts and app-side SpriteKit snapshots for all three game scenes.

## Canonical game direction

The canonical Buck Borris game direction is now **Beat Em Up Buck**.

The native runtime implements Beat Em Up Buck as a SpriteKit micro brawler with Buck Borris as the playable character, an original Training Bruiser enemy, lane movement, attack timing, hitboxes, hurtboxes, damage, hit stun, knockback, health bars, KO/score, game-over, and restart.

Related docs:

```text
docs/games/beat-em-up-buck.md
docs/prismcade/game-catalog-parity.md
```

## Site reference pass

`prismtek-site` was cloned and searched during the final PR #203 merge pass. It had useful Flappy Pixel source and Prismcade platform metadata, but no better safe bird, dinosaur, Buck Borris, or native background art than the curated local assets now used by the native app.

## Engine reference pass

Local OpenBOR/MUGEN/Ikemen-style search found Prismtek evaluation/reference folders, including:

- `experiments/ikemen-prismtek-fighter/`
- `experiments/openbor-prismtek-brawler/`
- `games/prismcade-fighter/`
- `tools/prismcade-fighter/`

These were used as conceptual reference for state and frame-data terminology only. No external fighter engine or third-party fighter asset pack was integrated, because the launch app must remain native and build for both macOS and iOS.

## Catalog parity

Prismcade should converge on one canonical game catalog shared by website/web Prismcade, Windows/HTML Prismcade, and native macOS/iOS Prismcade.

If an older web/HTML game shares a canonical identity with a newer native/canonical game, the newer canonical entry should replace the duplicate instead of producing two cards.

See:

```text
docs/prismcade/game-catalog-parity.md
```

## Build status

- macOS: passed with `macosx27.0` during the native launch polish pass.
- iOS simulator: passed with `iphonesimulator27.0` during the native launch polish pass.

## Known limitations

- App-side SpriteKit snapshots were used for verification because desktop screen capture was black in the agent environment.
- Native Prismcade does not yet read `data/prismcade/game-manifests.json` dynamically.
- Native Prismcade does not yet submit runs to the web Prismcade/Arcade score APIs found in `prismtek-site`.
- Audio is not wired yet.
- Beat Em Up Buck has one enemy and one basic attack timing window; richer move data and enemy sprites are next.
