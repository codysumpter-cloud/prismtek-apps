# Prismtek Game Platform Readiness

This tracker covers current `prismtek-apps/games/*` projects and the source-confirmed Prismtek-site arcade migration queue.

Shared arcade feel guide: [`docs/games/prismtek-arcade-feel.md`](prismtek-arcade-feel.md).

Prismtek-site migration queue: [`docs/games/prismtek-site-arcade-migration-queue.md`](prismtek-site-arcade-migration-queue.md).

Status values: **Verified**, **Partially verified**, **Unverified**, **Missing**, **Queued**.

## Active `prismtek-apps` games

| Game | Path | Web browser | Web ZIP | Windows | macOS | Linux / Steam Deck | RGDS Android | RGDS Linux | Nintendo DS source | Shared arcade feel |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Pixel Fruit Arena | `games/pixel-fruit-arena` | Verified | Partially verified | Partially verified | Unverified | Unverified | Unverified | Unverified | Partially verified | Platform-fighter matches with readable powers, ring-outs, awakening, progression, and result summaries. |
| TamerNet Battle Sandbox | `games/tamernet-battle-sandbox` | Verified | Partially verified | Partially verified | Unverified | Unverified | Unverified | Unverified | Partially verified | Creature command battles with readable roles, alpha encounters, PvP-ready rules, progression, and result summaries. |
| Spin Street Showdown | `games/spin-street-showdown` | Verified | Partially verified | Partially verified | Unverified | Unverified | Unverified | Unverified | Partially verified | Retro PvP dome clashes with launch skill, rim pressure, burst timing, Spirit Surge, rank, and cosmetic rewards. |

## Prismtek-site arcade migration queue

These games are source-confirmed in `codysumpter-cloud/prismtek-site`, but their target `games/<slug>/` folders are still missing from this repo until migration lands.

| Source game | Source ID | Target path | Source catalog | Prismtek-apps folder | Web ZIP | DS source | Migration status |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Flappy Pixel | `flappy-pixel` | `games/flappy-pixel/` | Verified | Missing | Missing | Missing | Queued |
| Crossy Pixel | `crossy-pixel` | `games/crossy-pixel/` | Verified | Missing | Missing | Missing | Queued |
| Pixel Snake | `pixel-snake` | `games/pixel-snake/` | Verified | Missing | Missing | Missing | Queued |
| Neon Brick Breaker | `neon-brick-breaker` | `games/neon-brick-breaker/` | Verified | Missing | Missing | Missing | Queued |
| Pixel Stacker | `pixel-stacker` | `games/pixel-stacker/` | Verified | Missing | Missing | Missing | Queued |

## Repo receipts

- Pixel Fruit Arena keeps its existing runtime tests, build script, ZIP packaging path, and compact DS source.
- TamerNet has package scripts, a browser smoke test, ZIP packaging path, and compact DS source.
- Spin Street has upgraded browser runtime mechanics, shared smoke test, quality smoke test, ZIP packaging path, and compact DS source.
- All three active games now have DS source folders with a README, Makefile, and `source/main.c`.
- CI validates browser game receipts and DS source receipts for all three active games.
- The root README lists every active current game folder and points to the shared Prismtek Arcade feel guide.
- The root README and queue docs now track five source-confirmed Prismtek-site arcade games still queued for migration.

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

- Build DS outputs on a machine with devkitPro/libnds installed.
- Publish web ZIP artifacts through GitHub Releases or itch.io.
- Test each downloadable game on Windows, macOS, Linux, Steam Deck, RGDS Android mode, and RGDS Linux mode.
- Add local profile, match history, rank progression, cosmetic unlocks, result JSON, and share cards across all active games.
- Migrate Flappy Pixel, Crossy Pixel, Pixel Snake, Neon Brick Breaker, and Pixel Stacker from Prismtek-site into `games/*` before treating them as active Prismtek-apps games.
