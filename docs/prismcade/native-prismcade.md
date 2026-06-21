# Native Prismcade

`apps/prismcade-native/` is the native macOS/iOS Prismcade app. It keeps the existing web Prismcade paths intact:

- `apps/prismcade/`
- `apps/prismcade-creator/`

The native app uses SwiftUI for the Prismcade hub and SpriteKit for game runtime scenes.

## Built

- Native Prismcade hub with cards for Flappy Pixel, Prismtek Dino Dash, and Beat Em Up Buck.
- macOS target: `PrismcadeMac`.
- iOS target: `PrismcadeiOS`.
- Curated local assets copied into `Shared/Resources/Art`, including Garden Birds, Onocentaur birds, DinoSprites, Buck Borris frames, Background Hills, desert arena art, Weather Effects wind/rain/shine sprites, snapshot hub previews, and CraftPix Mummy enemy strips.
- Runtime verification receipts and app-side SpriteKit snapshots for all three game scenes.

## Canonical game direction

The canonical Buck Borris game direction is now **Beat Em Up Buck**.

The native runtime implements Beat Em Up Buck as a SpriteKit micro brawler with Buck Borris as the playable character, an animated desert Mummy enemy, lane movement, attack timing, hitboxes, hurtboxes, damage, hit stun, knockback, health bars, KO/score, game-over, and restart.

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

## Platform layer (manifest/catalog parity PR)

Native now aligns with the canonical manifest-first Prismcade model:

- **Canonical catalog**: `apps/prismcade-native` bundles and reads
  `data/prismcade/prismcade-catalog.json` (32-game union). The hub shows native-playable games
  first, then every other catalog game as a clearly-labelled **planned** parity target — no fake
  playable buttons, no duplicate old/new cards (native canonical builds dedupe their web twin).
- **Local-first platform hooks** (`PrismcadePlatform`): persisted player handle, per-game best
  scores, rolling match receipts, and a leaderboard export payload.
- **GameShell**: a shared results/status bar (best, last result, leaderboard sync state) plus
  Restart and Return, so games don't reinvent post-game UI.
- **LeaderboardService**: offline-safe queue that submits match receipts to the shared Prismcade
  API (`functions/api/prismcade`) when `PRISMCADE_API_BASE` is configured; local-only otherwise.
- **SFX**: curated event sounds for Flappy, Dino, and Buck.

## Build status

- macOS: passed with `macosx27.0` during the native launch polish pass.
- iOS simulator: passed with `iphonesimulator27.0` during the native launch polish pass.

## Known limitations

- App-side SpriteKit snapshots were used for verification because desktop screen capture was black in the agent environment.
- Native reads the canonical `prismcade-catalog.json`; the 29 planned games are shown but not yet ported to native scenes.
- `LeaderboardService` submits to the shared API only when `PRISMCADE_API_BASE` is configured and a `POST /api/prismcade/scores` endpoint exists; otherwise it queues locally.
- The canonical catalog is regenerated manually (see `docs/prismcade/website-sync.md`); no automatic generator yet.
- Beat Em Up Buck has one enemy and one basic attack timing window; richer move data is next.
- The native character creator (portable avatar) is not built yet; assets are staged locally.
