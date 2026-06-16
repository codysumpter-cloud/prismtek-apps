# Phaser Arcade Upgrade Validation Plan

## Required checks before adoption

| Check | Requirement |
| --- | --- |
| Current game preservation | Existing `games/neon-brick-breaker/` still runs and packages unchanged. |
| Static/web packaging | Experiment can produce a browser-runnable artifact. |
| Input | Keyboard and touch/pointer controls both work. |
| Scaling | Pixel art remains crisp at common phone, tablet, and desktop sizes. |
| Receipts | End-of-run score/rank data is emitted as a local JSON-compatible object. |
| Performance | Stable frame pacing on normal mobile browser and low-power desktop browser. |
| Asset provenance | Any new assets have source/license receipts. |

## Scorecard

Score each area from 1 to 5.

| Area | Current game | Phaser spike | Notes |
| --- | --- | --- | --- |
| Visual polish |  |  |  |
| Input feel |  |  |  |
| Mobile/touch play |  |  |  |
| Build friction |  |  |  |
| File size |  |  |  |
| Maintainability |  |  |  |
| Shared arcade reuse |  |  |  |

## Decision outcomes

- **Adopt**: move Neon Brick Breaker to Phaser and use the layer for other small arcade games.
- **Borrow**: keep current stack but copy the design ideas into Prismtek-owned code.
- **Reject**: keep Phaser as a registry reference only.
