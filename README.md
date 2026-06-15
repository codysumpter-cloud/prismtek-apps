# Prismtek Apps

Prismtek-apps is the runnable software workspace for Prismtek products: mobile apps, desktop apps, web apps, games, tools, services, demos, and shipped product surfaces.

This is **not** a single SwiftUI repository. SwiftUI is one implementation technology for specific Apple targets.

## Quick links

[<kbd>▶ Pixel Fruit Arena</kbd>](games/pixel-fruit-arena/)
[<kbd>▶ TamerNet Battle Sandbox</kbd>](games/tamernet-battle-sandbox/)
[<kbd>▶ Spin Street Showdown</kbd>](games/spin-street-showdown/)
[<kbd>▶ Flappy Pixel</kbd>](games/flappy-pixel/)
[<kbd>▶ Crossy Pixel</kbd>](games/crossy-pixel/)
[<kbd>▶ Pixel Snake</kbd>](games/pixel-snake/)
[<kbd>▶ Neon Brick Breaker</kbd>](games/neon-brick-breaker/)
[<kbd>▶ Pixel Stacker</kbd>](games/pixel-stacker/)
[<kbd>🎮 Universal game support</kbd>](docs/games/universal-game-platform-standard.md)
[<kbd>🕹 Arcade feel guide</kbd>](docs/games/prismtek-arcade-feel.md)
[<kbd>🧰 Porting kits</kbd>](docs/porting-kits/)
[<kbd>📱 Android dual-screen APKs</kbd>](docs/porting-kits/android-dual-screen-apk.md)
[<kbd>🤖 Roblox target</kbd>](docs/porting-kits/roblox.md)
[<kbd>✅ Platform tracker</kbd>](docs/games/three-game-platform-readiness.md)

## Prismtek Arcade direction

Every game in `games/` should feel like part of the same arcade line: low-resource, highly available, instantly replayable, readable in seconds, and built around rank, rewards, rematches, receipts, and public clout.

Shared design source of truth: [`docs/games/prismtek-arcade-feel.md`](docs/games/prismtek-arcade-feel.md).

Universal input/platform source of truth: [`docs/games/universal-game-platform-standard.md`](docs/games/universal-game-platform-standard.md).

| Shared arcade pillar | Meaning |
| --- | --- |
| Fast to start | Browser/static-first where practical; no login required for local play. |
| Readable immediately | Clear silhouettes, inputs, hit effects, and win/loss states. |
| Skill over bloat | Short matches, instant rematches, mastery through timing and positioning. |
| Input parity | Keyboard/mouse, controller, and touch support should be tracked for every game. |
| Platform parity | Windows, macOS, iOS, Android, Linux, RGDS Android, RGDS Linux, and Roblox targets should be tracked before support is claimed. |
| Low-resource by design | Canvas/static ZIP/small assets before heavy engines or large downloads. |
| Clout loop | Ranks, titles, badges, trails, plaques, trophies, win cards, and leaderboard-ready receipts. |
| Original Prismtek identity | No shipped reference/test assets or copied franchise content. |

## Games

All active Prismtek game folders currently under `games/` are listed here.

| Game | Path | Status | Shared feel target | Run locally |
| --- | --- | --- | --- | --- |
| Pixel Fruit Arena | [`games/pixel-fruit-arena/`](games/pixel-fruit-arena/) | Playable browser/PWA MVP; web ZIP path exists; DS source exists; Android dual-screen config exists; universal support config exists; public release artifacts pending. | Local platform-fighter matches with character identity, readable powers, ring-outs, awakening, rank rewards, and match receipts. | `cd games/pixel-fruit-arena && npm test && npm run build && npm run package:zip` |
| TamerNet Battle Sandbox | [`games/tamernet-battle-sandbox/`](games/tamernet-battle-sandbox/) | Playable browser prototype; smoke test and web ZIP path exist; DS source exists; Android dual-screen config exists; universal support config exists; public release artifacts pending. | Quick creature command battles with readable roles, alpha encounters, PvP-ready duel rules, rank rewards, and match receipts. | `cd games/tamernet-battle-sandbox && npm test && npm run package:zip` |
| Spin Street Showdown | [`games/spin-street-showdown/`](games/spin-street-showdown/) | Playable browser prototype; upgraded physics/RPM/graphics pass, smoke tests, web ZIP path, DS source, Android dual-screen config, and universal support config exist; public release artifacts pending. | Short retro PvP dome clashes with launch skill, RPM control, rim pressure, burst timing, Spirit Surge, visible rank, and clout rewards. | `cd games/spin-street-showdown && npm test && npm run package:zip` |
| Flappy Pixel | [`games/flappy-pixel/`](games/flappy-pixel/) | Prismtek-site arcade import; browser smoke test and web ZIP path exist; public release artifacts pending. | One-button reflex survival match with score/rank clout. | `cd games/flappy-pixel && npm test && npm run package:zip` |
| Crossy Pixel | [`games/crossy-pixel/`](games/crossy-pixel/) | Prismtek-site arcade import; browser smoke test and web ZIP path exist; public release artifacts pending. | Lane-crossing dodge/run match with streak and distance clout. | `cd games/crossy-pixel && npm test && npm run package:zip` |
| Pixel Snake | [`games/pixel-snake/`](games/pixel-snake/) | Prismtek-site arcade import; browser smoke test and web ZIP path exist; public release artifacts pending. | Classic route-control score match with speed/rank rewards. | `cd games/pixel-snake && npm test && npm run package:zip` |
| Neon Brick Breaker | [`games/neon-brick-breaker/`](games/neon-brick-breaker/) | Prismtek-site arcade import; browser smoke test and web ZIP path exist; public release artifacts pending. | Paddle/brick clear match with combo, accuracy, and score clout. | `cd games/neon-brick-breaker && npm test && npm run package:zip` |
| Pixel Stacker | [`games/pixel-stacker/`](games/pixel-stacker/) | Prismtek-site arcade import; browser smoke test and web ZIP path exist; public release artifacts pending. | Timing/stacking precision match with height, streak, and badge rewards. | `cd games/pixel-stacker && npm test && npm run package:zip` |

