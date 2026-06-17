# Prismcade Platform Loop

Status: **foundation slice**

Prismcade is the Prismtek Arcade product loop: a retro pixel-art, browser-first arcade platform where small original games can be cataloged, remixed, asset-backed, packaged, and eventually published with local profiles, match receipts, share cards, and leaderboard-ready exports.

This is not a mandate to finish the largest game first. Prismcade should make many small games easy to ship before large-world showcases absorb attention.

## Product target

Prismcade should feel like an indie Roblox for retro/pixel games, but scoped around Prismtek's existing strengths:

- instant browser play;
- tiny replayable games;
- local-first game loops;
- reusable templates;
- traceable asset generation;
- clear game manifests;
- honest platform readiness;
- packageable static ZIPs;
- future hooks for profiles, leaderboards, ratings, creator pages, and multiplayer.

## Priority order

1. **Platform loop:** catalog, manifests, validation, asset index, publishing docs.
2. **Focused showcase games:** Pixel Fruit Arena, Spin Street Showdown, TamerNet, and the migrated quick-play arcade games.
3. **Creator MVP:** template picker, metadata editor, asset picker, manifest preview/export.
4. **Asset generation workflow:** Pixel Forge plus pixellab.ai/LibreSprite curation.
5. **Large showcases:** Prismwilds / Wildlands-style survival after the loop is usable.

## Current active game roles

| Game | Role in Prismcade | Priority |
| --- | --- | --- |
| Pixel Fruit Arena | Flagship focused platform-fighter showcase. | High |
| Flappy Pixel | Quick-play one-button arcade proof. | High |
| Crossy Pixel | Quick-play lane-dodge arcade proof. | High |
| Pixel Snake | Quick-play route-control arcade proof. | High |
| Neon Brick Breaker | Quick-play paddle/combo arcade proof. | High |
| Pixel Stacker | Quick-play timing arcade proof. | High |
| Spin Street Showdown | Medium top-battle arena showcase. | Medium |
| TamerNet Battle Sandbox | Medium creature-battle sandbox showcase. | Medium |
| Prismwilds: Echo Dominion | Larger creature-survival showcase; catalog honestly, finish later. | Later |

## Non-negotiables

- No copied franchise assets, logos, characters, or shipped reference assets.
- No public release/download/platform claim without a receipt.
- No online ranked system until local match receipts are stable.
- No asset dumps without provenance.
- No replacing the existing Pixel Forge or pixel asset pipeline with a duplicate system.

## Near-term implementation slices

1. Add `data/prismcade/game-manifests.json`.
2. Add `tools/prismcade/validate-game-manifests.mjs`.
3. Add `apps/prismcade/` as a static catalog/launcher.
4. Add `apps/prismcade-creator/` as a manifest creator MVP.
5. Add `packages/game-assets/manifests/prismcade-assets.json`.
6. Add Pixel Fruit Arena catalog polish and manifest-first match receipt hooks.
7. Add share-card/result-receipt contracts before hosted leaderboards.
