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

### `apps/bemore-ios-native`
Current role:
- native iPhone app source of truth for BeMoreAgent / BeMore iOS
- owns the current XcodeGen project inputs, Info.plist, and native app structure
- is the repo path targeted by the current iOS validate/TestFlight workflows
- hosts the product-owned Buddy iPhone surface, not just a placeholder handoff stub

Direction:
- remain the working native iPhone source until there is a deliberate re-home or rename
- keep product-facing Buddy UX and native app release docs truthful here
- avoid docs that still describe the iOS project as if it only lives in `bmo-stack`

### `apps/bemore-macos`
Current role:
- BeMore Mac Build 1 local workstation surface
- workspace tree, text editor, command runner, tasks, diffs, artifacts, receipts, Buddy state, and pairing boundary
- app-owned runtime API for the local Mac vertical slice

Direction:
- become the primary BeMore local IDE/runtime/sandbox app
- keep inherited runtime ideas behind BeMore product-facing language and receipts
- expose Mac pairing deliberately; loopback is the safe default unless the operator opts into a host bind

## Likely future surfaces

### `apps/bemore-web`
Possible future rename or replacement for `apps/web` once the BeMore identity and app structure are mature enough to justify it.

### `apps/bemore-ios`
Possible future rename or re-home for `apps/bemore-ios-native` once the native iPhone project structure is ready for that change. Until then, `apps/bemore-ios-native` is the real working path and should be documented that way.

### `apps/arcade`
Only if an arcade surface truly belongs in the shared product family here rather than staying web-owned elsewhere.

## Rule of thumb

If a surface is shipped to users as part of the product family, it belongs under `apps/`.
If it is only shared logic, it probably belongs under `packages/`.
If it is really runtime substrate, policy, or public-web ownership, it belongs elsewhere.
