# Prismtek-site Arcade Migration Receipt

This document records the Prismtek-site arcade games that were migrated into `codysumpter-cloud/prismtek-apps` as first-class `games/*` projects.

Source evidence in `prismtek-site`:

- `src/arcade/game-catalog.tsx` imports the arcade game components.
- `src/arcade/game-catalog.tsx` maps the public game IDs to those components.
- `src/arcade/shared.ts` owns the shared arcade types/state.
- `src/data/game-catalog.js` and `functions/lib/arcade-shared.js` appear in the older/shared arcade data surface.

## Migrated games

| Source game | Source ID | Target path | Migration status | Intended Prismtek Arcade role |
| --- | --- | --- | --- | --- |
| Flappy Pixel | `flappy-pixel` | `games/flappy-pixel/` | Migrated | One-button reflex survival match with score/rank clout. |
| Crossy Pixel | `crossy-pixel` | `games/crossy-pixel/` | Migrated | Lane-crossing dodge/run match with streak and distance clout. |
| Pixel Snake | `pixel-snake` | `games/pixel-snake/` | Migrated | Classic route-control score match with speed/rank rewards. |
| Neon Brick Breaker | `neon-brick-breaker` | `games/neon-brick-breaker/` | Migrated | Paddle/brick clear match with combo, accuracy, and score clout. |
| Pixel Stacker | `pixel-stacker` | `games/pixel-stacker/` | Migrated | Timing/stacking precision match with height, streak, and badge rewards. |

## Migration contract status

Each migrated arcade game now has:

1. `games/<slug>/README.md`
2. `games/<slug>/package.json`
3. Browser-playable entrypoint
4. Shared static ZIP packaging path
5. Smoke test through `games/_shared/prismtek-arcade/smoke.mjs`
6. Platform matrix entry
7. Shared Prismtek Arcade feel alignment

## Remaining hardening

These games are active Prismtek-apps games now, but they still need release-level receipts before being called fully shipped:

- Attach web ZIP artifacts to GitHub Releases or itch.io.
- Device-test browser ZIPs on Windows, macOS, Linux, Steam Deck, RGDS Android mode, and RGDS Linux mode.
- Decide whether each should receive a separate Nintendo DS homebrew source port.
- Add local arcade profile, rank progression, match history, result JSON, and share-card UI where it fits the game loop.
