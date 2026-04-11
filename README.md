# Prismtek Apps

![CI](https://github.com/codysumpter-cloud/prismtek-apps/actions/workflows/ci.yml/badge.svg) ![CodeQL](https://github.com/codysumpter-cloud/prismtek-apps/actions/workflows/codeql.yml/badge.svg)

Canonical product monorepo for **BeMore** and future **Prismtek** apps.

This repository is the implementation home for the Prismtek app family. It owns product-facing apps, shared product packages, and app-level APIs. It does **not** own the assistant runtime substrate, the council and Buddy policy layer, or the public Prismtek website.

## Quick start

```bash
npm install
npm run dev
```

Use this repo when the work is about shipped product implementation.
If the work is really runtime substrate, policy/identity, or public-site ownership, it probably belongs elsewhere.

## At a glance

- **Umbrella brand:** Prismtek
- **Flagship product:** BeMore
- **Current App Store display bridge:** BeMore iOS
- **Internal technical app lineage:** BeMoreAgent
- **Repo role:** canonical product monorepo

## Ownership map

Use this mental model:

- **BeMore runtime substrate** = execution engine and inherited runtime primitives
- **`bmo-stack`** = brain / policy / council / identity
- **`prismtek-site`** = public web world
- **`prismtek-apps`** = shipped app family

If a change belongs to product implementation, it probably belongs here.

## What this repo owns

This repo owns:
- app implementation for **BeMore**
- future Prismtek apps that share product infrastructure
- shared product packages
- product-facing APIs and services
- Buddy UI and Buddy Workshop product surfaces
- shared auth, account, and profile systems
- app-shell, design-system, and product UX patterns
- product build and release automation over time

## What this repo does not own

This repo does **not** own:
- deep runtime substrate, tools, sessions, nodes, channels, and execution primitives outside the BeMore product adapter
- **`bmo-stack`** council policy, Buddy identity rules, memory philosophy, agent operating behavior, and cross-repo governance
- **`prismtek-site`** public website ownership for `prismtek.dev`, site-backed public experiences, and site-specific APIs

## Product naming layers

Use these deliberately instead of flattening everything into one label.

- **Prismtek Apps** = repo / monorepo identity
- **BeMore** = flagship product identity
- **BeMore iOS** = current practical display name where needed
- **BeMoreAgent** = internal technical identifiers that do not need immediate renaming

## Current repository structure

```text
apps/
  api/             Product-facing backend/API
  web/             Current web app surface

packages/
  app-factory/     Product scaffolding and generation primitives
  core/            Shared types and core product contracts
  sandbox/         Product-level sandbox/session adapters

docs/
  DECISIONS/           Short architecture decisions
  ORGANIZATION.md      Naming layers, ownership split, migration posture
  REPO_POSITIONING.md  Repo role and cleanup posture
```

## Near-term structure direction

This repo is expected to grow toward a clearer product layout over time.

```text
apps/
  bemore-web/
  bemore-ios/
  api/
  arcade/            (only if it becomes part of the product family here)

packages/
  buddy-core/
  design-system/
  runtime-adapter/
  product-core/
```

That future structure is directional, not a promise that everything moves at once.

## Working rules

1. Do not duplicate runtime substrate ownership in product packages.
2. Do not duplicate policy and identity ownership already held by `bmo-stack`.
3. Do not treat this repo as the owner of the public marketing and site layer unless that ownership is explicitly moved here.
4. Prefer clear product boundaries over "just put it here for now."
5. If a feature is experimental and not product-canonical, label it clearly.
6. Product implementation lives here, policy and operating philosophy live elsewhere.

## Migration posture

This repo is being promoted from an ambiguously positioned platform monorepo into the canonical Prismtek product repo.

That means:
- ambiguous legacy positioning should be removed
- stale scaffold leftovers should be cleaned up deliberately
- overlapping app repos should eventually be folded in, renamed, or archived
- product-owned automation should migrate here over time when safe
- working systems should not be broken just to satisfy architectural neatness

## Getting started

### Prerequisites

- Node.js 18+
- npm 10+

### Install dependencies

```bash
npm install
```

### Run the product apps in development

```bash
npm run dev
```

### Build the repo

```bash
npm run build
```

### Useful commands

```bash
npm run lint
npm run clean
```

## Docs

### Core repo docs
- `docs/REPO_POSITIONING.md` — repo ownership summary and cleanup posture
- `docs/ORGANIZATION.md` — naming layers, ownership split, and migration posture
- `docs/STRUCTURE.md` — current and intended file structure
- `docs/REPO_OWNERSHIP_MAP.md` — canonical repo roles across the legacy runtime substrate, BMO, Prismtek Site, and Prismtek Apps
- `CONTRIBUTING.md` — contribution boundaries and repo expectations

### Product structure and boundaries
- `docs/PACKAGE_BOUNDARIES.md` — current package roles and future package direction
- `docs/APP_SURFACES.md` — current and intended app surfaces
- `docs/NEXT_STRUCTURE_PASS.md` — recommended next structural cleanup without premature churn
- `docs/PACKAGE_ROLE_AUDIT.md` — package-by-package review of current roles and likely direction

### Migration and release ownership
- `docs/AUTOMATION_MIGRATION.md` — how product-owned automation should move here over time
- `docs/BEMORE_IOS_BUILD_MIGRATION.md` — target migration path for BeMore iOS build ownership
- `docs/BUILD_OWNERSHIP_AUDIT.md` — audit table for current vs target build/release ownership
- `docs/IOS_BUILD_OWNERSHIP.md` — current notes on iOS build ownership posture

### Working checklists
- `docs/DEV_CHECKLIST.md` — lightweight checklist for meaningful repo changes
- `docs/RELEASE_CHECKLIST.md` — lightweight release-path checklist

### Decisions
- `docs/DECISIONS/0001-product-monorepo.md` — why this repo is the canonical product monorepo
- `docs/DECISIONS/0002-naming-layers.md` — why repo, product, and technical naming are intentionally separated

## Current cleanup priorities

1. keep repo naming and docs aligned
2. clarify package responsibilities
3. move product-owned automation here over time
4. reduce overlap with shadow or transitional app repos
5. keep BeMore implementation decisions close to the product repo

## Branding assets

A polished app logo is important for shipped product surfaces, especially iOS, but it is not required for this repo README to do its job.

Current priority order:
1. real app icon and branding system for the BeMore app
2. consistent product naming across app surfaces
3. optional repo-level branding assets once the product identity is more stable

## License

Apache-2.0. See `LICENSE`.
