# Repository Audit

Prismtek-apps is the runnable software workspace for Prismtek product surfaces. It is not a single SwiftUI repository and it is not a notes vault.

This audit classifies the current major repo surfaces by their actual role so future moves can be staged without breaking builds.

## Classification rules

| Class | Meaning |
| --- | --- |
| Runnable app | User-facing product surface that launches as an app, web app, desktop app, mobile app, launcher, or local executable surface. |
| Game | Playable game, game prototype, game runtime, or game-specific simulation surface. |
| Service | Server, worker, sync process, API, integration server, or deployable backend. |
| Shared package | Reusable code consumed by multiple runnable surfaces or services. |
| Developer tool | CLI, build helper, validation script, automation, or repo maintenance utility. |
| Documentation | Human/agent-readable architecture, runbook, product, or planning material. |
| Asset | Static images, sprites, app icons, manifests, generated media, or product resources. |
| Config | CI, workspace, build, package-manager, container, XcodeGen, TypeScript, Vite, or deployment configuration. |
| Legacy/deprecated | Older artifact retained for provenance or recovery but not a live source of truth. |
| Misplaced/unknown | Material whose purpose or ownership is unclear, or whose current location hides its real role. |

## Current major surfaces

| Current path | Classification | Notes | Target owner |
| --- | --- | --- | --- |
| `apps/bemore-ios-native/` | Runnable app | Native Apple mobile app. SwiftUI is implementation detail for this product only. | `apps/mobile/bemore-ios-native/` |
| `apps/bemoreagent-platform-ios/` | Runnable app | iOS platform/admin-capable app. Admin screens are product behavior, not top-level placement. | `apps/mobile/bemoreagent-platform-ios/` |
| `apps/bemore-macos-native/` | Runnable app | Native macOS app with Xcode project and TestFlight/release ownership. | `apps/desktop/bemore-macos-native/` |
| `apps/bemore-macos/` | Runnable app | Web/desktop-style BeMore Buddy surface with local gateway pieces. Needs later classification as desktop shell vs web app. | `apps/desktop/bemore-macos/` until proven otherwise |
| `apps/web/` | Runnable app | React/Vite web product surface. | `apps/web/bemore-web/` |
| `apps/prismds-os/` | Runnable app | RGDS userland launcher layer. Not a boot image or flasher. | `apps/desktop/prismds-os/` or `tools/launchers/prismds-os/`; decide by release packaging |
| `games/tamernet-battle-sandbox/` | Game | Browser-playable battle sandbox prototype. | `games/tamernet-battle-sandbox/` |
| `apps/bemore-cli/` | Developer tool | CLI surface for repo/product workflows. | `tools/cli/bemore-cli/` |
| `apps/api/` | Service | Product-facing API server. | `services/api/` |
| `integrations/buddy-chat/` | Service | Deployable Buddy chat integration/server with VPS runbook. | `services/buddy-chat/` |
| `packages/core/` | Shared package | Shared BeMore/Buddy product logic and types. | `packages/core/` |
| `packages/agent-protocol/` | Shared package | Runtime communication contracts and schemas. | `packages/agent-protocol/` |
| `packages/workspace-core/` | Shared package | Workspace shared logic. | `packages/workspace-core/` |
| `packages/app-factory/` | Shared package | App scaffolding/factory logic. | `packages/app-factory/` |
| `packages/sandbox/` | Shared package | Sandbox primitives. Validate consumers before renaming. | `packages/sandbox/` |
| `packages/receipts-core/` | Shared package | Receipt/shared persistence or audit primitives. | `packages/receipts-core/` |
| `scripts/` | Developer tool | Repo-level automation and validation scripts. | `tools/scripts/` after references are updated |
| `.github/workflows/` | Config | CI/CD workflow ownership. | `.github/workflows/` |
| `docs/` | Documentation | Repo, product, architecture, runbook, and planning docs. | `docs/` with architecture/products/runbooks grouping |
| `docs/api/` | Documentation / config | API contracts. Can stay under docs unless generated clients are produced. | `docs/api/` |
| `skills/` | Misplaced/unknown | Agent skills likely belong in buddy-agent, buddy-brain, or KnowledgeVault unless directly powering a runnable product. | Audit before move |
| `context/` | Misplaced/unknown | Context/memory-like material likely belongs in KnowledgeVault or docs. | Audit before move |
| `tvm_home/` | Legacy/deprecated or vendored dependency | Vendored/generated runtime material. Keep only if active Apple local runtime requires it. | `legacy/quarantined-generated/tvm_home/` only after proving unused |
| `.turbo/cache/` | Legacy/deprecated | Generated cache should not be committed as source. | Remove/quarantine after checking CI expectations |
| root `project.pbxproj` / `project.pbxproj.bak` | Legacy/deprecated | Root Xcode project files are suspicious because live Apple products own nested projects. | `legacy/old-xcode-root/` after confirming unused |
| `restored_runtime.swift` | Legacy/deprecated | Recovery artifact unless referenced by an active project. | `legacy/restored-runtime/` after reference scan |
| `docker-compose.yml` | Config | Service/local dev orchestration. | root until service layout is migrated |
| root `package.json`, lockfile, `turbo.json` | Config | Workspace package/build orchestration. | root |

## Immediate findings

1. `apps/` still mixes mobile apps, desktop apps, web apps, CLI tools, services, and launcher products.
2. SwiftUI is present for Apple targets, but it must not define repository-wide architecture.
3. `integrations/buddy-chat` behaves like a service, not a miscellaneous integration folder.
4. `games/tamernet-battle-sandbox` is now the first staged migration into the games workspace.
5. Apple projects should move last because Xcode project paths, generated projects, signing, TestFlight, and Xcode Cloud are path-sensitive.
6. Root/generated artifacts should be quarantined only after reference scans and build validation.

## Non-goals for PR1

- No Xcode project moves.
- No package import rewrites.
- No workflow trigger rewrites unless clearly safe.
- No deletion of generated or legacy-looking files.
- No shared-code extraction until at least two consumers are verified.
