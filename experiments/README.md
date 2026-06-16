# Prismtek Experiments

Experiments are repo-visible research spikes that are not shipped products yet.

## Current experiments

| Experiment | Purpose | Status |
| --- | --- | --- |
| [`openbor-prismtek-brawler/`](openbor-prismtek-brawler/) | Evaluate OpenBOR for an original Prismtek arcade brawler. | Scaffolded |
| [`castagne-pixel-fruit-spike/`](castagne-pixel-fruit-spike/) | Evaluate Castagne for Pixel Fruit Arena combat architecture. | Scaffolded |
| [`ikemen-prismtek-fighter/`](ikemen-prismtek-fighter/) | Evaluate Ikemen GO for a traditional 2D Prismtek fighter path. | Scaffolded |
| [`fighting-engine-bakeoff/`](fighting-engine-bakeoff/) | Compare current PFA combat, Castagne, and Ikemen GO. | Scaffolded |
| [`phaser-arcade-upgrade/`](phaser-arcade-upgrade/) | Evaluate Phaser as the first shared browser arcade upgrade path. | Scaffolded |
| [`pixijs-arcade-renderer/`](pixijs-arcade-renderer/) | Evaluate PixiJS as a lightweight renderer/effects layer for existing arcade games. | Scaffolded |

## Next arcade target

Start with `games/neon-brick-breaker/` because it is small, visually obvious, and low risk. Use the Phaser and PixiJS spikes to decide whether the first real migration should be framework-led or renderer-only.

## Rules

- Experiments may reference local checkouts under `.external/`.
- Experiments must not ship unreviewed third-party code, assets, audio, modules, or binaries.
- Experiments must graduate through a product/game PR before they become release targets.
