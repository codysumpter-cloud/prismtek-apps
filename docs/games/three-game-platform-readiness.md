# Prismtek Game Platform Readiness

This tracker covers every current game under `games/`.

Shared arcade feel guide: [`docs/games/prismtek-arcade-feel.md`](prismtek-arcade-feel.md).

Status values: **Verified**, **Partially verified**, **Unverified**, **Missing**.

| Game | Web browser | Web ZIP | Windows | macOS | Linux / Steam Deck | RGDS Android | RGDS Linux | Nintendo DS source | Shared arcade feel |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Pixel Fruit Arena | Verified | Partially verified | Partially verified | Unverified | Unverified | Unverified | Unverified | Partially verified | Platform-fighter matches with readable powers, ring-outs, awakening, progression, and result summaries. |
| TamerNet Battle Sandbox | Verified | Partially verified | Partially verified | Unverified | Unverified | Unverified | Unverified | Partially verified | Creature command battles with readable roles, alpha encounters, PvP-ready rules, progression, and result summaries. |
| Spin Street Showdown | Verified | Partially verified | Partially verified | Unverified | Unverified | Unverified | Unverified | Partially verified | Retro PvP dome clashes with launch skill, rim pressure, burst timing, Spirit Surge, rank, and cosmetic rewards. |

## Repo receipts

- Pixel Fruit Arena keeps its existing runtime tests, build script, ZIP packaging path, and compact DS source.
- TamerNet has package scripts, a browser smoke test, ZIP packaging path, and compact DS source.
- Spin Street has upgraded browser runtime mechanics, shared smoke test, quality smoke test, ZIP packaging path, and compact DS source.
- All three games now have DS source folders with a README, Makefile, and `source/main.c`.
- CI validates browser game receipts and DS source receipts for all three games.
- The root README lists every current game folder and points to the shared Prismtek Arcade feel guide.

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
- Add local profile, match history, rank progression, cosmetic unlocks, result JSON, and share cards across all three games.
