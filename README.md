# Prismtek Apps

![CI](https://github.com/codysumpter-cloud/prismtek-apps/actions/workflows/ci.yml/badge.svg) ![CodeQL](https://github.com/codysumpter-cloud/prismtek-apps/actions/workflows/codeql.yml/badge.svg)

Prismtek-apps is the runnable software workspace for Prismtek applications and actual programs that need to run somewhere: mobile apps, desktop apps, web apps, games, tools, workers, servers, demos, and shipped product surfaces.

It is **not** a single SwiftUI repository. SwiftUI is one implementation technology for specific Apple targets.

It is **not** the KnowledgeVault, the Buddy runtime, or the Buddy governance layer.

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

## Current major surfaces

| Surface | Current path | Role |
| --- | --- | --- |
| BeMore iOS native | `apps/bemore-ios-native/` | Mobile app |
| BeMore Agent Platform iOS | `apps/bemoreagent-platform-ios/` | Mobile app with platform/admin behavior |
| BeMore macOS native | `apps/bemore-macos-native/` | Desktop app |
| BeMore desktop/web shell | `apps/bemore-macos/` | Desktop-style web app/local shell |
| BeMore web | `apps/web/` | Browser product surface |
| PrismDS for RGDS | `apps/prismds-os/` | RGDS launcher/userland product |
| TamerNet battle sandbox | `games/tamernet-battle-sandbox/` | Game prototype |
| BeMore CLI | `apps/bemore-cli/` | Developer CLI |
| Product API | `apps/api/` | Service |
| Buddy chat integration | `integrations/buddy-chat/` | Service/integration server |
| Shared packages | `packages/*` | Reused product/service code |

## Architecture docs

Start here:

- [`docs/architecture/repository-audit.md`](docs/architecture/repository-audit.md)
- [`docs/architecture/monorepo-target-map.md`](docs/architecture/monorepo-target-map.md)
- [`docs/architecture/path-ownership.md`](docs/architecture/path-ownership.md)

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
2. Move `games/tamernet-battle-sandbox` into the games workspace.
3. Move `apps/bemore-cli` to `tools/cli/bemore-cli`.
4. Move `apps/api` to `services/api` and `integrations/buddy-chat` to `services/buddy-chat`.
5. Decide final ownership for `apps/prismds-os` after packaging review.
6. Move Apple projects last, one product at a time.
7. Quarantine root/generated legacy material only after reference scans.

## Quick start

Install workspace dependencies:

```bash
npm install
```

Run the current default dev command:

```bash
npm run dev
```

Run common checks:

```bash
npm run lint
npm run build
```

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

## Game prototype development

Current TamerNet sandbox path:

```bash
cd games/tamernet-battle-sandbox
python3 -m http.server 8080
```

## Safety rules

- Do not bulk-move Xcode projects.
- Do not treat SwiftUI as the repository default.
- Do not bury games, services, or web apps under Apple assumptions.
- Do not extract shared packages until reuse is proven.
- Do not delete or quarantine root artifacts until reference scans prove they are unused.

## License

Apache-2.0. See `LICENSE`.
