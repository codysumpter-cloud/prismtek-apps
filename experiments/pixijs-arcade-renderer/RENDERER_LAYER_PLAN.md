# Renderer Layer Plan

## Purpose

Define a renderer-only layer for games that already have acceptable game logic but need stronger presentation.

## Responsibilities

| Area | Responsibility |
| --- | --- |
| Pixel scaling | Keep sprites and UI crisp across screen sizes. |
| Sprite batching | Render many tiles/bricks/particles efficiently. |
| Particles | Hit sparks, trails, score bursts, impact puffs. |
| HUD | Score/rank/lives/timer overlays. |
| Transitions | Title, pause, game-over, rematch, rank card. |
| Theming | Shared Prismtek arcade palette and effects rules. |

## Minimal renderer concepts

```ts
export type RendererLayerConfig = {
  gameId: string;
  width: number;
  height: number;
  pixelPerfect: boolean;
  palette: string;
};

export type ArcadeEffect =
  | { type: 'spark'; x: number; y: number; intensity: number }
  | { type: 'score-pop'; x: number; y: number; label: string }
  | { type: 'screen-shake'; durationMs: number; strength: number };
```

## Validation

PixiJS is worth adopting if it can improve visuals while leaving existing game logic mostly intact.

Reject PixiJS if the experiment turns into a full engine rewrite anyway; at that point Phaser or current custom code should win.