### Game buttons

| Game | Open | README | DS source | Android dual-screen | Universal support | Arcade design |
| --- | --- | --- | --- | --- | --- | --- |
| Pixel Fruit Arena | [<kbd>▶ Open</kbd>](games/pixel-fruit-arena/) | [README](games/pixel-fruit-arena/README.md) | [DS source](games/pixel-fruit-arena/ds-homebrew/) | [Config](games/pixel-fruit-arena/platforms/android-dual-screen.json) | [Support](games/pixel-fruit-arena/platforms/universal-support.json) | [Shared feel](docs/games/prismtek-arcade-feel.md) |
| TamerNet Battle Sandbox | [<kbd>▶ Open</kbd>](games/tamernet-battle-sandbox/) | [README](games/tamernet-battle-sandbox/README.md) | [DS source](games/tamernet-battle-sandbox/ds-homebrew/) | [Config](games/tamernet-battle-sandbox/platforms/android-dual-screen.json) | [Support](games/tamernet-battle-sandbox/platforms/universal-support.json) | [Shared feel](docs/games/prismtek-arcade-feel.md) |
| Spin Street Showdown | [<kbd>▶ Open</kbd>](games/spin-street-showdown/) | [README](games/spin-street-showdown/README.md) | [DS source](games/spin-street-showdown/ds-homebrew/) | [Config](games/spin-street-showdown/platforms/android-dual-screen.json) | [Support](games/spin-street-showdown/platforms/universal-support.json) | [PvP loop](games/spin-street-showdown/docs/ARCADE_PVP_LOOP.md) / [reference notes](games/spin-street-showdown/docs/SLAYBLADE_REFERENCE_NOTES.md) / [Shared feel](docs/games/prismtek-arcade-feel.md) |
| Flappy Pixel | [<kbd>▶ Open</kbd>](games/flappy-pixel/) | [README](games/flappy-pixel/README.md) | Missing | Pending | Pending | [Shared feel](docs/games/prismtek-arcade-feel.md) |
| Crossy Pixel | [<kbd>▶ Open</kbd>](games/crossy-pixel/) | [README](games/crossy-pixel/README.md) | Missing | Pending | Pending | [Shared feel](docs/games/prismtek-arcade-feel.md) |
| Pixel Snake | [<kbd>▶ Open</kbd>](games/pixel-snake/) | [README](games/pixel-snake/README.md) | Missing | Pending | Pending | [Shared feel](docs/games/prismtek-arcade-feel.md) |
| Neon Brick Breaker | [<kbd>▶ Open</kbd>](games/neon-brick-breaker/) | [README](games/neon-brick-breaker/README.md) | Missing | Pending | Pending | [Shared feel](docs/games/prismtek-arcade-feel.md) |
| Pixel Stacker | [<kbd>▶ Open</kbd>](games/pixel-stacker/) | [README](games/pixel-stacker/README.md) | Missing | Pending | Pending | [Shared feel](docs/games/prismtek-arcade-feel.md) |

### Shared game release rules

