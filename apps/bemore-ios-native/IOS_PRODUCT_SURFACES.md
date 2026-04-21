# iOS Product Surfaces

This file is the current source of truth for what the BeMoreAgent iOS shell actually exposes from
`BeMore-stack`.

## Available inside iOS

### Mission Control

- companion-first Buddy home
- roster, battle, and trade status summary
- optional operator depth for routes, runtime, and receipts
- bundled BMO Stack surface briefs sourced from repo docs when needed

### Buddy

- Buddy care actions with visible stats
- teachable preferences and training persistence
- Buddy customization and appearance expression
- collectible starter roster installs and equip flow
- lightweight local sparring with persisted battle history
- Buddy trade package export/import with validation

### Models

- installed local models
- linked cloud providers
- available cloud models per provider
- active route summary
- local model activation
- cloud route activation and day-to-day model switching
- saved model source URLs

### Chat

- practical Buddy-first conversation flow
- in-app capability framing before operator/runtime depth
- file-context assisted prompts when the user wants them

### Product shell customization

- persisted tab visibility
- persisted tab ordering
- Settings-managed tab editor
- relaunch-safe selected tab handling

### Repo-backed surface briefs

- `docs/MISSION_CONTROL.md`
- `apps/bemore-ios-native/ADMIN_TESTFLIGHT_RUNBOOK.md`
- `docs/POKEMON_CHAMPIONS_TEAM_BUILDER_BACKEND.md`

These are wrapped as mobile briefs inside Mission Control so the app can expose real stack scope
without pretending to ship full desktop parity or a full team-builder product.

## Wrapped

### Mission Control contract

Wrapped as a mobile operator summary plus bundled source brief.

Why:

- the iPhone shell can surface the current operating contract and operator posture
- the phone should not claim to be the full desktop Mission Control service

### TestFlight admin path

Wrapped as an operational brief sourced from the repo runbook.

Why:

- release proof and upload posture are now part of the real `BeMore-stack` workflow
- the app can expose the truth of the release path without trying to upload builds from the phone

### Pokemon Champions team builder backend spec

Wrapped as a bundled brief sourced from the merged spec.

Why:

- PR `#206` already made it real repo scope
- the iOS shell can acknowledge and surface the spec honestly without inventing a fake in-app
  backend client or toy builder

## Deferred

### Full BeMore dashboard parity

Deferred because the current phone shell is product-first, not a full desktop operator workstation.

### Enterprise administration suite

Deferred because real tenancy, approvals, auth, and audit plumbing are not present in this app
target yet.

### Real on-device local runtime

Deferred from PR A because the current shell still boots `MLCBridgeEngine()` with no target
dependency and still falls back to the stub local-runtime path when `MLCSwift` is unavailable.

## Guidance

- Lead with the standalone Buddy loop on iPhone.
- Use Mission Control for the companion-first home and only then optional operator context.
- Use Models for live route selection when the user wants deeper technical help.
- Keep wrapped surfaces clearly labeled as wrapped.
- Do not imply local on-device inference is available until a device-backed runtime proves it.
