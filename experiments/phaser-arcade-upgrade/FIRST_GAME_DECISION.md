# First Game Decision

## Selected first target

**Neon Brick Breaker**

Path:

```txt
games/neon-brick-breaker/
```

## Why this game

Neon Brick Breaker is the cleanest first candidate because it has:

- a simple game loop,
- obvious visual improvement opportunities,
- clear score and rank hooks,
- straightforward touch/mouse/keyboard input,
- low risk of breaking complex combat or progression systems.

## Upgrade hypothesis

A Phaser prototype should make Neon Brick Breaker feel more polished through:

- crisp pixel scaling,
- paddle input smoothing,
- brick-hit particles,
- combo/streak effects,
- clearer score/rank HUD,
- better pause/rematch flow,
- mobile-friendly touch zones.

## Keep unchanged

The spike must preserve the current playable browser game while experimenting separately. Do not replace the current game entrypoint until the spike proves value.

## Graduation path

1. Create a Phaser experiment that mirrors the Neon Brick Breaker loop.
2. Compare file size, build friction, input feel, and visual polish.
3. Record a scorecard.
4. Either adopt Phaser for Neon Brick Breaker, borrow the ideas into the existing stack, or reject Phaser for this game.
