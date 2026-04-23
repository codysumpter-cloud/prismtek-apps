# Agentmemory Adoption Plan for Prismtek Apps

_Date: 2026-04-23_

## Purpose

Adopt `agentmemory` as the first concrete donor path from the fork upgrade program so the shipped Buddy product can use durable recall, preferences, and project-aware context without inventing a second memory system.

## Why this lands here

`prismtek-apps` is the shipped Buddy product surface. The app should expose Buddy-facing memory usefulness, but it should not become the canonical runtime truth for memory contracts. That truth belongs in `bmo-stack`.

## App-side goals

1. Expose explicit config for `AGENTMEMORY_URL` and `AGENTMEMORY_SECRET`
2. Define Buddy-facing memory use cases
3. Route memory-backed Buddy experiences through app-native surfaces
4. Avoid claiming deep integration before runtime truth and health checks are real

## Buddy-facing use cases

### 1. Recall and continuity

Buddy should be able to answer things like:

- what Cody was working on recently
- what the Buddy was taught recently
- which repo, feature, or runtime was touched last
- what preferences or patterns the Buddy should remember

### 2. Preferences and profile

Buddy should be able to surface:

- preferred coding style and UX posture
- product priorities
- current focus areas
- recurring constraints and tradeoffs

### 3. Project profile

Buddy should be able to ground itself in:

- top repos and active surfaces
- repeated workflows
- conventions and operating patterns

### 4. Future cross-agent continuity

The app should be able to benefit from memories also available to Hermes and other supported clients once the runtime contract is stable.

## Product guardrails

- Do not market speculative memory features as already live.
- Do not duplicate memory contracts in app-only code if `bmo-stack` already owns them.
- Keep Buddy-first UX central: memory should make Buddy feel more helpful, not more like a control panel.
- Keep the app native-first even if the memory server is shared with other tools.

## Proposed app/runtime boundary

### `prismtek-apps` owns

- user-facing Buddy memory affordances
- settings/config display for memory availability
- app-level health/status copy
- Buddy recall surfaces, prompts, and presentation

### `bmo-stack` owns

- runtime truth for how memory is consumed
- machine-readable contracts and donor manifest
- operator/runtime posture
- integration glue for shared memory access patterns

## Recommended first implementation slices

### Slice A — config and visibility

- [x] Add `AGENTMEMORY_URL` and `AGENTMEMORY_SECRET` to `.env.example`
- [ ] Add app-side memory availability/status surface
- [ ] Make copy honest when memory runtime is not configured

### Slice B — Buddy recall contract

- [ ] Define minimal recall types used by Buddy:
  - recent work
  - user preferences
  - project profile
  - recent teachings
- [ ] Keep these aligned with `bmo-stack` runtime truth

### Slice C — Buddy UX landing

- [ ] Add Buddy-facing recall entry points in app-native surfaces
- [ ] Prefer concise, useful recall summaries over raw memory dumps
- [ ] Tie recall into onboarding, Buddy tab, and home surfaces where it improves continuity

## Validation

```bash
cd /Users/prismtek/code/prismtek-apps
npm install
npm run dev
```

For iOS-native surfaces:

```bash
cd /Users/prismtek/code/prismtek-apps/apps/bemore-ios-native
xcodegen generate
xcodebuild build -project /Users/prismtek/code/prismtek-apps/apps/bemore-ios-native/BeMoreAgent.xcodeproj -scheme BeMoreAgent -destination 'platform=iOS Simulator,name=iPhone 17'
```
