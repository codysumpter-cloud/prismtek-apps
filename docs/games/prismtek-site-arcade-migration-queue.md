# Prismtek-site Arcade Migration Queue

This queue tracks arcade games that exist in `codysumpter-cloud/prismtek-site` and still need to be migrated into `codysumpter-cloud/prismtek-apps` as first-class `games/*` projects.

Source evidence in `prismtek-site`:

- `src/arcade/game-catalog.tsx` imports the arcade game components.
- `src/arcade/game-catalog.tsx` maps the public game IDs to those components.
- `src/arcade/shared.ts` owns the shared arcade types/state.
- `src/data/game-catalog.js` and `functions/lib/arcade-shared.js` appear in the older/shared arcade data surface.

## Queue

| Source game | Source ID | Target path | Migration status | Intended Prismtek Arcade role |
| --- | --- | --- | --- | --- |
| Flappy Pixel | `flappy-pixel` | `games/flappy-pixel/` | Queued | One-button reflex survival match with score/rank clout. |
| Crossy Pixel | `crossy-pixel` | `games/crossy-pixel/` | Queued | Lane-crossing dodge/run match with streak and distance clout. |
| Pixel Snake | `pixel-snake` | `games/pixel-snake/` | Queued | Classic route-control score match with speed/rank rewards. |
| Neon Brick Breaker | `neon-brick-breaker` | `games/neon-brick-breaker/` | Queued | Paddle/brick clear match with combo, accuracy, and score clout. |
| Pixel Stacker | `pixel-stacker` | `games/pixel-stacker/` | Queued | Timing/stacking precision match with height, streak, and badge rewards. |

## Target migration contract

Each migrated arcade game should land with:

1. `games/<slug>/README.md`
2. `games/<slug>/package.json`
3. Browser-playable entrypoint
4. Shared static ZIP packaging path
5. Smoke test
6. Honest platform matrix entry
7. Shared Prismtek Arcade feel alignment
8. Local-first profile/match-result direction where it fits

## Migration order

Recommended order:

1. `games/pixel-snake/` — smallest classic arcade loop and easiest smoke-test target.
2. `games/flappy-pixel/` — simple one-button skill loop.
3. `games/neon-brick-breaker/` — stronger score/combo loop.
4. `games/crossy-pixel/` — lane/object spawning and collision timing.
5. `games/pixel-stacker/` — precision timing and stack-state persistence.

## Release honesty

These games are **not** current `prismtek-apps/games/*` projects until their source is actually migrated. Until then:

- Do not add direct `games/<slug>/` open buttons.
- Do not claim downloadable ZIPs exist.
- Do not claim DS/RGDS/Steam Deck/device support.
- Do list them as queued source-confirmed arcade migrations.
