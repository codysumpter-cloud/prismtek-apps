# Buddy Personalization Surfaces

## Purpose

This document defines the product-side contract for Buddy appearance, performance, and guided generation inside `prismtek-apps`.

## Product promise

Users should be able to:

- personalize Buddy appearance completely
- personalize Buddy behavior/performance completely
- generate ASCII Buddies through guided prompts
- generate pixel Buddies through guided prompts
- preview and persist animation packs
- keep Buddy customization explicit instead of hiding it in scattered settings

## Boundary

`prismtek-apps` owns:

- Buddy customization UI
- guided prompt flows
- local preview/render surfaces
- saved personalization state
- app routing for Buddy appearance/performance tools
- product-facing adapter contracts for Buddy generation and preview

`bmo-stack` / BeMore-stack owns:

- shared Buddy Runtime
- capability execution
- policy / routing / memory ownership
- runtime-side generation handlers if generation is server-backed
- validation and receipts for bounded Buddy creation tools

## Required surfaces

### Appearance

- render mode: ascii / pixel
- palette
- body style
- face / eyes / accessories
- scale
- preview

### Performance

- response style
- initiative
- strictness
- warmth
- speed vs depth bias
- creativity vs verification bias
- animation intensity

### Animation

- preview by trigger: idle / chat / thinking / working / celebrate / sleep
- packed frames for ascii and pixel modes
- persistent animation pack metadata

### Guided generation

The guided prompt system should collect structured answers and produce:

- appearance profile
- behavior profile
- animation pack
- generation notes
- warnings when requested output cannot be satisfied cleanly

## Honesty rule

No visible Buddy surface should imply fully generated pixel/ascii pipelines unless the product actually has generation + preview + persistence wired for that mode.

If a mode is incomplete, hide it or clearly mark it non-shipping.
