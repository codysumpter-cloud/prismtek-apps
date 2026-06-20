# Prismtek Buddies Product Direction

Prismtek Buddies Desktop is a cozy productivity room for BUAP pets.

## Current prototype

The prototype supports:

- loading pet packages
- animating Bitbud-style pet atlases
- a room scene
- a to-do list
- a memo pad
- a focus timer
- focus XP and level stubs
- ambience controls
- compact Mini Mode
- event-to-animation state mapping

## State mapping

| Product event | Pet state |
| --- | --- |
| Default presence | `idle` |
| Waiting on user | `waiting` |
| Focus running | `review` or `running` |
| Work review | `review` |
| Error/failure | `failed` |
| Session complete | `jumping` |
| Greeting action | `waving` |

## Differentiator

The Prismtek version should be local-first and BUAP-aware. The pet should eventually react to tasks, notes, checks, PR state, Obsidian context, and Buddy/Lil Buddy work phases.

## Safety

Use original Prismtek UI and assets.

## Native app (cozy room v0)

In addition to the earlier prototype, there is now a native SwiftUI app for macOS and iOS
at `apps/prismtek-buddies-native/` (see `native-app-plan.md`). Same cozy-productivity
vision; original SwiftUI art only; the only bitmap shipped is Bitbud, sliced from Cody's
own pet atlas. The cozy-room genre (e.g. "Mini Cozy Room"-style scenes) is referenced only
as inspiration — no copied art or text. Third-party asset packs are prototype-only and not
shipped.
