# Prismtek Buddies — Buddy Actions

What Bitbud can do in the interactive room today, and the planned expansion.
Surfaced in-app via the **"What can Buddy do?"** panel (`BuddyActionsView` →
`WhatCanBuddyDoPanel`).

## Current actions

Each row maps an object `kind` (or app event) → `BuddyInteraction` → Bitbud
`BuddyState` animation row → on-screen action label. Mapping lives in
`AppState.state(for:)` and `AppState.label(for:objectName:)`.

| Trigger | Object kind | Interaction | Bitbud state | Label | Notes |
|---|---|---|---|---|---|
| Tap chair / couch | `chair` | `sit` | `waiting` | "Bitbud is sitting" | reuses waiting row (TODO: dedicated sit) |
| Tap desk | `desk` | `work` | `running` | "Bitbud is working at the desk" | |
| Tap computer | `computer` | `work` | `running` | "Bitbud is working at the computer" | |
| Tap shelf / picture | `shelf` | `inspect` | `review` | "Bitbud is inspecting the …" | |
| Tap plant | `plant` | `waterPlant` | `review` | "Bitbud waters the plant" | reuses review row (TODO: dedicated water) |
| Tap window | `window` | `rest` | `waiting` | "Bitbud is resting" | |
| Tap rug | `rug` | `rest` | `waiting` | "Bitbud is resting" | |
| Tap music player | `musicPlayer` | `listen` | `waving` | "Bitbud is listening to music" | audio is a placeholder (no sound shipped) |
| Focus session complete | — (event) | `celebrate` | `jumping` | "Bitbud is celebrating a finished focus session!" | wired in `focusSessionCompleted()` |
| Delete / fail task | — (event) | — | `failed` | "Bitbud reacts to a deleted task" | wired in `deleteTask()` |
| App appears / greet | — (event) | `wave` | `waving` | "Bitbud waves hello" | wired in `greeted()` |

### Manual emote buttons

`BuddyActionsView` also exposes manual emote buttons that set Bitbud's state +
label directly, independent of furniture:

- **Wave** → `waving` · "Bitbud waves hello"
- **Celebrate** → `jumping` · "Bitbud is celebrating!"
- **Think** (inspect) → `review` · "Bitbud is thinking it over"
- **Work** → `running` · "Bitbud is working"
- **Wait** → `waiting` · "Bitbud is waiting"
- **Sit** → `waiting` · "Bitbud is sitting"
- **Sad** (fail) → `failed` · "Bitbud feels sad"

## Future expansion

Listed in the panel's "Future" section:

- Apple Reminders tasks
- Apple Notes memo context
- GitHub PR / check reactions
- Codex / Claude build-phase reactions
- Gifts / unlocks after focus streaks
- Time-of-day room / theme changes
- Choose different Buddies
- Dedicated animations (sit / sleep / dance / eat / read / code / fish / garden)
- Room editor / furniture placement
- Mini Mode desktop companion controls

See `interactive-room-plan.md` for how to add a furniture object or a dedicated
Buddy animation state.
