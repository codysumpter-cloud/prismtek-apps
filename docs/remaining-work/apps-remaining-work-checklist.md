# BeMore iOS app remaining work checklist

This document tracks the remaining work that is still incomplete on the iPhone-native BeMore/Buddy surface after the recent runtime identity, skills cleanup, linked-account relay, onboarding, and native Pixel Studio passes.

## P0

- Get `main` green in CI for the BeMore iOS validation workflow.
- Fix any remaining compile/runtime regressions introduced by the onboarding, native Pixel Studio, linked relay, and Buddy appearance changes.
- Run and document the exact simulator/test commands that the repo expects after the branch is green.

## P1 — Buddy product gaps

- Finish the guided Buddy creation flow so ASCII and Pixel modes are both fully standardized outputs, not just appearance settings plus a seeded studio project.
- Add stronger Buddy ownership feedback in Home/Buddy views so the active Buddy’s guided appearance is clearly visible beyond summary text.
- Convert the current care/training loops into a stronger Tamagotchi-style passive state system with drift over time:
  - ambient energy changes
  - passive mood changes
  - neglected / thriving states
  - lightweight check-in prompts
  - stronger daily rhythm and streak handling
- Ensure Buddy appearance profiles fully preserve pixel-vs-ASCII identity and can be swapped without losing appearance metadata.

## P1 — Pixel Studio gaps

- Let Buddy directly edit the native canvas/timeline data from chat and Studio actions, not just create guidance artifacts beside the canvas.
- Add native frame operations that Buddy can invoke safely:
  - fill / clear regions
  - duplicate / reorder frames
  - palette remap
  - simple onion-skin / preview support
- Improve export paths for native Pixel Studio projects and animation previews.

## P1 — App parity gaps

- Split the Studio surface into clearly distinct app-native destinations instead of loose routing:
  - Pixel Studio
  - Builder / creation tools
  - Mission Control
  - Profiles / account
- Improve the iPhone account/runtime settings so linked provider status, runtime relay state, and provider actions are first-class and clearly actionable.
- Verify that the app never over-leads with runtime/operator depth when the linked runtime is inactive.

## P2 — Cleanup

- Remove the remaining OpenClaw compatibility names still present in app runtime internals where they are no longer required.
- Remove any stale copy implying ChatGPT/OpenAI linked-account support is fully native in-app before the deployment/provider flow is actually complete.
- Add focused tests around:
  - onboarding guided appearance persistence
  - pixel studio native canvas persistence
  - Buddy passive-state drift
  - linked relay status loading
