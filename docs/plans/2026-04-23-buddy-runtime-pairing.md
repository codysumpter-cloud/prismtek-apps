# Buddy Runtime Pairing Rollout Plan

**Goal:** add honest runtime pairing, reachability, and degraded-state UX to the Buddy product without pulling full operator workflows into the app shell.

## Outcome

The product should answer these questions clearly:

- Is my Buddy paired to a runtime?
- Is the runtime reachable right now?
- Is the runtime fully available or on a fallback path?
- Are linked account surfaces ready for runtime-backed workflows?

## Slice 1 — shared pairing model

Create a shared model for:

- pairing state
- selected transport mode
- last transport reason
- heartbeat timestamp
- remote-session-available flag

Suggested touch points:

- `packages/agent-protocol/`
- `apps/bemore-ios-native/BeMoreAgentShell/AppModels.swift`
- `apps/bemore-ios-native/BeMoreAgentShell/RuntimeServices.swift`

## Slice 2 — product-safe settings surface

Add a runtime pairing screen that shows:

- paired / unpaired / degraded / limited state
- last heartbeat
- linked account summary
- clear language about relayed vs local behavior

Suggested touch points:

- `apps/bemore-ios-native/BeMoreAgentShell/Views/SettingsView.swift`
- `apps/bemore-ios-native/BeMoreAgentShell/Services/LinkedAccountStore.swift`

## Slice 3 — Buddy status card

Expose pairing truth in the Buddy shell:

- status badge
- short reachability explanation
- fallback wording when only limited runtime access is available

Suggested touch points:

- `apps/bemore-ios-native/BeMoreAgentShell/Views/BuddyView.swift`
- `apps/bemore-ios-native/BeMoreAgentShell/Views/HomeView.swift`

## Slice 4 — runtime truth copy cleanup

Ensure the app does not blur these modes:

- local on-device capability
- paired runtime capability
- unavailable capability

Suggested touch points:

- `apps/bemore-ios-native/BeMoreAgentShell/Views/ChatView.swift`
- `apps/bemore-ios-native/BeMoreAgentShell/Views/ModelsView.swift`
- `apps/bemore-ios-native/BeMoreAgentShell/Features/Models/ModelsTabView.swift`

## Guardrails

- keep the iPhone app native-first
- do not embed field operator controls in the product shell
- do not expose bridge details or secrets
- keep wording short, explicit, and user-facing

## Upstream dependency

This plan depends on the mirrored contracts in:

- `omni-bmo`
- `bmo-stack`
