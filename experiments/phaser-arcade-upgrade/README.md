# Phaser Arcade Upgrade Spike

This experiment evaluates Phaser as the first practical upgrade path for Prismtek's existing browser arcade games.

## Why Phaser first

Phaser is the most direct next step because the active arcade games already ship as browser-first experiences. A Phaser spike can improve input, scaling, HUD, effects, scene flow, and touch support without forcing the games into a heavy engine or native packaging path.

## Candidate games

| Game | Why it is a candidate | Risk |
| --- | --- | --- |
| `games/neon-brick-breaker/` | Simple scene, clear score loop, easy particle/effects improvements. | Low |
| `games/pixel-snake/` | Clear grid logic and rank loop; good for shared input/scaling tests. | Low |
| `games/flappy-pixel/` | Smallest one-button loop; great mobile/touch smoke target. | Low |
| `games/pixel-fruit-arena/` | Biggest payoff, but too large for the first renderer spike. | High |

## First game decision

Start with **Neon Brick Breaker**. It is the best first target because visual polish, particles, score/rank receipts, pixel-perfect scaling, and touch/controller input can be tested quickly without changing a complex combat system.

## Spike goals

- Define a shared browser arcade layer.
- Compare Phaser against the current dependency-light browser stack.
- Keep original Prismtek identity and assets.
- Avoid changing shipped game behavior until the spike proves value.
- Produce a clear adopt / borrow / reject decision.

## Non-goals

- Do not migrate every game at once.
- Do not add Phaser as a root dependency until the spike has a validation receipt.
- Do not claim Phaser builds are production-ready until a playable experiment exists.
- Do not mix in unreviewed third-party assets.

## Files

- [`SHARED_ARCADE_LAYER_PLAN.md`](SHARED_ARCADE_LAYER_PLAN.md)
- [`FIRST_GAME_DECISION.md`](FIRST_GAME_DECISION.md)
- [`VALIDATION_PLAN.md`](VALIDATION_PLAN.md)
