# Prismtek Game Platform Readiness

This tracker covers current `prismtek-apps/games/*` projects.

Shared arcade feel guide: [`docs/games/prismtek-arcade-feel.md`](prismtek-arcade-feel.md).

Universal platform/input standard: [`docs/games/universal-game-platform-standard.md`](universal-game-platform-standard.md).

Porting kit setup: [`docs/porting-kits/README.md`](../porting-kits/README.md).

Android dual-screen APK process: [`docs/porting-kits/android-dual-screen-apk.md`](../porting-kits/android-dual-screen-apk.md).

Roblox porting kit: [`docs/porting-kits/roblox.md`](../porting-kits/roblox.md).

Status values: **Required**, **Configured**, **Partially verified**, **Verified**, **Blocked**, **Missing**, **Not applicable**, **Unverified**.

## Required input support

The first three active games have explicit `platforms/universal-support.json` contracts in this PR. The five imported arcade games are active browser games and should receive matching universal support contracts in a follow-up hardening PR.

| Game | Keyboard | Mouse | Controller | Touch | Support contract |
| --- | --- | --- | --- | --- | --- |
| Pixel Fruit Arena | Partially verified | Required | Required | Configured | [`universal-support.json`](../../games/pixel-fruit-arena/platforms/universal-support.json) |
| TamerNet Battle Sandbox | Partially verified | Required | Required | Configured | [`universal-support.json`](../../games/tamernet-battle-sandbox/platforms/universal-support.json) |
| Spin Street Showdown | Partially verified | Required | Required | Configured | [`universal-support.json`](../../games/spin-street-showdown/platforms/universal-support.json) |
| Flappy Pixel | Verified | Not applicable | Missing | Missing | Missing follow-up |
| Crossy Pixel | Verified | Not applicable | Missing | Missing | Missing follow-up |
| Pixel Snake | Verified | Not applicable | Missing | Missing | Missing follow-up |
| Neon Brick Breaker | Verified | Required | Missing | Missing | Missing follow-up |
| Pixel Stacker | Verified | Required | Missing | Missing | Missing follow-up |

## Active `prismtek-apps` games

| Game | Path | Web browser | Web ZIP | Windows | macOS | Linux / Steam Deck | iOS | Android | RGDS Android | RGDS Linux | Roblox | Nintendo DS source | Shared arcade feel |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Pixel Fruit Arena | `games/pixel-fruit-arena` | Verified | Partially verified | Partially verified | Required | Required | Required | Configured | Configured | Required | Required | Partially verified | Platform-fighter matches with readable powers, ring-outs, awakening, progression, and result summaries. |
| TamerNet Battle Sandbox | `games/tamernet-battle-sandbox` | Verified | Partially verified | Partially verified | Required | Required | Required | Configured | Configured | Required | Required | Partially verified | Creature command battles with readable roles, alpha encounters, PvP-ready rules, progression, and result summaries. |
| Spin Street Showdown | `games/spin-street-showdown` | Verified | Partially verified | Partially verified | Required | Required | Required | Configured | Configured | Required | Required | Partially verified | Retro PvP dome clashes with launch skill, rim pressure, burst timing, Spirit Surge, rank, and cosmetic rewards. |
| Flappy Pixel | `games/flappy-pixel` | Verified | Partially verified | Partially verified | Unverified | Unverified | Unverified | Unverified | Unverified | Unverified | Missing | Missing | One-button reflex survival match with score/rank clout. |
| Crossy Pixel | `games/crossy-pixel` | Verified | Partially verified | Partially verified | Unverified | Unverified | Unverified | Unverified | Unverified | Unverified | Missing | Missing | Lane-crossing dodge/run match with streak and distance clout. |
| Pixel Snake | `games/pixel-snake` | Verified | Partially verified | Partially verified | Unverified | Unverified | Unverified | Unverified | Unverified | Unverified | Missing | Missing | Classic route-control score match with speed/rank rewards. |
| Neon Brick Breaker | `games/neon-brick-breaker` | Verified | Partially verified | Partially verified | Unverified | Unverified | Unverified | Unverified | Unverified | Unverified | Missing | Missing | Paddle/brick clear match with combo, accuracy, and score clout. |
| Pixel Stacker | `games/pixel-stacker` | Verified | Partially verified | Partially verified | Unverified | Unverified | Unverified | Unverified | Unverified | Unverified | Missing | Missing | Timing/stacking precision match with height, streak, and badge rewards. |

## Repo receipts

- Pixel Fruit Arena keeps its existing runtime tests, build script, ZIP packaging path, compact DS source, Android dual-screen config, and universal support contract.
- TamerNet has package scripts, a browser smoke test, ZIP packaging path, compact DS source, Android dual-screen config, and universal support contract.
- Spin Street has upgraded browser runtime mechanics, shared smoke test, quality smoke test, ZIP packaging path, compact DS source, Android dual-screen config, and universal support contract.
- Flappy Pixel, Crossy Pixel, Pixel Snake, Neon Brick Breaker, and Pixel Stacker now exist under `games/*` as Prismtek-site arcade imports.
- All eight active games have package scripts, browser smoke tests, and static ZIP packaging paths.
- All three original active games now have `platforms/android-dual-screen.json` configs validated by `npm run dual-screen:validate`.
- All three original active games now have `platforms/universal-support.json` configs validated by `npm run games:validate-support`.
- The shared dual-screen runtime lives at `packages/prismtek-dual-screen-runtime/` and is smoke-testable with `npm run dual-screen:smoke`.
- CI validates all eight active game package entries and smoke tests.
- Porting-kit setup docs and downloader manifests now live under `docs/porting-kits/` and `tools/porting-kits/`.

## Shared release target

Each game should grow toward the same low-resource arcade product shape:

1. Browser/local play first.
2. Static ZIP packaging.
3. Keyboard/mouse, controller, and touch input parity.
4. Windows, macOS, Linux, iOS, Android, RGDS Android, RGDS Linux, and Roblox platform receipts.
5. Local profile and match history.
6. Rank ladder and cosmetic unlocks.
7. Match result JSON.
8. Win/share card.
9. Leaderboard-ready export.
10. Optional hosted leaderboard or ranked API after local result data is stable.

## Remaining receipts before full release

- Run `npm run platforms:validate` before platform work.
- Run `npm run porting-kits:verify` and `npm run porting-kits:download` on a local machine to stage third-party setup archives outside git.
- Run `npm run dual-screen:validate`, `npm run dual-screen:smoke`, and `npm run games:validate-support` before Android APK wrapper work.
- Build DS outputs on a machine with devkitPro/libnds installed for games that have DS source.
- Decide whether the five Prismtek-site arcade imports should receive separate DS homebrew ports.
- Build Android APK artifacts through the shared Android game shell contract and test display modes.
- Publish web ZIP artifacts through GitHub Releases or itch.io.
- Test each downloadable game on Windows, macOS, Linux, iOS, Android, RGDS Android mode, and RGDS Linux mode.
- Create Roblox adapter/project receipts before claiming Roblox support.
- Add local profile, match history, rank progression, cosmetic unlocks, result JSON, and share cards across all active games.
