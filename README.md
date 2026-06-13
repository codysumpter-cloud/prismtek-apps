# Prismtek Apps

![CI](https://github.com/codysumpter-cloud/prismtek-apps/actions/workflows/ci.yml/badge.svg) ![CodeQL](https://github.com/codysumpter-cloud/prismtek-apps/actions/workflows/codeql.yml/badge.svg)

[<kbd>⬇ Download Source ZIP</kbd>](https://github.com/codysumpter-cloud/prismtek-apps/archive/refs/heads/main.zip)
[<kbd>⬇ GitHub Releases</kbd>](https://github.com/codysumpter-cloud/prismtek-apps/releases)
[<kbd>▶ Open Pixel Fruit Arena</kbd>](games/pixel-fruit-arena/)
[<kbd>▶ Open TamerNet Battle Sandbox</kbd>](games/tamernet-battle-sandbox/)
[<kbd>🕹 Arcade migration tracker</kbd>](docs/games/prismtek-arcade-cross-platform-migration.md)

Prismtek-apps is the runnable software workspace for Prismtek products: mobile apps, desktop apps, web apps, games, tools, services, demos, and shipped product surfaces.

This is **not** a single SwiftUI repository. SwiftUI is one implementation technology for specific Apple targets.

This is **not** the KnowledgeVault, the Buddy runtime, or the Buddy governance layer.

## Download buttons

| Product | Buttons | Status |
| --- | --- | --- |
| Pixel Fruit Arena | [<kbd>▶ Open</kbd>](games/pixel-fruit-arena/) [<kbd>README</kbd>](games/pixel-fruit-arena/README.md) [<kbd>⬇ Download ZIP</kbd>](https://github.com/codysumpter-cloud/prismtek-apps/archive/refs/heads/main.zip) | Playable browser/PWA MVP; packaged release artifact pending. |
| TamerNet Battle Sandbox | [<kbd>▶ Open</kbd>](games/tamernet-battle-sandbox/) [<kbd>README</kbd>](games/tamernet-battle-sandbox/README.md) [<kbd>⬇ Download ZIP</kbd>](https://github.com/codysumpter-cloud/prismtek-apps/archive/refs/heads/main.zip) | Playable browser prototype; packaged release artifact pending. |
| BeMore iOS native | [<kbd>Open source</kbd>](apps/bemore-ios-native/) [<kbd>README</kbd>](apps/bemore-ios-native/README.md) [<kbd>TestFlight runbook</kbd>](apps/bemore-ios-native/ADMIN_TESTFLIGHT_RUNBOOK.md) | Native iOS app source; public signed download link pending. |
| BeMore Agent Platform iOS | [<kbd>Open source</kbd>](apps/bemoreagent-platform-ios/) [<kbd>⬇ Download ZIP</kbd>](https://github.com/codysumpter-cloud/prismtek-apps/archive/refs/heads/main.zip) | iOS platform/admin source; signed artifact pending. |
| BeMore macOS native | [<kbd>Open source</kbd>](apps/bemore-macos-native/) [<kbd>⬇ Download ZIP</kbd>](https://github.com/codysumpter-cloud/prismtek-apps/archive/refs/heads/main.zip) | macOS app source; packaged app download pending. |
| BeMore desktop/web shell | [<kbd>Open source</kbd>](apps/bemore-macos/) [<kbd>⬇ Download ZIP</kbd>](https://github.com/codysumpter-cloud/prismtek-apps/archive/refs/heads/main.zip) | Desktop/web shell source; installer pending. |
| BeMore web | [<kbd>Open source</kbd>](apps/web/) [<kbd>⬇ Download ZIP</kbd>](https://github.com/codysumpter-cloud/prismtek-apps/archive/refs/heads/main.zip) | Web app source; hosted link pending. |
| PrismDS for RGDS | [<kbd>Open source</kbd>](apps/prismds-os/) [<kbd>⬇ Download ZIP</kbd>](https://github.com/codysumpter-cloud/prismtek-apps/archive/refs/heads/main.zip) | RGDS launcher/userland source; OS image/download pending. |
| BeMore CLI | [<kbd>Open source</kbd>](apps/bemore-cli/) [<kbd>⬇ Download ZIP</kbd>](https://github.com/codysumpter-cloud/prismtek-apps/archive/refs/heads/main.zip) | CLI source; standalone binary pending. |
| Product API | [<kbd>Open source</kbd>](apps/api/) [<kbd>⬇ Download ZIP</kbd>](https://github.com/codysumpter-cloud/prismtek-apps/archive/refs/heads/main.zip) | Service source; deployment artifact depends on environment. |
| Buddy chat integration | [<kbd>Open source</kbd>](integrations/buddy-chat/) [<kbd>⬇ Download ZIP</kbd>](https://github.com/codysumpter-cloud/prismtek-apps/archive/refs/heads/main.zip) | Integration source; deployment artifact depends on environment. |

## Download, play, and run

> Release packaging is still being standardized. Until a project has a packaged release artifact, the table links to the best current playable/runnable source path and the exact local run instructions.

| Product | Type | Status | Download / open | Run locally |
| --- | --- | --- | --- | --- |
| Pixel Fruit Arena | Browser game / PWA MVP | Playable local multiplayer MVP; web/PWA package path exists; release artifact must be built from source today. | [<kbd>▶ Open</kbd>](games/pixel-fruit-arena/) [<kbd>README</kbd>](games/pixel-fruit-arena/README.md) [<kbd>⬇ Download ZIP</kbd>](https://github.com/codysumpter-cloud/prismtek-apps/archive/refs/heads/main.zip) | `cd games/pixel-fruit-arena && npm test && npm run build` then serve `dist/`, or `npx serve -l 4173 .` for dev. |
| TamerNet Battle Sandbox | Browser game prototype | Playable local browser prototype; no packaged release artifact yet. | [<kbd>▶ Open</kbd>](games/tamernet-battle-sandbox/) [<kbd>README</kbd>](games/tamernet-battle-sandbox/README.md) [<kbd>⬇ Download ZIP</kbd>](https://github.com/codysumpter-cloud/prismtek-apps/archive/refs/heads/main.zip) | `cd games/tamernet-battle-sandbox && python3 -m http.server 8080`, then open `http://localhost:8080`. |
| BeMore iOS native | iOS app | Native SwiftUI iPhone shell with Buddy care/training/collection, provider settings, local persistence, and a stubbed local-runtime boundary until packaged runtime/model libraries are wired. | [<kbd>Open source</kbd>](apps/bemore-ios-native/) [<kbd>README</kbd>](apps/bemore-ios-native/README.md) [<kbd>TestFlight runbook</kbd>](apps/bemore-ios-native/ADMIN_TESTFLIGHT_RUNBOOK.md) | `cd apps/bemore-ios-native && xcodegen generate && open BeMoreAgent.xcodeproj`. |
| BeMore Agent Platform iOS | iOS app | Platform/admin-capable iOS surface; build/release path is repo source today unless a signed build is distributed through Apple tooling. | [<kbd>Open source</kbd>](apps/bemoreagent-platform-ios/) [<kbd>⬇ Download ZIP</kbd>](https://github.com/codysumpter-cloud/prismtek-apps/archive/refs/heads/main.zip) | Open the project from Xcode after inspecting the app folder. |
| BeMore macOS native | macOS app | Native macOS app surface; packaged download link is not published in this README yet. | [<kbd>Open source</kbd>](apps/bemore-macos-native/) [<kbd>⬇ Download ZIP</kbd>](https://github.com/codysumpter-cloud/prismtek-apps/archive/refs/heads/main.zip) | Open/build the native macOS project from Xcode. |
| BeMore desktop/web shell | Desktop-style web/local shell | Desktop/web shell source is present; packaged installer is not published in this README yet. | [<kbd>Open source</kbd>](apps/bemore-macos/) [<kbd>⬇ Download ZIP</kbd>](https://github.com/codysumpter-cloud/prismtek-apps/archive/refs/heads/main.zip) | Install workspace deps, then use the app-specific package scripts. |
| BeMore web | Web app | Browser product surface source is present; hosted production URL is not published in this README yet. | [<kbd>Open source</kbd>](apps/web/) [<kbd>⬇ Download ZIP</kbd>](https://github.com/codysumpter-cloud/prismtek-apps/archive/refs/heads/main.zip) | Install workspace deps, then use the app-specific package scripts. |
| PrismDS for RGDS | RGDS launcher/userland product | Source exists for the RGDS launcher/userland direction; not a boot image, flasher, or downloadable OS image yet. | [<kbd>Open source</kbd>](apps/prismds-os/) [<kbd>⬇ Download ZIP</kbd>](https://github.com/codysumpter-cloud/prismtek-apps/archive/refs/heads/main.zip) | Inspect the app folder and package only through the documented project scripts. |
| BeMore CLI | Developer program | Developer CLI source; no standalone binary release link yet. | [<kbd>Open source</kbd>](apps/bemore-cli/) [<kbd>⬇ Download ZIP</kbd>](https://github.com/codysumpter-cloud/prismtek-apps/archive/refs/heads/main.zip) | Install workspace deps, then use the CLI package scripts. |
| Product API | Service program | Service source; deploy/run artifact depends on environment configuration. | [<kbd>Open source</kbd>](apps/api/) [<kbd>⬇ Download ZIP</kbd>](https://github.com/codysumpter-cloud/prismtek-apps/archive/refs/heads/main.zip) | Install workspace deps, then use the service package scripts. |
| Buddy chat integration | Service/integration program | Integration server source; deploy/run artifact depends on environment configuration. | [<kbd>Open source</kbd>](integrations/buddy-chat/) [<kbd>⬇ Download ZIP</kbd>](https://github.com/codysumpter-cloud/prismtek-apps/archive/refs/heads/main.zip) | Install workspace deps, then use the integration package scripts. |

## What is actually downloadable today?

- **Source ZIP:** [<kbd>⬇ Download Source ZIP</kbd>](https://github.com/codysumpter-cloud/prismtek-apps/archive/refs/heads/main.zip)
- **GitHub Releases:** [<kbd>⬇ Open GitHub Releases</kbd>](https://github.com/codysumpter-cloud/prismtek-apps/releases)
- **Git clone:**

  ```bash
  git clone https://github.com/codysumpter-cloud/prismtek-apps.git
  cd prismtek-apps
  ```

- **Packaged releases:** use GitHub Releases once product artifacts are attached there. Do not claim a product has a downloadable installer, app bundle, ROM image, or hosted build until that artifact exists.

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

## Games

### Pixel Fruit Arena

[<kbd>▶ Open Pixel Fruit Arena</kbd>](games/pixel-fruit-arena/)
[<kbd>⬇ Download Source ZIP</kbd>](https://github.com/codysumpter-cloud/prismtek-apps/archive/refs/heads/main.zip)

Pixel Fruit Arena is a local multiplayer pixel-art platform fighting MVP. It has a character creator, fruit powers, stocks, knockback, ring-outs, awakening, keyboard controls, controller support through the browser Gamepad API, and PWA metadata.

Run from `games/pixel-fruit-arena/`:

```bash
npx serve -l 4173 .
# or
python -m http.server 4173
```

Build and validate:

```bash
cd games/pixel-fruit-arena
npm test
npm run build
```

Known limits: local multiplayer only, placeholder original art, browser-dependent controller mapping, rough first-pass combat balance, and simple CPU behavior.

### TamerNet Battle Sandbox

[<kbd>▶ Open TamerNet Battle Sandbox</kbd>](games/tamernet-battle-sandbox/)
[<kbd>⬇ Download Source ZIP</kbd>](https://github.com/codysumpter-cloud/prismtek-apps/archive/refs/heads/main.zip)

TamerNet Battle Sandbox is a playable browser prototype for creature MMO battle direction. It uses original placeholder creatures and no external franchise assets.

Run from `games/tamernet-battle-sandbox/`:

```bash
python3 -m http.server 8080
```

Then open:

```text
http://localhost:8080
```

Known limits: no server authority, multiplayer, PvP duel mode, marketplace, breeding, economy, legendary custody, or BYO-file importer yet.

### Incoming Prismtek arcade migration

[<kbd>Open migration tracker</kbd>](docs/games/prismtek-arcade-cross-platform-migration.md)
[<kbd>Open GitHub issue #154</kbd>](https://github.com/codysumpter-cloud/prismtek-apps/issues/154)

Verified incoming games from `prismtek-site`:

- Flappy Pixel
- Crossy Pixel
- Pixel Snake
- Neon Brick Breaker
- Pixel Stacker

These are not listed as playable from `prismtek-apps` until their `games/<slug>/` folders exist and builds are validated.

## Products

| Product | Category | Current path | Role |
| --- | --- | --- | --- |
| Pixel Fruit Arena | Game | `games/pixel-fruit-arena/` | Playable browser/PWA platform-fighting MVP |
| TamerNet Battle Sandbox | Game prototype | `games/tamernet-battle-sandbox/` | Playable browser creature-battle sandbox |
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

These documents are the source of truth for staged repo reorganization.

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
3. Move `apps/bemore-cli` to `tools/cli/bemore-cli`.
4. Move `apps/api` to `services/api` and `integrations/buddy-chat` to `services/buddy-chat`.
5. Decide final ownership for `apps/prismds-os` after packaging review.
6. Move Apple projects last, one product at a time.
7. Quarantine root/generated legacy material only after reference scans.

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
- Do not claim RGDS/OS images, app installers, or signed builds exist until they are packaged and attached.
- Do not ship reference/test assets as release assets.
- Do not extract shared packages until reuse is proven.
- Do not delete or quarantine root artifacts until reference scans prove they are unused.

## License

Apache-2.0. See `LICENSE`.
