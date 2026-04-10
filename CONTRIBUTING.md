# Contributing

## Purpose

This repo is the canonical product monorepo for **BeMore** and future **Prismtek** apps.

Contribute here when the work is about product implementation.

Do **not** use this repo as a dumping ground for runtime substrate work, public-site ownership, or cross-repo policy that belongs elsewhere.

## Before you add something

Ask:

1. Is this product implementation?
2. Does it belong to the BeMore app or another Prismtek app surface?
3. Is it shared product code that should live in `packages/`?
4. Is it really policy, identity, or runtime infrastructure that belongs in another repo?

## Repo boundaries

### Belongs here
- app UI and app shells
- product-facing APIs
- shared product packages
- Buddy and workspace product implementation
- product build/release automation over time
- implementation-facing docs and decisions

### Does not belong here
- deep runtime substrate and tool execution primitives
- council policy and Buddy operating philosophy
- public marketing/site ownership for `prismtek.dev`
- cross-repo operator automation that is not product-owned

## Structure guide

- `apps/` → product surfaces
- `packages/` → shared product code
- `docs/` → product-repo docs and decisions

## Pull request expectations

PRs should say:
- what changed
- why it belongs in this repo
- whether it changes product behavior, package boundaries, or repo structure
- any migration or follow-up work still needed

## Naming reminders

- repo identity = **Prismtek Apps**
- flagship product = **BeMore**
- temporary display workaround = **BeMore iOS**
- technical lineage = **BeMoreAgent**
