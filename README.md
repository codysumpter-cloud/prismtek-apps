# Prismtek Apps

![CI](https://github.com/codysumpter-cloud/prismtek-apps/actions/workflows/ci.yml/badge.svg) ![CodeQL](https://github.com/codysumpter-cloud/prismtek-apps/actions/workflows/codeql.yml/badge.svg)

[<kbd>⬇ Download Source ZIP</kbd>](https://github.com/codysumpter-cloud/prismtek-apps/archive/refs/heads/main.zip)
[<kbd>⬇ GitHub Releases</kbd>](https://github.com/codysumpter-cloud/prismtek-apps/releases)
[<kbd>▶ Pixel Fruit Arena</kbd>](games/pixel-fruit-arena/)
[<kbd>▶ TamerNet Battle Sandbox</kbd>](games/tamernet-battle-sandbox/)
[<kbd>▶ Spin Street Showdown</kbd>](games/spin-street-showdown/)
[<kbd>▶ Flappy Pixel</kbd>](games/flappy-pixel/)
[<kbd>▶ Crossy Pixel</kbd>](games/crossy-pixel/)
[<kbd>▶ Pixel Snake</kbd>](games/pixel-snake/)
[<kbd>▶ Neon Brick Breaker</kbd>](games/neon-brick-breaker/)
[<kbd>▶ Pixel Stacker</kbd>](games/pixel-stacker/)
[<kbd>▶ Prismwilds: Echo Dominion</kbd>](games/prismwilds-echo-dominion/)
[<kbd>Prismcade catalog</kbd>](apps/prismcade/)
[<kbd>Prismcade creator</kbd>](apps/prismcade-creator/)
[<kbd>Prismcade platform loop</kbd>](docs/prismcade/PRISMCADE_PLATFORM.md)
[<kbd>Prismcade character factory</kbd>](docs/prismcade/CHARACTER_FACTORY.md)
[<kbd>Prismcade contracts</kbd>](docs/integrations/gamemaker-html5-adapter.md)
[<kbd>🧪 Experiments</kbd>](experiments/)
[<kbd>📚 Reference registry</kbd>](docs/games/open-source-reference-games.md)
[<kbd>🎨 Asset policy</kbd>](docs/assets/asset-source-policy.md)
[<kbd>🕹 Arcade feel guide</kbd>](docs/games/prismtek-arcade-feel.md)
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

All active Prismtek game folders currently under `games/` are listed here.

| Game | Path | Status | Shared feel target | Run locally |
| --- | --- | --- | --- | --- |
| Pixel Fruit Arena | [`games/pixel-fruit-arena/`](games/pixel-fruit-arena/) | Playable browser/PWA MVP with Prismcade/Pixellab roster; web ZIP path exists; DS source exists; public release artifacts pending. | Local platform-fighter matches with Buddy, Prismtek, Prismtek Jones, Female Blue Hoodie, Ponytail Guy, PixelGod variants, readable powers, ring-outs, awakening, rank rewards, and match receipts. | `cd games/pixel-fruit-arena && npm test && npm run validate:prismcade-roster && npm run package:zip` |
| TamerNet Battle Sandbox | [`games/tamernet-battle-sandbox/`](games/tamernet-battle-sandbox/) | Playable browser prototype; smoke test and web ZIP path exist; DS source exists; public release artifacts pending. | Quick creature command battles with readable roles, alpha encounters, PvP-ready duel rules, rank rewards, and match receipts. | `cd games/tamernet-battle-sandbox && npm test && npm run package:zip` |
| Spin Street Showdown | [`games/spin-street-showdown/`](games/spin-street-showdown/) | Playable browser prototype; upgraded physics/RPM/graphics pass, smoke tests, web ZIP path, and DS source exist; public release artifacts pending. | Short retro PvP dome clashes with launch skill, RPM control, rim pressure, burst timing, Spirit Surge, visible rank, and clout rewards. | `cd games/spin-street-showdown && npm test && npm run package:zip` |
| Flappy Pixel | [`games/flappy-pixel/`](games/flappy-pixel/) | Prismtek-site arcade import; browser smoke test and web ZIP path exist; public release artifacts pending. | One-button reflex survival match with score/rank clout. | `cd games/flappy-pixel && npm test && npm run package:zip` |
| Crossy Pixel | [`games/crossy-pixel/`](games/crossy-pixel/) | Prismtek-site arcade import; browser smoke test and web ZIP path exist; public release artifacts pending. | Lane-crossing dodge/run match with streak and distance clout. | `cd games/crossy-pixel && npm test && npm run package:zip` |
| Pixel Snake | [`games/pixel-snake/`](games/pixel-snake/) | Prismtek-site arcade import; browser smoke test and web ZIP path exist; public release artifacts pending. | Classic route-control score match with speed/rank rewards. | `cd games/pixel-snake && npm test && npm run package:zip` |
| Neon Brick Breaker | [`games/neon-brick-breaker/`](games/neon-brick-breaker/) | Prismtek-site arcade import; browser smoke test and web ZIP path exist; public release artifacts pending. | Paddle/brick clear match with combo, accuracy, and score clout. | `cd games/neon-brick-breaker && npm test && npm run package:zip` |
| Pixel Stacker | [`games/pixel-stacker/`](games/pixel-stacker/) | Prismtek-site arcade import; browser smoke test and web ZIP path exist; public release artifacts pending. | Timing/stacking precision match with height, streak, and badge rewards. | `cd games/pixel-stacker && npm test && npm run package:zip` |
| Prismwilds: Echo Dominion | [`games/prismwilds-echo-dominion/`](games/prismwilds-echo-dominion/) | Playable browser creature-survival prototype; smoke test and web ZIP path exist; public release artifacts pending. | Open-world dinosaur-inspired survival with resources, stealth, water, feeder NPCs, roaming dinosaurs, and local-first play. | `cd games/prismwilds-echo-dominion && npm test && npm run package:zip` |

### Game buttons

| Game | Open | README | DS source | Arcade design |
| --- | --- | --- | --- | --- |
| Pixel Fruit Arena | [<kbd>▶ Open</kbd>](games/pixel-fruit-arena/) | [README](games/pixel-fruit-arena/README.md) | [DS source](games/pixel-fruit-arena/ds-homebrew/) | [Shared feel](docs/games/prismtek-arcade-feel.md) |
| TamerNet Battle Sandbox | [<kbd>▶ Open</kbd>](games/tamernet-battle-sandbox/) | [README](games/tamernet-battle-sandbox/README.md) | [DS source](games/tamernet-battle-sandbox/ds-homebrew/) | [Shared feel](docs/games/prismtek-arcade-feel.md) |
| Spin Street Showdown | [<kbd>▶ Open</kbd>](games/spin-street-showdown/) | [README](games/spin-street-showdown/README.md) | [DS source](games/spin-street-showdown/ds-homebrew/) | [PvP loop](games/spin-street-showdown/docs/ARCADE_PVP_LOOP.md) / [reference notes](games/spin-street-showdown/docs/SLAYBLADE_REFERENCE_NOTES.md) / [Shared feel](docs/games/prismtek-arcade-feel.md) |
| Flappy Pixel | [<kbd>▶ Open</kbd>](games/flappy-pixel/) | [README](games/flappy-pixel/README.md) | Missing | [Shared feel](docs/games/prismtek-arcade-feel.md) |
| Crossy Pixel | [<kbd>▶ Open</kbd>](games/crossy-pixel/) | [README](games/crossy-pixel/README.md) | Missing | [Shared feel](docs/games/prismtek-arcade-feel.md) |
| Pixel Snake | [<kbd>▶ Open</kbd>](games/pixel-snake/) | [README](games/pixel-snake/README.md) | Missing | [Shared feel](docs/games/prismtek-arcade-feel.md) |
| Neon Brick Breaker | [<kbd>▶ Open</kbd>](games/neon-brick-breaker/) | [README](games/neon-brick-breaker/README.md) | Missing | [Shared feel](docs/games/prismtek-arcade-feel.md) |
| Pixel Stacker | [<kbd>▶ Open</kbd>](games/pixel-stacker/) | [README](games/pixel-stacker/README.md) | Missing | [Shared feel](docs/games/prismtek-arcade-feel.md) |
| Prismwilds: Echo Dominion | [<kbd>▶ Open</kbd>](games/prismwilds-echo-dominion/) | [README](games/prismwilds-echo-dominion/README.md) | Missing | [Survival design](games/prismwilds-echo-dominion/README.md#survival-design) |

### Shared game release rules

- Do not claim a public download exists until the artifact is attached to GitHub Releases, itch.io, or another verifiable release surface.
- Do not claim a DS binary exists until a `.nds` file is actually built and attached or tested.
- Do not claim RGDS, Steam Deck, Windows, macOS, or Linux verification until there is a real device/runtime receipt.
- Do not ship reference/test assets.
- Keep game loops playable offline/local first.

## Experiments and reference spikes

Experiments are repo-visible research spikes that can graduate into games or tools only after validation. They may use local reference checkouts under `.external/`, but they do not ship third-party engines, modules, binaries, or assets unless provenance is recorded.

| Experiment | Path | Purpose | Status |
| --- | --- | --- | --- |
| OpenBOR Prismtek Evaluation | [`experiments/openbor-prismtek-brawler/`](experiments/openbor-prismtek-brawler/) | Evaluate OpenBOR for an original Prismtek arcade brawler path. | Scaffolded |
| Castagne Pixel Fruit Spike | [`experiments/castagne-pixel-fruit-spike/`](experiments/castagne-pixel-fruit-spike/) | Evaluate Castagne as a Pixel Fruit Arena combat architecture option. | Scaffolded |
| Ikemen GO Prismtek Fighter Spike | [`experiments/ikemen-prismtek-fighter/`](experiments/ikemen-prismtek-fighter/) | Evaluate Ikemen GO for a traditional 2D Prismtek fighter path. | Scaffolded |
| Fighting Engine Bakeoff | [`experiments/fighting-engine-bakeoff/`](experiments/fighting-engine-bakeoff/) | Compare current PFA combat, Castagne, and Ikemen GO. | Scaffolded |

Reference-game and asset-source intake starts here:

```bash
npm run references:validate
node tools/reference-games/import-reference-game.mjs openbor
node tools/reference-games/import-reference-game.mjs castagne
node tools/reference-games/import-reference-game.mjs ikemen-go
```

## Download buttons

| Product | Buttons | Status |
| --- | --- | --- |
| Pixel Fruit Arena | [<kbd>▶ Open</kbd>](games/pixel-fruit-arena/) [<kbd>README</kbd>](games/pixel-fruit-arena/README.md) [<kbd>Prismcade roster</kbd>](games/pixel-fruit-arena/docs/PRISMCADE_PLAYABLE_ROSTER.md) [<kbd>DS source</kbd>](games/pixel-fruit-arena/ds-homebrew/) [<kbd>⬇ Source ZIP</kbd>](https://github.com/codysumpter-cloud/prismtek-apps/archive/refs/heads/main.zip) | Playable browser/PWA MVP with Prismcade/Pixellab roster; web ZIP path exists; DS source exists; public release artifacts pending. |
| TamerNet Battle Sandbox | [<kbd>▶ Open</kbd>](games/tamernet-battle-sandbox/) [<kbd>README</kbd>](games/tamernet-battle-sandbox/README.md) [<kbd>DS source</kbd>](games/tamernet-battle-sandbox/ds-homebrew/) [<kbd>⬇ Source ZIP</kbd>](https://github.com/codysumpter-cloud/prismtek-apps/archive/refs/heads/main.zip) | Playable browser prototype; web ZIP path exists; DS source exists; public release artifacts pending. |
| Spin Street Showdown | [<kbd>▶ Open</kbd>](games/spin-street-showdown/) [<kbd>README</kbd>](games/spin-street-showdown/README.md) [<kbd>DS source</kbd>](games/spin-street-showdown/ds-homebrew/) [<kbd>⬇ Source ZIP</kbd>](https://github.com/codysumpter-cloud/prismtek-apps/archive/refs/heads/main.zip) | Playable browser prototype; web ZIP path exists; DS source exists; public release artifacts pending. |
| Flappy Pixel | [<kbd>▶ Open</kbd>](games/flappy-pixel/) [<kbd>README</kbd>](games/flappy-pixel/README.md) [<kbd>⬇ Source ZIP</kbd>](https://github.com/codysumpter-cloud/prismtek-apps/archive/refs/heads/main.zip) | Browser arcade import; packaged release artifact pending. |
| Crossy Pixel | [<kbd>▶ Open</kbd>](games/crossy-pixel/) [<kbd>README</kbd>](games/crossy-pixel/README.md) [<kbd>⬇ Source ZIP</kbd>](https://github.com/codysumpter-cloud/prismtek-apps/archive/refs/heads/main.zip) | Browser arcade import; packaged release artifact pending. |
| Pixel Snake | [<kbd>▶ Open</kbd>](games/pixel-snake/) [<kbd>README</kbd>](games/pixel-snake/README.md) [<kbd>⬇ Source ZIP</kbd>](https://github.com/codysumpter-cloud/prismtek-apps/archive/refs/heads/main.zip) | Browser arcade import; packaged release artifact pending. |
| Neon Brick Breaker | [<kbd>▶ Open</kbd>](games/neon-brick-breaker/) [<kbd>README</kbd>](games/neon-brick-breaker/README.md) [<kbd>⬇ Source ZIP</kbd>](https://github.com/codysumpter-cloud/prismtek-apps/archive/refs/heads/main.zip) | Browser arcade import; packaged release artifact pending. |
| Pixel Stacker | [<kbd>▶ Open</kbd>](games/pixel-stacker/) [<kbd>README</kbd>](games/pixel-stacker/README.md) [<kbd>⬇ Source ZIP</kbd>](https://github.com/codysumpter-cloud/prismtek-apps/archive/refs/heads/main.zip) | Browser arcade import; packaged release artifact pending. |
| Prismwilds: Echo Dominion | [<kbd>▶ Open</kbd>](games/prismwilds-echo-dominion/) [<kbd>README</kbd>](games/prismwilds-echo-dominion/README.md) [<kbd>⬇ Source ZIP</kbd>](https://github.com/codysumpter-cloud/prismtek-apps/archive/refs/heads/main.zip) | Browser creature-survival prototype; packaged release artifact pending. |
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
npm run prismcade:validate:all
npm run games:validate-support
npm run references:validate
```

Some projects are intentionally dependency-free browser prototypes and should be run from their own folders. See the product table above.

## Products

| Product | Category | Current path | Role |
| --- | --- | --- | --- |
| Pixel Fruit Arena | Game | `games/pixel-fruit-arena/` | Playable browser/PWA platform-fighting MVP with Prismcade/Pixellab roster and DS source |
| TamerNet Battle Sandbox | Game prototype | `games/tamernet-battle-sandbox/` | Playable browser creature prototype plus DS source |
| Spin Street Showdown | Game prototype | `games/spin-street-showdown/` | Playable browser arcade prototype plus DS source |
| Flappy Pixel | Game | `games/flappy-pixel/` | Prismtek-site arcade import |
| Crossy Pixel | Game | `games/crossy-pixel/` | Prismtek-site arcade import |
| Pixel Snake | Game | `games/pixel-snake/` | Prismtek-site arcade import |
| Neon Brick Breaker | Game | `games/neon-brick-breaker/` | Prismtek-site arcade import |
| Pixel Stacker | Game | `games/pixel-stacker/` | Prismtek-site arcade import |
| Prismwilds: Echo Dominion | Game prototype | `games/prismwilds-echo-dominion/` | Browser creature-survival prototype with local smoke test and web ZIP packager |
| Prismcade catalog | Game platform app | `apps/prismcade/` | Static catalog/launcher for the Prismtek game roster driven by `data/prismcade/game-manifests.json` |
| Prismcade creator MVP | Game creation tool | `apps/prismcade-creator/` | Manifest-first creator prototype for reusable Prismcade game templates and publishing metadata |
| Prismcade character factory | Game asset workflow | `data/prismcade/character-template-registry.json`, `games/pixel-fruit-arena/data/characters/prismcade_playable_roster.json` | Repeatable PixelLab character template and playable roster validation path |
| Prismcade GameMaker adapters | Integration contract | `docs/integrations/gamemaker-html5-adapter.md`, `docs/integrations/gamemaker-cli-tooling.md`, `data/integrations/prismcade-reference-sources.json` | Contract-only Prismcade import/wrapper research validated by `npm run integrations:validate` |
| OpenBOR Prismtek Evaluation | Experiment | `experiments/openbor-prismtek-brawler/` | Original brawler-engine spike using the reference registry workflow |
| Castagne Pixel Fruit Spike | Experiment | `experiments/castagne-pixel-fruit-spike/` | Pixel Fruit Arena combat architecture evaluation |
| Ikemen GO Prismtek Fighter Spike | Experiment | `experiments/ikemen-prismtek-fighter/` | Traditional 2D fighter engine evaluation |
| Fighting Engine Bakeoff | Experiment | `experiments/fighting-engine-bakeoff/` | Comparison scorecard for current PFA, Castagne, and Ikemen GO |
| Reference game registry | Research tooling | `data/reference-games/`, `tools/reference-games/`, `docs/games/open-source-reference-games.md` | External game/engine/asset-source registry and import validation |
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

## Repository model

```text
repo root = Prismtek runnable software workspace
```

Target layout:

```text
apps/
  mobile/
  desktop/
  web/
  admin/

games/
experiments/
services/
packages/
tools/
docs/
legacy/
```

Current code is being moved in stages so existing builds keep working.

## Architecture docs

Start here:

- [`docs/architecture/repository-audit.md`](docs/architecture/repository-audit.md)
- [`docs/architecture/monorepo-target-map.md`](docs/architecture/monorepo-target-map.md)
- [`docs/architecture/path-ownership.md`](docs/architecture/path-ownership.md)
- [`docs/PLATFORM_TEST_MATRIX.md`](docs/PLATFORM_TEST_MATRIX.md)
- [`docs/games/prismtek-arcade-cross-platform-migration.md`](docs/games/prismtek-arcade-cross-platform-migration.md)
- [`docs/games/three-game-platform-readiness.md`](docs/games/three-game-platform-readiness.md)
- [`docs/games/prismtek-arcade-feel.md`](docs/games/prismtek-arcade-feel.md)
- [`docs/games/prismtek-site-arcade-migration-queue.md`](docs/games/prismtek-site-arcade-migration-queue.md)
- [`docs/games/open-source-reference-games.md`](docs/games/open-source-reference-games.md)
- [`docs/assets/asset-source-policy.md`](docs/assets/asset-source-policy.md)
- [`experiments/README.md`](experiments/README.md)
- [`experiments/openbor-prismtek-brawler/README.md`](experiments/openbor-prismtek-brawler/README.md)
- [`experiments/fighting-engine-bakeoff/README.md`](experiments/fighting-engine-bakeoff/README.md)
- [`games/spin-street-showdown/docs/SLAYBLADE_REFERENCE_NOTES.md`](games/spin-street-showdown/docs/SLAYBLADE_REFERENCE_NOTES.md)

These documents are the source of truth for staged repo reorganization, external reference intake, and experiment graduation.

## Repo boundaries

| Repo | Owns |
| --- | --- |
| `Prismtek-apps` | Runnable software workspace and shipped/product surfaces. |
| `KnowledgeVault` | Memory, brain, long-lived notes, graph records, and agent-readable knowledge. |
| `buddy-agent` | Runtime/operator implementation. |
| `buddy-brain` | Orchestration, governance, policy, planning, and coordination. |
| `omni-buddy` | Raspberry Pi/local multimodal Buddy hardware runtime. |

## Migration order

1. Add governance docs and README framing. No product moves.
2. Move browser-playable game prototypes into the games workspace.
3. Keep Prismtek-site arcade imports active in `games/*` and harden them one game at a time.
4. Use `experiments/*` for engine spikes before graduating them into games or tools.
5. Move `apps/bemore-cli` to `tools/cli/bemore-cli`.
6. Move `apps/api` to `services/api` and `integrations/buddy-chat` to `services/buddy-chat`.
7. Decide final ownership for `apps/prismds-os` after packaging review.
8. Move Apple projects last, one product at a time.
9. Quarantine root/generated legacy material only after reference scans.

## Apple development

Apple projects are intentionally left in their current paths until dedicated migration PRs update Xcode, XcodeGen, signing, and CI references.

For the current BeMore iOS native app:

```bash
cd apps/bemore-ios-native
xcodegen generate
open BeMoreAgent.xcodeproj
```

Build example:

```bash
cd apps/bemore-ios-native
xcodegen generate
xcodebuild -project BeMoreAgent.xcodeproj -scheme BeMoreAgent -sdk iphonesimulator build
```

## Safety rules

- Do not bulk-move Xcode projects.
- Do not treat SwiftUI as the repository default.
- Do not bury games, services, or web apps under Apple assumptions.
- Do not claim download links exist unless the artifact or source path exists.
- Do not claim RGDS/OS images, app installers, DS binaries, or signed builds exist until they are packaged and attached.
- Do not ship reference/test assets as release assets.
- Do not commit external reference checkouts from `.external/` or `third_party/local/`.
- Do not copy third-party code, modules, binaries, assets, or audio into shipped paths without a provenance record.
- Do not list arcade imports as public releases until each artifact exists.
- Do not extract shared packages until reuse is proven.
- Do not delete or quarantine root artifacts until reference scans prove they are unused.

## License

Apache-2.0. See `LICENSE`.
