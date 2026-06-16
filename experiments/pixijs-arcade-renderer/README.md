# PixiJS Arcade Renderer Spike

This experiment evaluates PixiJS as a lightweight rendering/effects layer for Prismtek browser arcade games.

## Why PixiJS

PixiJS may be a better fit than a full game framework when a game already has simple logic but needs better rendering, scaling, particles, and UI polish.

## Best candidate games

| Game | PixiJS fit | Reason |
| --- | --- | --- |
| `games/neon-brick-breaker/` | Strong | Particles, trails, glow, crisp scaling, HUD polish. |
| `games/pixel-snake/` | Strong | Grid rendering, tile effects, score/rank HUD. |
| `games/flappy-pixel/` | Medium | Simple sprite/background/effects pass. |
| `games/pixel-fruit-arena/` | Medium | Could help visuals, but combat logic is larger than a renderer spike. |

## Spike goals

- Determine whether PixiJS can polish existing canvas games without a full Phaser migration.
- Define a renderer-only layer for sprites, particles, HUD, and pixel scaling.
- Compare against Phaser for file size, complexity, and reuse.

## Non-goals

- Do not replace game logic in the first pass.
- Do not add PixiJS as a production dependency until a validation receipt exists.
- Do not commit third-party assets without provenance.

## Decision relationship to Phaser

Use this alongside `experiments/phaser-arcade-upgrade/`.

- Phaser wins if scene/input/game lifecycle is the main problem.
- PixiJS wins if rendering/effects/HUD polish is the main problem.
- Current stack wins if dependency cost outweighs benefits.