- Do not claim a public download exists until the artifact is attached to GitHub Releases, itch.io, or another verifiable release surface.
- Do not claim a DS binary exists until a `.nds` file is actually built and attached or tested.
- Do not claim RGDS, Steam Deck, Windows, macOS, Linux, iOS, Android, or Roblox verification until there is a real device/runtime receipt.
- Do not ship reference/test assets.
- Keep game loops playable offline/local first.

## Download buttons

Packaged releases should be attached to GitHub Releases or another verifiable release surface before the README claims a downloadable installer, app bundle, ROM image, DS binary, APK, Roblox place/module, or hosted build exists.

Porting-kit local downloads can be staged after cloning with:

```bash
npm run porting-kits:download
```

Files are stored in `.porting-kits/` and are intentionally not committed.

## Quick start

Install workspace dependencies:

```bash
npm install
```

Run common checks:

```bash
npm run lint
npm run build
```

Some projects are intentionally dependency-free browser prototypes and should be run from their own folders. See the product table above.

## Products

| Product | Category | Current path | Role |
| --- | --- | --- | --- |
| Pixel Fruit Arena | Game | `games/pixel-fruit-arena/` | Playable browser/PWA platform-fighting MVP plus DS source |
| TamerNet Battle Sandbox | Game prototype | `games/tamernet-battle-sandbox/` | Playable browser creature prototype plus DS source |
| Spin Street Showdown | Game prototype | `games/spin-street-showdown/` | Playable browser arcade prototype plus DS source |
| Flappy Pixel | Game | `games/flappy-pixel/` | Prismtek-site arcade import |
| Crossy Pixel | Game | `games/crossy-pixel/` | Prismtek-site arcade import |
| Pixel Snake | Game | `games/pixel-snake/` | Prismtek-site arcade import |
| Neon Brick Breaker | Game | `games/neon-brick-breaker/` | Prismtek-site arcade import |
| Pixel Stacker | Game | `games/pixel-stacker/` | Prismtek-site arcade import |
| BeMore iOS native | Mobile app | `apps/bemore-ios-native/` | Native iOS Buddy/operator app |
| BeMore Agent Platform iOS | Mobile app | `apps/bemoreagent-platform-ios/` | iOS platform/admin-capable app |
| BeMore macOS native | Desktop app | `apps/bemore-macos-native/` | Native macOS app |
| BeMore desktop/web shell | Desktop/web app | `apps/bemore-macos/` | Desktop-style web app/local shell |
| BeMore web | Web app | `apps/web/` | Browser product surface |
| PrismDS for RGDS | Launcher/userland product | `apps/prismds-os/` | RGDS launcher/userland product |
| BeMore CLI | Developer tool | `apps/bemore-cli/` | Developer CLI |
| Product API | Service | `apps/api/` | Product API service |
| Buddy chat integration | Service/integration | `integrations/buddy-chat/` | Buddy chat integration server |
| Shared packages | Shared code | `packages/*` | Reused product/service code |

## Architecture docs

- [`docs/architecture/repository-audit.md`](docs/architecture/repository-audit.md)
- [`docs/architecture/monorepo-target-map.md`](docs/architecture/monorepo-target-map.md)
- [`docs/architecture/path-ownership.md`](docs/architecture/path-ownership.md)
- [`docs/PLATFORM_TEST_MATRIX.md`](docs/PLATFORM_TEST_MATRIX.md)
- [`docs/games/prismtek-arcade-cross-platform-migration.md`](docs/games/prismtek-arcade-cross-platform-migration.md)
- [`docs/games/three-game-platform-readiness.md`](docs/games/three-game-platform-readiness.md)
- [`docs/games/universal-game-platform-standard.md`](docs/games/universal-game-platform-standard.md)
- [`docs/games/prismtek-arcade-feel.md`](docs/games/prismtek-arcade-feel.md)
- [`docs/porting-kits/README.md`](docs/porting-kits/README.md)
- [`docs/porting-kits/android-dual-screen-apk.md`](docs/porting-kits/android-dual-screen-apk.md)
- [`docs/porting-kits/roblox.md`](docs/porting-kits/roblox.md)
- [`games/spin-street-showdown/docs/SLAYBLADE_REFERENCE_NOTES.md`](games/spin-street-showdown/docs/SLAYBLADE_REFERENCE_NOTES.md)

These documents are the source of truth for staged repo reorganization.

## Repo boundaries

| Repo | Owns |
| --- | --- |
| `Prismtek-apps` | Runnable software workspace and shipped/product surfaces. |
| `KnowledgeVault` | Memory, brain, long-lived notes, graph records, and agent-readable knowledge. |
| `buddy-agent` | Runtime/operator implementation. |
| `buddy-brain` | Orchestration, governance, policy, planning, and coordination. |
| `omni-buddy` | Raspberry Pi/local multimodal Buddy hardware runtime. |
