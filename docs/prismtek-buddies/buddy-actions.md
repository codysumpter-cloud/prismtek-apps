# Prismtek Buddies — Buddy Actions

What Buddy can do in the interactive room today, and the planned expansion.
Surfaced in-app via the **What can Buddy do?** panel (`BuddyActionsView` ->
`WhatCanBuddyDoPanel`).

## Current actions

| Trigger | Object kind | Interaction | Buddy state | Label | Notes |
|---|---|---|---|---|---|
| Tap chair / couch | `chair` | `sit` | `waiting` | "Buddy is sitting" | reuses waiting row; future dedicated sit |
| Tap desk | `desk` | `work` | `running` | "Buddy is working at the desk" | desk anchor places Buddy by the chair |
| Tap computer | `computer` | `work` | `running` | "Buddy is working at the computer" | |
| Tap shelf / picture | `shelf` | `inspect` | `review` | "Buddy is inspecting the ..." | |
| Tap plant | `plant` | `waterPlant` | `review` | "Buddy checks the plant" | future water/garden animation |
| Tap window | `window` | `rest` | `waiting` | "Buddy is resting" | |
| Tap rug | `rug` | `rest` | `waiting` | "Buddy is resting" | idle/play-on-rug placeholder |
| Tap music player | `musicPlayer` | `listen` | `waving` | "Buddy is listening to music" | audio is a placeholder |
| Focus session complete | event | `celebrate` | `jumping` | "Buddy celebrates a finished focus session!" | Pomodoro completion |
| Delete / fail task | event | failed | `failed` | "Buddy reacts to a deleted task" | |
| App appears / greet | event | `wave` | `waving` | "Buddy waves hello" | |
| Buddy picker | UI | switch | current state | selected Buddy changes renderer | Bitbud animated; variants static |
| Buddy Studio | UI | workflow | unchanged | panel opens | import/generation workflow v0 |

## Manual emote buttons

- Wave -> `waving`
- Celebrate -> `jumping`
- Think -> `review`
- Work -> `running`
- Wait -> `waiting`
- Sit -> `waiting`
- Sad -> `failed`

## Static Buddy behavior

Static 64x64 buddies do not have per-state animation rows. They still respond to
clicks and emotes through action labels, anchor movement, and a small state-driven
bob/scale in `StaticBuddyRenderer`. Bitbud remains the default animated atlas
Buddy.

## Current in-app capability list

- Sit on chair
- Work at desk/computer
- Review task
- Wait for user
- Celebrate focus session
- Wave/greet
- React to failed/deleted task
- Inspect shelf
- Water/check plant
- Listen to music placeholder
- Idle/play on rug
- Switch buddies
- Open Buddy Studio

## Future expansion

- Apple Reminders tasks
- Apple Notes context
- GitHub PR/check status
- Codex/Claude build phases
- Obsidian context
- Focus streak gifts/unlocks
- Time-of-day room changes
- More Buddy variants
- Dedicated animations: sit, sleep, dance, eat, read, code, fish, garden, listen
- Room editor / furniture placement
- Mini Mode desktop companion controls
- Live pet generation/import through LibreSprite + PixelLab plugin

See `interactive-room-plan.md` for room-object expansion and
`buddy-studio.md` for Buddy import/generation expansion.
