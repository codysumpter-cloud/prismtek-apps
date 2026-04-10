# Package Boundaries

## Purpose

This document defines the current package roles inside `prismtek-apps` and the intended direction for future cleanup.

## Current packages

### `packages/core`
Current role:
- shared product-domain types and contracts

Keep here if:
- the code is a reusable product-facing type or model
- both app and API need it

Do not turn it into:
- a generic utilities junk drawer
- a policy layer
- a runtime substrate layer

### `packages/sandbox`
Current role:
- product-level sandbox/session adapters used by the app-facing API

Keep here if:
- the code adapts product behavior to external execution or session layers

Do not turn it into:
- the owner of deep execution primitives
- a reimplementation of `openclaw`

### `packages/app-factory`
Current role:
- app/template generation logic and registry

This package needs the most scrutiny.

Questions to keep asking:
- Is app-factory still a real product feature?
- Is it transitional scaffolding?
- Should parts of it become product-specific setup flows instead of generic platform language?

If it remains, narrow it to product-owned behavior.
If not, shrink, move, or retire it instead of letting it define the repo identity.

## Likely future packages

### `packages/product-core`
For shared product-domain services that outgrow the current `core` package.

### `packages/buddy-core`
For Buddy templates, install models, and Buddy-domain logic.

### `packages/design-system`
For shared UI components and app-shell primitives.

### `packages/runtime-adapter`
For app-facing runtime integration that bridges product surfaces to external execution systems without owning the substrate itself.

## Current cleanup priority

1. keep `core` small and clear
2. keep `sandbox` at the adapter layer
3. decide whether `app-factory` is a keeper, a narrowing target, or transitional legacy
4. avoid creating new packages until the need is real
