# Package Role Audit

This audit records the current package and app roles in `prismtek-apps` and recommends what should be kept, renamed later, split, or demoted.

## Summary

The repo rename is real, but parts of the codebase still reflect older platform and app-factory assumptions.

The right immediate move is not a giant restructure.
It is to keep the useful pieces, demote the misleading center of gravity, and move gradually toward BeMore-first product ownership.

## Current code reality snapshot

The current implementation still centers a few older assumptions that the docs should not hide:

- `apps/api` still exposes factory-style routes like `/api/factory/templates`, `/api/factory/models`, and `/api/factory/generate`
- `packages/app-factory` still acts as a template catalog plus generation job simulator
- `packages/core` currently mixes product contracts for users, workspaces, templates, sandbox sessions, admin stats, and logs in one place
- `packages/sandbox` is currently a lightweight product adapter around sandbox session lifecycle, not deep runtime ownership

That means the docs are directionally right, but the codebase is still transitional.
The next cleanup steps should acknowledge that reality instead of pretending the product model is already fully re-centered.

## Current recommendations

### `apps/web`
**Recommendation:** keep, but redefine over time

Current posture:
- transitional BeMore web surface
- still contains legacy control-surface and platform-console assumptions

Direction:
- move toward Buddy, Workspace, Memory, Library, and product-first BeMore behavior
- reduce app-factory-first framing over time

### `apps/api`
**Recommendation:** keep, but narrow identity

Current posture:
- product backend with legacy platform/app-factory assumptions still present

Direction:
- move toward BeMore product API ownership
- prefer product-oriented route grouping over generic platform framing

### `packages/core`
**Recommendation:** keep for now, split later if needed

Current posture:
- shared contracts and types
- still a mixed bucket rather than a final domain package

Direction:
- acceptable temporary home for shared product contracts
- later candidate for split into more focused domain packages

### `packages/sandbox`
**Recommendation:** keep

Current posture:
- early product runtime/session adapter layer

Direction:
- likely long-term seed for runtime-adapter or workspace-runtime behavior
- should remain product-owned here rather than being treated as mere leftover scaffolding

### `packages/app-factory`
**Recommendation:** demote hard, then split or rename later

Current posture:
- strongest leftover from the old platform/app-factory center of gravity
- currently provides the template/model catalog and fake generation job flow used by `apps/api`

Direction:
- do not let this package define the product architecture
- if retained, split conceptually into template-catalog and provisioning/generation responsibilities
- if no longer core to the product, mark clearly as secondary or transitional
- likely first candidate for either a rename or a narrower BeMore-specific replacement once the real product flow is clearer

## Keep / rename / split / archive

### Keep
- `apps/web`
- `apps/api`
- `packages/core`
- `packages/sandbox`

### Rename later
- `packages/core`
- `packages/sandbox`

### Split or demote
- `packages/app-factory`

### Archive now
- none of the current top-level apps/packages need immediate archival

## Target direction

Move gradually toward a structure like:
- `apps/bemore-web`
- `apps/api`
- `packages/buddy-core`
- `packages/runtime-adapter`
- `packages/shared-types`
- `packages/template-catalog`

## Recommended next code-facing moves

1. keep `apps/api` working, but gradually rename or regroup factory-first routes under clearer product semantics
2. decide whether template generation is actually a lasting BeMore product feature or just transitional scaffolding
3. split `packages/core` only when real domain seams appear, not for aesthetics alone
4. keep `packages/sandbox` at the adapter layer and resist turning it into runtime substrate ownership

## Rule of thumb

If a package is product implementation, it belongs here.
If it is policy, council, identity philosophy, or cross-repo operator logic, it belongs in `BeMore-stack` instead.
