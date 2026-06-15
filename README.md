# Prismtek Apps

![CI](https://github.com/codysumpter-cloud/prismtek-apps/actions/workflows/ci.yml/badge.svg) ![CodeQL](https://github.com/codysumpter-cloud/prismtek-apps/actions/workflows/codeql.yml/badge.svg)

[<kbd>⬇ Download Source ZIP</kbd>](https://github.com/codysumpter-cloud/prismtek-apps/archive/refs/heads/main.zip)
[<kbd>⬇ GitHub Releases</kbd>](https://github.com/codysumpter-cloud/prismtek-apps/releases)
[<kbd>▶ Pixel Fruit Arena</kbd>](games/pixel-fruit-arena/)
[<kbd>▶ TamerNet Battle Sandbox</kbd>](games/tamernet-battle-sandbox/)
[<kbd>▶ Spin Street Showdown</kbd>](games/spin-street-showdown/)
[<kbd>🕹 Arcade feel guide</kbd>](docs/games/prismtek-arcade-feel.md)
[<kbd>🧰 Porting kits</kbd>](docs/porting-kits/)
[<kbd>📥 Arcade migration queue</kbd>](docs/games/prismtek-site-arcade-migration-queue.md)
[<kbd>✅ Platform tracker</kbd>](docs/games/three-game-platform-readiness.md)

Prismtek-apps is the runnable software workspace for Prismtek products: mobile apps, desktop apps, web apps, games, tools, services, demos, and shipped product surfaces.

This is **not** a single SwiftUI repository. SwiftUI is one implementation technology for specific Apple targets.

This is **not** the KnowledgeVault, the Buddy runtime, or the Buddy governance layer.

## Prismtek Arcade direction

Every game in `games/` should feel like part of the same arcade line: low-resource, highly available, instantly replayable, readable in seconds, and built around rank, rewards, rematches, receipts, and public clout.

Shared design source of truth: [`docs/games/prismtek-arcade-feel.md`](docs/games/prismtek-arcade-feel.md).

| Shared arcade pillar | Meaning |
| --- | --- |
| Fast to start | Browser/static-first where practical; no login required for local play. |
| Readable immediately | Clear silhouettes, inputs, hit effects, and win/loss states. |
| Skill over bloat | Short matches, instant rematches, mastery through timing and positioning. |
| Low-resource by design | Canvas/static ZIP/small assets before heavy engines or large downloads. |
| Clout loop | Ranks, titles, badges, trails, plaques, trophies, win cards, and leaderboard-ready receipts. |
| Original Prismtek identity | No shipped reference/test assets or copied franchise content. |

## Games

### Active `prismtek-apps` games

These game folders currently exist under `games/` and are part of this repo branch.

| Game | Path | Status | Shared feel target | Run locally |
| --- | --- | --- | --- | --- |
| Pixel Fruit Arena | [`games/pixel-fruit-arena/`](games/pixel-fruit-arena/) | Playable browser/PWA MVP; web ZIP path exists; DS source exists; public release artifacts pending. | Local platform-fighter matches with character identity, readable powers, ring-outs, awakening, rank rewards, and match receipts. | `cd games/pixel-fruit-arena && npm test && npm run build && npm run package:zip` |
| TamerNet Battle Sandbox | [`games/tamernet-battle-sandbox/`](games/tamernet-battle-sandbox/) | Playable browser prototype; smoke test and web ZIP path exist; DS source exists; public release artifacts pending. | Quick creature command battles with readable roles, alpha encounters, PvP-ready duel rules, rank rewards, and match receipts. | `cd games/tamernet-battle-sandbox && npm test && npm run package:zip` |
| Spin Street Showdown | [`games/spin-street-showdown/`](games/spin-street-showdown/) | Playable browser prototype; upgraded physics/graphics pass, smoke tests, web ZIP path, and DS source exist; public release artifacts pending. | Short retro PvP dome clashes with launch skill, rim pressure, burst timing, Spirit Surge, visible rank, and clout rewards. | `cd games/spin-street-showdown && npm test && npm run package:zip` |

### Prismtek-site arcade migration queue

These arcade games are source-confirmed in `codysumpter-cloud/prismtek-site` and are queued to become first-class `games/*` projects here. They are intentionally listed as queued until their source is actually migrated.

Full queue tracker: [`docs/games/prismtek-site-arcade-migration-queue.md`](docs/games/prismtek-site-arcade-migration-queue.md).

| Source game | Source ID | Target path | Migration status | Shared feel target |
| --- | --- | --- | --- | --- |
| Flappy Pixel | `flappy-pixel` | `games/flappy-pixel/` | Queued | One-button reflex survival match with score/rank clout. |
| Crossy Pixel | `crossy-pixel` | `games/crossy-pixel/` | Queued | Lane-crossing dodge/run match with streak and distance clout. |
| Pixel Snake | `pixel-snake` | `games/pixel-snake/` | Queued | Classic route-control score match with speed/rank rewards. |
| Neon Brick Breaker | `neon-brick-breaker` | `games/neon-brick-breaker/` | Queued | Paddle/brick clear match with combo, accuracy, and score clout. |
| Pixel Stacker | `pixel-stacker` | `games/pixel-stacker/` | Queued | Timing/stacking precision match with height, streak, and badge rewards. |

### Game buttons

| Game | Open | README | DS source | Arcade design |
| --- | --- | --- | --- | --- |
| Pixel Fruit Arena | [<kbd>▶ Open</kbd>](games/pixel-fruit-arena/) | [README](games/pixel-fruit-arena/README.md) | [DS source](games/pixel-fruit-arena/ds-homebrew/) | [Shared feel](docs/games/prismtek-arcade-feel.md) |
| TamerNet Battle Sandbox | [<kbd>▶ Open</kbd>](games/tamernet-battle-sandbox/) | [README](games/tamernet-battle-sandbox/README.md) | [DS source](games/tamernet-battle-sandbox/ds-homebrew/) | [Shared feel](docs/games/prismtek-arcade-feel.md) |
| Spin Street Showdown | [<kbd>▶ Open</kbd>](games/spin-street-showdown/) | [README](games/spin-street-showdown/README.md) | [DS source](games/spin-street-showdown/ds-homebrew/) | [PvP loop](games/spin-street-showdown/docs/ARCADE_PVP_LOOP.md) / [Shared feel](docs/games/prismtek-arcade-feel.md) |

Queued Prismtek-site arcade games should **not** get open buttons until their target `games/<slug>/` folders exist.

### Shared game release rules

- Do not claim a public download exists until the artifact is attached to GitHub Releases, itch.io, or another verifiable release surface.
- Do not claim a DS binary exists until a `.nds` file is actually built and attached or tested.
- Do not claim RGDS, Steam Deck, Windows, macOS, or Linux verification until there is a real device/runtime receipt.
- Do not ship reference/test assets.
- Keep game loops playable offline/local first.

## Download buttons

| Product | Buttons | Status |
| --- | --- | --- |
| Pixel Fruit Arena | [<kbd>▶ Open</kbd>](games/pixel-fruit-arena/) [<kbd>README</kbd>](games/pixel-fruit-arena/README.md) [<kbd>DS source</kbd>](games/pixel-fruit-arena/ds-homebrew/) [<kbd>⬇ Source ZIP</kbd>](https://github.com/codysumpter-cloud/prismtek-apps/archive/refs/heads/main.zip) | Playable browser/PWA MVP; web ZIP path exists; DS source exists; public release artifacts pending. |
| TamerNet Battle Sandbox | [<kbd>▶ Open</kbd>](games/tamernet-battle-sandbox/) [<kbd>README</kbd>](games/tamernet-battle-sandbox/README.md) [<kbd>DS source</kbd>](games/tamernet-battle-sandbox/ds-homebrew/) [<kbd>⬇ Source ZIP</kbd>](https://github.com/codysumpter-cloud/prismtek-apps/archive/refs/heads/main.zip) | Playable browser prototype; web ZIP path exists; DS source exists; public release artifacts pending. |
| Spin Street Showdown | [<kbd>▶ Open</kbd>](games/spin-street-showdown/) [<kbd>README</kbd>](games/spin-street-showdown/README.md) [<kbd>DS source</kbd>](games/spin-street-showdown/ds-homebrew/) [<kbd>⬇ Source ZIP</kbd>](https://github.com/codysumpter-cloud/prismtek-apps/archive/refs/heads/main.zip) | Playable browser prototype; web ZIP path exists; DS source exists; public release artifacts pending. |
| Porting kits | [<kbd>🧰 Open docs</kbd>](docs/porting-kits/) [<kbd>Manifest</kbd>](tools/porting-kits/porting-kits.manifest.json) | Setup manifests, downloader scripts, and instructions for web/itch, desktop, Android/RGDS, and DS homebrew. Third-party installers download locally and are not committed. |
| BeMore iOS native | [<kbd>Open source</kbd>](apps/bemore-ios-native/) [<kbd>README</kbd>](apps/bemore-ios-native/README.md) [<kbd>TestFlight runbook</kbd>](apps/bemore-ios-native/ADMIN_TESTFLIGHT_RUNBOOK.md) | Native iOS app source; public signed download link pending. |
| BeMore Agent Platform iOS | [<kbd>Open source</kbd>](apps/bemoreagent-platform-ios/) [<kbd>⬇ Source ZIP</kbd>](https://github.com/codysumpter-cloud/prismtek-apps/archive/refs/heads/main.zip) | iOS platform/admin source; signed artifact pending. |
| BeMore macOS native | [<kbd>Open source</kbd>](apps/bemore-macos-native/) [<kbd>⬇ Source ZIP</kbd>](https://github.com/codysumpter-cloud/prismtek-apps/archive/refs/heads/main.zip) | macOS app source; packaged app download pending. |
| BeMore desktop/web shell | [<kbd>Open source</kbd>](apps/bemore-macos/) [<kbd>⬇ Source ZIP</kbd>](https://github.com/codysumpter-cloud/prismtek-apps/archive/refs/heads/main.zip) | Desktop/web shell source; installer pending. |
| BeMore web | [<kbd>Open source</kbd>](apps/web/) [<kbd>⬇ Source ZIP</kbd>](https://github.com/codysumpter-cloud/prismtek-apps/archive/refs/heads/main.zip) | Web app source; hosted link pending. |
| PrismDS for RGDS | [<kbd>Open source</kbd>](apps/prismds-os/) [<kbd>⬇ Source ZIP</kbd>](https://github.com/codysumpter-cloud/prismtek-apps/archive/refs/heads/main.zip) | RGDS launcher/userland source; OS image/download pending. |
| BeMore CLI | [<kbd>Open source</kbd>](apps/bemore-cli/) [<kbd>⬇ Source ZIP</kbd>](https://github.com/codysumpter-cloud/prismtek-apps/archive/refs/heads/main.zip) | CLI source; standalone binary pending. |
| Product API | [<kbd>Open source</kbd>](apps/api/) [<kbd>⬇ Source ZIP</kbd>](https://github.com/codysumpter-cloud/prismtek-apps/archive/refs/heads/main.zip) | Service source; deployment artifact depends on environment. |
| Buddy chat integration | [<kbd>Open source</kbd>](integrations/buddy-chat/) [<kbd>⬇ Source ZIP</kbd>](https://github.com/codysumpter-cloud/prismtek-apps/archive/refs/heads/main.zip) | Integration source; deployment artifact depends on environment. |

## What is actually downloadable today?

- **Source ZIP:** [<kbd>⬇ Download Source ZIP</kbd>](https://github.com/codysumpter-cloud/prismtek-apps/archive/refs/heads/main.zip)
- **GitHub Releases:** [<kbd>⬇ Open GitHub Releases</kbd>](https://github.com/codysumpter-cloud/prismtek-apps/releases)
- **Git clone:**

  ```bash
  git clone https://github.com/codysumpter-cloud/prismtek-apps.git
  cd prismtek-apps
  ```

- **Porting-kit local downloads:** run `npm run porting-kits:download` after cloning. Files are stored in `.porting-kits/` and are intentionally not committed.
- **Packaged releases:** use GitHub Releases once product artifacts are attached there. Do not claim a product has a downloadable installer, app bundle, ROM image, DS binary, or hosted build until that artifact exists.

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

Prepare local porting-kit sources:

```bash
npm run porting-kits:verify
npm run porting-kits:download
```
