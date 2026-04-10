# App Surfaces

## Purpose

This document tracks the current and intended app surfaces inside `prismtek-apps`.

## Current surfaces

### `apps/web`
Current role:
- current web app surface
- user-facing product shell
- still carries some transitional assumptions from earlier platform/app-factory positioning

Direction:
- continue shifting toward a clear **BeMore** product surface
- remove leftover platform-first language over time
- keep app-owned UI here until there is a real rename or split reason

### `apps/api`
Current role:
- product-facing API
- currently wires together auth, templates, sandbox launch, and app-generation flows
- still reflects older factory/workspace-console assumptions in its route shape

Direction:
- keep this as the app-owned API layer
- avoid letting it become a vague system backend for things owned elsewhere
- over time, regroup routes around BeMore product capabilities instead of generic platform/factory framing

## Likely future surfaces

### `apps/bemore-web`
Possible future rename or replacement for `apps/web` once the BeMore identity and app structure are mature enough to justify it.

### `apps/bemore-ios`
Possible future home for app-owned iOS project structure, bridge docs, or release automation ownership.

### `apps/arcade`
Only if an arcade surface truly belongs in the shared product family here rather than staying web-owned elsewhere.

## Rule of thumb

If a surface is shipped to users as part of the product family, it belongs under `apps/`.
If it is only shared logic, it probably belongs under `packages/`.
If it is really runtime substrate, policy, or public-web ownership, it belongs elsewhere.
