# Monorepo Target Map

Prismtek-apps is the home for runnable Prismtek software: mobile apps, desktop apps, web apps, games, services, workers, tools, demos, and shipped product surfaces.

It is not the KnowledgeVault, not the Buddy runtime, and not the Buddy governance layer.

## Target principle

```text
repo root = Prismtek runnable software workspace
```

## Canonical top-level layout

```text
Prismtek-apps/
  apps/
    mobile/
    desktop/
    web/
    admin/

  games/

  services/
    api/
    workers/
    sync/

  packages/

  tools/
    cli/
    build/
    scripts/

  docs/
    architecture/
    products/
    runbooks/

  legacy/
```

## Product placement rules

### `apps/mobile/`

Mobile app products and mobile-first app shells.

Planned homes:

```text
apps/mobile/bemore-ios-native/
apps/mobile/bemoreagent-platform-ios/
```

`bemoreagent-platform-ios` belongs under mobile because it is an iOS runtime. Admin screens inside the app are product behavior, not repo placement.

### `apps/desktop/`

Desktop app products, desktop shells, and desktop-first launcher surfaces.

Planned homes:

```text
apps/desktop/bemore-macos-native/
apps/desktop/bemore-macos/
```

`apps/prismds-os` needs one more packaging decision. If treated as a user-facing RGDS launcher product, it can live under `apps/desktop/prismds-os`. If treated primarily as installer/launcher tooling, it should live under `tools/launchers/prismds-os`.

### `apps/web/`

Browser-delivered product surfaces.

Planned homes:

```text
apps/web/bemore-web/
```

### `apps/admin/`

Standalone admin products only.

Do not place mobile apps here just because they contain admin screens. A product goes here only when its runtime is itself an admin app/surface.

### `games/`

Playable games, game prototypes, battle sandboxes, simulation surfaces, and game runtimes.

Current and planned homes:

```text
games/tamernet-battle-sandbox/
games/pixel-fruit-arena/
games/legends-mmo/
```

### `services/`

Deployable backend code: APIs, workers, sync jobs, gateways, integration servers, and service runbooks.

Planned homes:

```text
services/api/
services/buddy-chat/
services/workers/
services/sync/
```

### `packages/`

Shared code only when actually reused.

Keep packages narrow and named by role, not aspiration. Do not extract code just because it feels reusable.

Current homes remain:

```text
packages/core/
packages/agent-protocol/
packages/workspace-core/
packages/app-factory/
packages/sandbox/
packages/receipts-core/
```

Future candidate package names, only after verified reuse:

```text
packages/design-system/
packages/shared-models/
packages/buddy-client/
packages/auth/
packages/knowledge-graph-client/
```

### `tools/`

Developer tools, CLIs, scripts, validators, build helpers, and repo automation.

Planned homes:

```text
tools/cli/bemore-cli/
tools/scripts/
tools/build/
```

### `docs/`

Human and agent-readable docs.

```text
docs/architecture/
docs/products/
docs/runbooks/
docs/api/
docs/plans/
docs/decisions/
```

### `legacy/`

Quarantined material kept for provenance, recovery, or temporary compatibility.

Planned homes after reference scans:

```text
legacy/old-xcode-root/project.pbxproj
legacy/old-xcode-root/project.pbxproj.bak
legacy/restored-runtime/
legacy/quarantined-generated/
```

## Explicit repo boundaries

| Repo | Owns |
| --- | --- |
| `Prismtek-apps` | Runnable software workspace and product surfaces. |
| `KnowledgeVault` | Memory, brain, notes, long-lived knowledge, graph records, agent-readable books. |
| `buddy-agent` | Runtime/operator implementation. |
| `buddy-brain` | Orchestration, governance, policy, planning, and coordination. |
| `omni-buddy` | Raspberry Pi/local multimodal Buddy hardware runtime. |

## Migration order

1. Governance docs and README only.
2. Move `games/tamernet-battle-sandbox` into the games workspace.
3. Move `apps/bemore-cli` to `tools/cli/bemore-cli`.
4. Move `apps/api` to `services/api` and `integrations/buddy-chat` to `services/buddy-chat`.
5. Decide and move `apps/prismds-os` only after packaging ownership is clear.
6. Move Apple projects last, one at a time, after CI and Xcode path checks are proven.
7. Quarantine legacy/generated root material only after reference scans.
