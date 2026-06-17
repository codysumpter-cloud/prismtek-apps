# Prismtek Game Platform Readiness

This tracker covers current `prismtek-apps/games/*` projects.

Shared arcade feel guide: [`docs/games/prismtek-arcade-feel.md`](prismtek-arcade-feel.md).

Status values: **Verified**, **Partially verified**, **Unverified**, **Missing**.

## Active `prismtek-apps` games

| Game | Path | Web browser | Web ZIP | Windows | macOS | Linux / Steam Deck | RGDS Android | RGDS Linux | Nintendo DS source | Shared arcade feel |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Pixel Fruit Arena | `games/pixel-fruit-arena` | Verified | Partially verified | Partially verified | Unverified | Unverified | Unverified | Unverified | Partially verified | Platform-fighter matches with readable powers, ring-outs, awakening, progression, and result summaries. |
| TamerNet Battle Sandbox | `games/tamernet-battle-sandbox` | Verified | Partially verified | Partially verified | Unverified | Unverified | Unverified | Unverified | Partially verified | Creature command battles with readable roles, alpha encounters, PvP-ready rules, progression, and result summaries. |
| Spin Street Showdown | `games/spin-street-showdown` | Verified | Partially verified | Partially verified | Unverified | Unverified | Unverified | Unverified | Partially verified | Retro PvP dome clashes with launch skill, rim pressure, burst timing, Spirit Surge, rank, and cosmetic rewards. |
| Flappy Pixel | `games/flappy-pixel` | Verified | Partially verified | Partially verified | Unverified | Unverified | Unverified | Unverified | Missing | One-button reflex survival match with score/rank clout. |
| Crossy Pixel | `games/crossy-pixel` | Verified | Partially verified | Partially verified | Unverified | Unverified | Unverified | Unverified | Missing | Lane-crossing dodge/run match with streak and distance clout. |
| Pixel Snake | `games/pixel-snake` | Verified | Partially verified | Partially verified | Unverified | Unverified | Unverified | Unverified | Missing | Classic route-control score match with speed/rank rewards. |
| Neon Brick Breaker | `games/neon-brick-breaker` | Verified | Partially verified | Partially verified | Unverified | Unverified | Unverified | Unverified | Missing | Paddle/brick clear match with combo, accuracy, and score clout. |
| Pixel Stacker | `games/pixel-stacker` | Verified | Partially verified | Partially verified | Unverified | Unverified | Unverified | Unverified | Missing | Timing/stacking precision match with height, streak, and badge rewards. |

## Repo receipts

- Pixel Fruit Arena keeps its existing runtime tests, build script, ZIP packaging path, and compact DS source.
- TamerNet has package scripts, a browser smoke test, ZIP packaging path, and compact DS source.
- Spin Street has upgraded browser runtime mechanics, shared smoke test, quality smoke test, ZIP packaging path, and compact DS source.
- Flappy Pixel, Crossy Pixel, Pixel Snake, Neon Brick Breaker, and Pixel Stacker now exist under `games/*` as Prismtek-site arcade imports.
- All eight active games have package scripts, browser smoke tests, and static ZIP packaging paths.
- CI validates all eight active game package entries and smoke tests.

## Shared release target

Each game should grow toward the same low-resource arcade product shape:

1. Browser/local play first.
2. Static ZIP packaging.
3. Local profile and match history.
4. Rank ladder and cosmetic unlocks.
5. Match result JSON.
6. Win/share card.
7. Leaderboard-ready export.
8. Optional hosted leaderboard or ranked API after local result data is stable.

## Remaining receipts before full release

- Build DS outputs on a machine with devkitPro/libnds installed for games that have DS source.
- Decide whether the five Prismtek-site arcade imports should receive separate DS homebrew ports.
- Publish web ZIP artifacts through GitHub Releases or itch.io.
- Test each downloadable game on Windows, macOS, Linux, Steam Deck, RGDS Android mode, and RGDS Linux mode.
- Add local profile, match history, rank progression, cosmetic unlocks, result JSON, and share cards across all active games.
