# Prismtek Apps

Canonical product monorepo for **BeMore** and future **Prismtek** apps.

This repository is the implementation home for the Prismtek app family. It owns product-facing apps, shared product packages, and app-level APIs. It does **not** own the assistant runtime substrate, the council and Buddy policy layer, or the public Prismtek website.

## At a glance

- **Umbrella brand:** Prismtek
- **Flagship product:** BeMore
- **Current App Store display bridge:** BeMore iOS
- **Internal technical app lineage:** BeMoreAgent
- **Repo role:** canonical product monorepo

## Ownership map

Use this mental model:

- **`openclaw`** = engine
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
- **`openclaw`** runtime substrate, tools, sessions, nodes, channels, and deep execution primitives
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

1. Do not duplicate runtime ownership already held by `openclaw`.
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

## Docs

- `docs/REPO_POSITIONING.md` — repo ownership summary and cleanup posture
- `docs/ORGANIZATION.md` — naming layers, ownership split, and migration posture

## Current cleanup priorities

1. keep repo naming and docs aligned
2. clarify package responsibilities
3. move product-owned automation here over time
4. reduce overlap with shadow or transitional app repos
5. keep BeMore implementation decisions close to the product repo

## License

Apache-2.0. See `LICENSE`.
