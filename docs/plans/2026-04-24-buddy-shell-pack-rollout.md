# Buddy Shell and Pack Rollout Plan

This plan makes `prismtek-apps` the product delivery repo for Buddies without turning it into the long-term home of all Buddy-core logic.

## Product role of this repo

`prismtek-apps` should own the shipped Buddy experience:

- onboarding
- Buddy shell UI
- settings and trust controls
- memory cards and receipts surfaces
- pack install / clone flows
- Creator Buddy, Teen Buddy, and Field Tech Buddy presentation

It should consume shared Buddy-core contracts instead of defining every crown-jewel rule inline forever.

## Product architecture target

### One shell, multiple packs

Build one Buddy shell with installable packs.

Do **not** split into separate app codepaths per Buddy type.

The shell should support:

- dashboard
- chat
- task board
- memory cards
- receipts
- settings
- trust controls
- install / remix / clone flow

### Canonical product-safe objects consumed here

- `BuddyProfile`
- `BuddyPolicy`
- `BuddyMemory`
- `BuddyReceipt`
- `BuddyPack`
- `BuddyTemplate`

These should be imported from the future private Buddy-core repo once created.

## Build sequence

### Slice 1 — shared shell and state model

Suggested touch points:

- `packages/agent-protocol/`
- `packages/core/`
- `apps/bemore-ios-native/BeMoreAgentShell/AppModels.swift`
- `apps/bemore-ios-native/BeMoreAgentShell/RuntimeServices.swift`

Deliver:

- shared shell state
- current Buddy summary card
- receipt list state
- memory card list state
- pack install metadata hooks

### Slice 2 — trust and receipt surfaces

Suggested touch points:

- `apps/bemore-ios-native/BeMoreAgentShell/Views/HomeView.swift`
- `apps/bemore-ios-native/BeMoreAgentShell/Views/ChatView.swift`
- `apps/bemore-ios-native/BeMoreAgentShell/Views/SettingsView.swift`

Deliver:

- clear relayed vs local wording
- receipt ledger view
- memory cards view
- trust controls / privacy copy
- paired / degraded / limited runtime state presentation

### Slice 3 — Creator Buddy alpha

Deliver first:

- idea capture
- project continuity
- draft shelf
- critique mode
- publish checklist
- style preference memory
- next-best-move suggestions

Suggested touch points:

- `apps/bemore-ios-native/BeMoreAgentShell/Views/BuddyView.swift`
- `apps/bemore-ios-native/BeMoreAgentShell/Features/Buddy/`
- `apps/bemore-ios-native/BeMoreAgentShell/Views/HomeView.swift`

### Slice 4 — Teen Buddy alpha

Non-negotiables:

- youth-safe policy mode
- no manipulative bonding loops
- explicit boundaries
- strict escalation and blocked-content posture

This should reuse the same shell and object model, not a separate architecture.

### Slice 5 — Field Tech Buddy alpha

Non-negotiables:

- before/after documentation flow
- checklist-first workflow
- offline-friendly posture
- explicit verification wording for on-site judgment

## Product guardrails

1. never claim local execution when the capability is relayed
2. never export live Buddy state; only sanitized templates
3. every meaningful tool action should create a receipt
4. packs should change behavior and affordances, not invent totally separate product architecture
5. child/youth-safe posture must be policy-backed, not copy-only

## Suggested milestones

### Milestone A

- shell state model
- receipts list
- memory cards list
- settings trust section

### Milestone B

- Creator Buddy alpha complete
- pack install / clone metadata
- template sanitation hookup

### Milestone C

- Teen Buddy alpha
- Field Tech Buddy alpha
- workshop/install/remix surfaces

## Success metrics

- users with 2+ Buddies
- receipts generated per active user
- resumed projects per week
- day-7 retention for Creator Buddy
- trust score
- "this feels like mine" score

## Immediate next actions

1. wire shared Buddy shell state
2. add receipt and memory-card surfaces
3. build Creator Buddy first
4. defer cross-pack polish until the shell and first pack are coherent
