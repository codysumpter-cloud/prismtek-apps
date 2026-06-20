# Native Prismcade

`apps/prismcade-native/` is the native macOS/iOS Prismcade app. It keeps the existing web Prismcade paths intact:

- `apps/prismcade/`
- `apps/prismcade-creator/`

The native app uses SwiftUI for the Prismcade hub and SpriteKit for game runtime scenes.

## Built

- Native Prismcade hub with cards for Flappy Pixel, Prismtek Dino Dash, and the Buck Borris prototype.
- macOS target: `PrismcadeMac`.
- iOS target: `PrismcadeiOS`.
- Curated local assets copied into `Shared/Resources/Art`.
- Runtime verification receipts for all three game scenes.

## Canonical game direction

The canonical Buck Borris game direction is now **Beat Em Up Buck**.

The currently merged runtime still contains the earlier Buck Borris jump/dodge/pickup prototype. The next native polish pass should replace that prototype with a tiny SpriteKit brawler/fighter using Buck Borris as the player character.

Related docs:

```text
docs/games/beat-em-up-buck.md
docs/prismcade/game-catalog-parity.md
```

## Site reference pass

`prismtek-site` was cloned and searched during the final PR #203 merge pass. It had useful Flappy Pixel source and Prismcade platform metadata, but no better safe bird, dinosaur, or Buck Borris art than the curated local assets already used by the native app.

## Catalog parity

Prismcade should converge on one canonical game catalog shared by website/web Prismcade, Windows/HTML Prismcade, and native macOS/iOS Prismcade.

If an older web/HTML game shares a canonical identity with a newer native/canonical game, the newer canonical entry should replace the duplicate instead of producing two cards.

See:

```text
docs/prismcade/game-catalog-parity.md
```

## Build status

- macOS: passed with `macosx27.0` during the PR #203 merge pass.
- iOS simulator: passed with `iphonesimulator27.0` during the PR #203 merge pass.

## Known limitations

- App-side SpriteKit snapshots were used for verification because desktop screen capture was black in the agent environment.
- Native Prismcade does not yet read `data/prismcade/game-manifests.json` dynamically.
- Native Prismcade does not yet submit runs to the web Prismcade/Arcade score APIs found in `prismtek-site`.
- Audio is not wired yet.
- Beat Em Up Buck is not implemented yet; the merged Buck runtime is still the earlier jump/dodge prototype.
