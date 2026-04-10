# Structure

This document is the current and intended file-structure guide for `prismtek-apps`.

## Current layout

```text
apps/
  api/
  web/

packages/
  app-factory/
  core/
  sandbox/

docs/
  ORGANIZATION.md
  REPO_POSITIONING.md
  STRUCTURE.md
```

## Intended layout direction

```text
apps/
  bemore-web/        BeMore web product surface
  bemore-ios/        BeMore iOS app project or bridge docs
  api/               Product-facing API
  arcade/            Optional future product-family app surface

packages/
  buddy-core/        Buddy models, template contracts, install logic
  design-system/     Shared UI primitives and branding tokens
  product-core/      Shared product-domain types and services
  runtime-adapter/   App-facing runtime adapters that integrate with external execution layers

docs/
  ORGANIZATION.md
  REPO_POSITIONING.md
  STRUCTURE.md
  DECISIONS/
```

## Rules

### `apps/`
Put shipped product surfaces here.

Examples:
- web apps
- mobile app workspaces
- product-facing APIs if they are app-owned

### `packages/`
Put shared product code here.

Examples:
- shared domain types
- Buddy template models
- design system
- reusable product services

### `docs/`
Put product-repo docs here.

Examples:
- repo positioning
- organization rules
- decisions and migration notes
- implementation-facing planning

### `docs/DECISIONS/`
Use this for short architecture decisions.

Suggested naming:
- `0001-product-monorepo.md`
- `0002-bemore-naming-layers.md`

## Current posture

Do not force a full restructure in one pass.

Prefer:
1. naming clarity
2. ownership clarity
3. low-risk cleanup
4. incremental re-homing of product code

Avoid:
- moving everything at once
- duplicating source of truth across repos
- breaking working automation before replacement paths exist
