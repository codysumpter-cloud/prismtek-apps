# Shared Arcade Layer Plan

## Purpose

Create one reusable browser arcade layer that can improve Prismtek's small games without rewriting every game from scratch.

## Layer responsibilities

| Area | Responsibility |
| --- | --- |
| Scene lifecycle | boot, preload, title, play, pause, game over, rematch |
| Input | keyboard, touch, gamepad, pointer, mobile-friendly buttons |
| Scaling | pixel-perfect canvas sizing, safe area handling, responsive layout |
| HUD | score, rank, timer, streak, lives/stocks, match result |
| Effects | hit sparks, particle bursts, screen shake, flash, trail effects |
| Receipts | local score/rank card data for leaderboards and share cards |
| Persistence | local best score, last rank, unlocked badges/cosmetics |
| Audio hooks | music, sfx, mute toggle, mobile unlock handling |

## Minimal API sketch

```ts
export type ArcadeReceipt = {
  gameId: string;
  score: number;
  rank: string;
  durationMs: number;
  timestamp: string;
  modifiers?: string[];
};

export type ArcadeGameConfig = {
  gameId: string;
  title: string;
  pixelScale: number;
  targetWidth: number;
  targetHeight: number;
  controls: string[];
};
```

## Phaser-specific evaluation

Evaluate whether Phaser improves:

- reliable scene switching
- input mapping
- mobile/touch controls
- particle and tween effects
- pause/rematch flow
- debug overlays
- browser packaging

## Decision criteria

Adopt Phaser for an arcade layer only if:

1. one small game feels visibly better,
2. build/package complexity stays reasonable,
3. mobile/touch support improves,
4. it does not break the source-ZIP/static-web release path,
5. it can share receipts/rank logic across multiple games.
