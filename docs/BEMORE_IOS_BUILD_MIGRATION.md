# BeMore iOS Build Migration

## Purpose

This document tracks the eventual migration of BeMore iOS build and release ownership into `prismtek-apps`.

## Current posture

BeMore iOS build and release automation may still be operating from `BeMore-stack`.

That is acceptable as a transitional state, but it should not be the final ownership model.

## Target posture

Product-owned build and release automation for BeMore should live in `prismtek-apps`.

`BeMore-stack` may still keep higher-level orchestration or cross-repo wrappers if they are genuinely operator-layer concerns.

## Migration principles

1. do not break a working shipping path just to satisfy architecture neatness
2. recreate working automation here before removing the old path
3. document the current source of truth before migrating it
4. verify the new path with a real build/release flow before demoting the old path

## Migration outline

### Phase 1 - inventory
Capture:
- current scripts and workflows
- Xcode project or target assumptions
- signing assumptions
- archive/export steps
- versioning/build numbering behavior
- App Store or release tooling assumptions

### Phase 2 - establish local ownership
Add product-owned build/release docs and scripts to `prismtek-apps`.

### Phase 3 - verify
Run the new path successfully from `prismtek-apps`.

### Phase 4 - demote old ownership
Once the new path is proven, mark the `BeMore-stack` automation as transitional or wrapper-only.

## Immediate recommendation

Do not migrate the whole iOS build path today.

Instead:
- document the migration target here
- keep the current path working
- move only after the repo and product structure are stable enough to support it cleanly
