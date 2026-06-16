# Fighting Engine Bakeoff

This bakeoff compares Castagne and Ikemen GO against the current Pixel Fruit Arena browser combat stack.

## Contenders

| Option | Purpose | Experiment |
| --- | --- | --- |
| Current PFA browser stack | Keep the accessible web/PWA path | `games/pixel-fruit-arena/` |
| Castagne | Modern fighting-game combat architecture | `experiments/castagne-pixel-fruit-spike/` |
| Ikemen GO | Traditional 2D fighter engine path | `experiments/ikemen-prismtek-fighter/` |

## Scorecard

Score each area from 1 to 5.

| Area | Current PFA | Castagne | Ikemen GO | Notes |
| --- | --- | --- | --- | --- |
| Move authoring speed |  |  |  |  |
| Directional move variants |  |  |  |  |
| Hitbox tuning |  |  |  |  |
| Controller support |  |  |  |  |
| Web/PWA fit |  |  |  |  |
| Android/RGDS fit |  |  |  |  |
| Linux/RGDS fit |  |  |  |  |
| Netcode/rollback path |  |  |  |  |
| Asset workflow |  |  |  |  |
| Build/release friction |  |  |  |  |

## Decision rules

- Keep current PFA stack if web accessibility and iteration speed beat the engine spikes.
- Borrow concepts if an engine has better data structures but poor platform fit.
- Adopt an engine only if it clearly improves combat quality and release viability.

## Output

The bakeoff should produce a short decision note with:

- winner or no-winner result
- evidence from each spike
- migration impact
- platform impact
- next implementation task
