# Buddy Training + AgentCraft App Surface Plan

## Goal

Keep the Prismtek app-side contract for Buddy Training and AgentCraft aligned with the runtime and policy repos.

## Repo ownership

- `buddy-agent`: executable Buddy Training state updates, local persistence, and AgentCraft event emission.
- `buddy-brain`: source-of-truth contracts and JSON schema.
- `prismtek-apps`: TypeScript app-facing models, display helpers, and future UI surfaces.

## Added app contract

`packages/core/buddyTraining.ts` defines:

- `BuddyTrainingAction`
- `BuddyEvolutionStage`
- `BuddyTrainingStats`
- `BuddyTrainingState`
- `BuddyTrainingDisplayModel`
- `toBuddyTrainingDisplayModel`
- `isBuddyTrainingAction`

These types mirror the Buddy Brain state schema and are exported from `packages/core/index.ts`.

## UI direction

Use original Buddy Garden or Buddy Workshop styling:

- compact companion card
- level and XP progress
- sparks and snacks resources
- top three stats
- achievements and cosmetics
- evolution stage animation hook

Avoid copying referenced game branding or raw activity-tracking mechanics.

## Privacy boundary

App surfaces should render explicitly supplied Buddy Training state only. They should not collect raw keystrokes, global clicks, hidden productivity data, prompt content, or AgentCraft HUD events as proof of work.

## Next implementation steps

1. Add a Buddy Training card to the web Buddy Studio surface.
2. Add a macOS companion widget using `BuddyTrainingDisplayModel`.
3. Add iOS model parity once the runtime handoff path is ready.
4. Add fixtures generated from `buddy --state ./fixtures/buddy-training.json train reward quest_completed`.
