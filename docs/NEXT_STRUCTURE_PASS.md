# Next Structure Pass

## Purpose

This document proposes the next meaningful cleanup after the current repo-positioning and organization work.

The goal is not to churn names for fun. The goal is to reduce ambiguity in app/package ownership and prepare for product-owned automation to live in the right repo.

## Recommendation summary

### Keep immediately
- `apps/web`
- `apps/api`
- `packages/core`
- `packages/sandbox`
- `packages/app-factory`

### Do not rename in a rush
Even though names like `web` and `api` are generic, they are stable enough for now.

The repo just went through a major identity cleanup. The next move should be **clarifying intent**, not forcing cosmetic churn before the implementation picture is more stable.

## Proposed next evolution

### App surfaces

#### Current
- `apps/web`
- `apps/api`

#### Later, when the product shape is more settled
- `apps/bemore-web`
- `apps/api`
- `apps/bemore-ios` (or app-owned iOS bridge/build area)

### Package direction

#### Keep as-is for now
- `packages/core`
- `packages/sandbox`

#### Watch closely
- `packages/app-factory`

`app-factory` is the package most likely to need a real product decision. It may remain product-owned, be narrowed significantly, or be replaced by more BeMore-specific setup flows.

#### Likely future additions
- `packages/buddy-core`
- `packages/design-system`
- `packages/product-core`
- `packages/runtime-adapter`

## Why not rename everything now

Because the repo still needs a lot of product decisions:
- how central app-factory really is
- how BeMore web and iOS divide responsibilities
- what product-owned automation will move here from `bmo-stack`

Renaming too early creates work without creating clarity.

## Best next structural moves

1. keep current folder names for now
2. move product-owned build/release automation here gradually
3. add BeMore-specific packages only when code actually needs them
4. rename `apps/web` only when there is enough BeMore-specific surface area to justify it
5. decide the long-term fate of `packages/app-factory`
