# Prismcade Platform Loop

Status: **foundation slice**

Prismcade is the Prismtek Arcade product loop: a retro pixel-art, browser-first arcade platform where small original games can be cataloged, remixed, asset-backed, packaged, and eventually published with shared profiles, portable avatars, reusable animation templates, match receipts, share cards, and leaderboard-ready exports.

This is not a mandate to finish the largest game first. Prismcade should make many small games easy to ship before large-world showcases absorb attention.

## Product target

Prismcade should feel like an indie Roblox for retro/pixel games, but scoped around Prismtek's existing strengths:

- instant browser play;
- tiny replayable games;
- friend-ready pick-up-and-play sessions;
- one portable created character identity;
- created and earned avatar cosmetics that work across many games;
- template-bound animation rigs that let compatible characters reuse the same movement and action sets;
- shared player progression, clout, ranks, and leaderboard receipts;
- local-first game loops;
- reusable templates;
- traceable asset generation;
- clear game manifests;
- honest platform readiness;
- packageable static ZIPs;
- future hooks for profiles, leaderboards, ratings, creator pages, parties, and multiplayer.

## Platform moat

Generic game catalogs are good at discovery and downloads, but Prismcade needs to win on continuity:

1. A player should find a game fast and play immediately with a friend.
2. The same created avatar should work across many game formats.
3. Leaderboards, match receipts, ranks, and clout should make every small game matter.
4. Cosmetics should be reusable platform inventory, not one-off per-game art dumps.
5. A sprite style should be animated once, then reused by any character that matches its dimensions, anchors, view family, and layer rules.
6. Games should be tiny, readable, social, and replayable before they are huge.

The platform is successful when a player says: **this is my Prismcade character, these are my friends, these are my scores, and I can bring my look into the next game.**

## Portable avatar requirement

Every major Prismcade game should declare which avatar views it supports:

- `side`: platformers, fighters, brawlers, runners.
- `top_down`: overhead arcade, creature games, town hubs.
- `low_top_down`: RPG-like camera with visible front/side body readability.
- `isometric`: tactics, rooms, creator worlds, social spaces.

Avatar source assets should be generated and validated as a reusable kit instead of a single sprite sheet. Minimum cross-game kit:

- base body;
- hair layer;
- face/eyes layer;
- top/clothing layer;
- legs/bottom layer;
- shoes/accessory layer;
- palette slots;
- animation template ID;
- animation map;
- anchor map;
- view map;
- provenance receipt.

If a game cannot support the full avatar, it should support a fallback representation such as portrait, head icon, simplified mini avatar, or color/palette identity.

See `docs/prismcade/PORTABLE_AVATAR_CONTRACT.md` and `docs/prismcade/REUSABLE_ANIMATION_TEMPLATE.md` for the contracts.

## Priority order

1. **Platform loop:** catalog, manifests, validation, asset index, publishing docs.
2. **Portable identity:** profile, avatar contract, inventory, cosmetics, view support, receipts.
3. **Reusable animation templates:** shared dimensions, anchors, layer rules, animation slots, and game compatibility levels.
4. **Focused showcase games:** Pixel Fruit Arena, Spin Street Showdown, TamerNet, and the migrated quick-play arcade games.
5. **Creator MVP:** template picker, metadata editor, asset picker, manifest preview/export, avatar compatibility flags.
6. **Asset generation workflow:** Pixel Forge plus pixellab.ai/LibreSprite curation.
7. **Social/leaderboard loop:** friends, parties, local receipts, hosted leaderboard bridge, share cards.
8. **Large showcases:** Prismwilds / Wildlands-style survival after the loop is usable.

## Current active game roles

| Game | Role in Prismcade | Priority |
| --- | --- | --- |
| Pixel Fruit Arena | Flagship focused platform-fighter showcase; must prove side-view portable avatar support. | High |
| Flappy Pixel | Quick-play one-button arcade proof; should support avatar portrait and score identity. | High |
| Crossy Pixel | Quick-play lane-dodge arcade proof; should support top-down or mini-avatar identity. | High |
| Pixel Snake | Quick-play route-control arcade proof; should support profile identity, palette, and leaderboard receipts. | High |
| Neon Brick Breaker | Quick-play paddle/combo arcade proof; should support profile identity, cosmetics badge, and leaderboard receipts. | High |
| Pixel Stacker | Quick-play timing arcade proof; should support profile identity, cosmetics badge, and leaderboard receipts. | High |
| Spin Street Showdown | Medium top-battle arena showcase; should support avatar portrait, owner badge, launcher identity, and customization inventory. | Medium |
| TamerNet Battle Sandbox | Medium creature-battle sandbox showcase; should support top-down or low-top-down avatar identity. | Medium |
| Prismcade Fighter | Focused anime-pixel fighter foundation; must support side-view avatar/fighter packs. | Medium |
| Prismwilds: Echo Dominion | Larger creature-survival showcase; catalog honestly, finish later. | Later |

## Non-negotiables

- No copied franchise assets, logos, characters, or shipped reference assets.
- No public release/download/platform claim without a receipt.
- No online ranked system until local match receipts are stable.
- No asset dumps without provenance.
- No replacing the existing Pixel Forge or pixel asset pipeline with a duplicate system.
- No game may claim full Prismcade compatibility unless it declares profile, avatar, cosmetics, input, receipt, leaderboard, and animation-template support levels.
- No portable avatar may bypass the animation template contract unless it is marked as a custom/non-portable character.

## Near-term implementation slices

1. Add `data/prismcade/game-manifests.json`.
2. Add `tools/prismcade/validate-game-manifests.mjs`.
3. Add `apps/prismcade/` as a static catalog/launcher.
4. Add `apps/prismcade-creator/` as a manifest creator MVP.
5. Add `packages/game-assets/manifests/prismcade-assets.json`.
6. Add `docs/prismcade/PORTABLE_AVATAR_CONTRACT.md` and `data/prismcade/view-contract.txt`.
7. Add `docs/prismcade/REUSABLE_ANIMATION_TEMPLATE.md` and animation template validation.
8. Add Pixel Fruit Arena catalog polish and manifest-first match receipt hooks.
9. Add shared profile/avatar/inventory stubs before hosted leaderboards.
10. Add share-card/result-receipt contracts before hosted leaderboards.
