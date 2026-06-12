# Path Ownership

This document defines where new runnable Prismtek software should live and how existing code should migrate without breaking builds.

## Ownership summary

| Path | Owns | Does not own |
| --- | --- | --- |
| `apps/mobile/` | Mobile app runtimes. | Shared packages, backend services, generic docs. |
| `apps/desktop/` | Desktop app runtimes and desktop-first app shells. | Server-only code, CLI-only tooling. |
| `apps/web/` | Browser-delivered product surfaces. | Backends, workers, generic package code. |
| `apps/admin/` | Standalone admin product surfaces. | Any app that merely contains admin screens. |
| `games/` | Playable games, prototypes, game runtimes, battle sandboxes. | Generic app scaffolding or backend APIs. |
| `services/` | APIs, workers, sync services, integration servers, gateways. | User-facing apps. |
| `packages/` | Reused code consumed by multiple products/services. | One-off code that belongs to a single product. |
| `tools/` | CLI tools, build scripts, repo automation, validators. | Runtime product code. |
| `docs/` | Architecture, product docs, runbooks, plans, API specs. | Large memory vaults or unrelated notes. |
| `legacy/` | Quarantined files retained for recovery/provenance. | Active build inputs. |

## Placement decision tree

1. Does it launch as a user-facing app?
   - Mobile runtime: `apps/mobile/`
   - Desktop runtime: `apps/desktop/`
   - Browser runtime: `apps/web/`
   - Standalone admin runtime: `apps/admin/`
2. Is it a game or playable prototype?
   - Put it in `games/`.
3. Does it run as a backend process?
   - Put it in `services/`.
4. Is it reused by at least two products or services?
   - Put it in `packages/`.
5. Is it a CLI, script, validator, or build helper?
   - Put it in `tools/`.
6. Is it explanatory, planning, or operational text?
   - Put it in `docs/`.
7. Is it old, generated, suspicious, or only kept for recovery?
   - Put it in `legacy/` only after proving it is not an active build input.

## Path-specific notes

### Apple projects

Apple/Xcode projects are path-sensitive and should move last.

Rules:

- Do not bulk-move Xcode projects.
- Do not move `.xcodeproj`, `project.yml`, `ci_scripts`, signing files, or Xcode Cloud material without validating the project locally and in CI.
- Move one Apple product per PR.
- Keep old path redirects or migration notes during the transition if developer commands change.

### Games

`games/tamernet-battle-sandbox` is the first staged physical move because it is a browser-playable game prototype and was previously misclassified under `apps/`.

Current path:

```text
games/tamernet-battle-sandbox/
```

Validation:

```bash
cd games/tamernet-battle-sandbox
python3 -m http.server 8080
```

### CLI

`apps/bemore-cli` should move after the game move.

Move target:

```text
apps/bemore-cli/
→ tools/cli/bemore-cli/
```

Validation must include package scripts, bin path checks, and any README command updates.

### Services

Services should move after CLI.

Move targets:

```text
apps/api/
→ services/api/

integrations/buddy-chat/
→ services/buddy-chat/
```

Validation must include local build/typecheck commands, Docker/dev-compose references, deploy runbook path updates, and workflow path filters.

### Shared packages

Keep existing packages in place until consumers prove better names are needed.

Do not create `design-system`, `shared-models`, `buddy-client`, `auth`, or `knowledge-graph-client` until there are verified consumers.

### Legacy and root junk

Candidates:

```text
project.pbxproj
project.pbxproj.bak
restored_runtime.swift
tvm_home/
.turbo/cache/
```

Before moving or deleting:

```bash
git grep -n "project.pbxproj\|restored_runtime\|tvm_home\|\.turbo/cache"
npm run build
npm run lint
```

For Apple targets, also run the relevant `xcodegen` and `xcodebuild` commands.

## CI path filter policy

Workflow filters should follow product ownership rather than old path accidents.

Use broad product paths during migration:

```yaml
paths:
  - "apps/**"
  - "games/**"
  - "services/**"
  - "packages/**"
  - "tools/**"
  - "docs/architecture/**"
  - ".github/workflows/**"
```

After migrations settle, workflows can narrow to product-specific paths.

## CODEOWNERS note

A future `CODEOWNERS` file can mirror this map once team ownership exists. Until then, this document is the source of truth for placement decisions.
