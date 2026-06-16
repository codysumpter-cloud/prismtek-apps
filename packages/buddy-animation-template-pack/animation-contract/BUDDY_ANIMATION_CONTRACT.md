# Buddy Animation Contract

This contract keeps every Buddy variant compatible with Prismtek games, Buddy agents, Grok GIF generation, and future reusable animation tooling.

## Default runtime frame

Use `64x64` pixels per frame unless a specific target requests otherwise.

A `128x128` master sheet may be used for prompt/reference generation, but the game-ready runtime sheet should be exported or cleaned at `64x64`.

## Coordinate system

- Frame origin is top-left.
- Character feet should align to a shared baseline.
- Main silhouette should remain centered unless the animation intentionally lunges or jumps.
- Effects may extend inside the frame but must not require trimming between frames.

## Naming

Use lowercase snake case for state IDs:

```text
idle
blink
breathe
walk
run
jump
land
hurt
faint
wave
happy
shocked
thinking
charge
melee_slash
melee_jab
melee_spin
magic_cast
projectile_launch
status_effect
victory
defeat
```

## Timing guidance

| Family | Recommended frames | FPS | Loop |
| --- | ---: | ---: | --- |
| idle | 4-8 | 6-8 | yes |
| blink | 2-4 | 8-10 | no/hold |
| walk | 6-8 | 8-12 | yes |
| run | 6-8 | 10-14 | yes |
| jump | 4-6 | 8-12 | no |
| land | 3-5 | 8-12 | no |
| emote | 4-10 | 6-10 | optional |
| melee | 5-8 | 10-15 | no |
| magic/rpg | 6-12 | 8-15 | no |
| hurt/faint | 3-8 | 8-12 | no |

## Required states for a complete Buddy

A complete game-ready Buddy variant should implement:

- `idle`
- `walk`
- `jump`
- `hurt`
- `faint`
- `happy`
- `charge`
- `melee_slash`
- `magic_cast`
- `projectile_launch`
- `victory`
- `defeat`

Other states are strongly recommended for richer UI/agent behavior.

## Melee attack rules

Melee attacks should show readable anticipation, active hit, and recovery frames:

1. Anticipation: body leans or weapon/arm pulls back.
2. Active: slash/jab/spin has a clear hit silhouette.
3. Impact: one or two readable hit spark frames.
4. Recovery: Buddy returns to baseline pose.

## RPG / za-style attack rules

RPG attacks should be composable and reusable across buddies:

- `charge` should work before any elemental or psychic effect.
- `magic_cast` should show hands/eyes/body focus.
- `projectile_launch` should include a spawn frame and release frame.
- `status_effect` should show aura, buff/debuff, stars, smoke, or symbols around Buddy.

## Sheet layout

Recommended layout is row-per-state:

```text
row 0: idle
row 1: blink
row 2: walk
row 3: run
row 4: jump_land
row 5: emotes
row 6: melee
row 7: rpg_attacks
row 8: hurt_faint
row 9: victory_defeat
```

Each row may contain unused transparent cells, but frame dimensions must stay consistent.

## Metadata requirements

Every generated sheet should include a JSON manifest matching `animation-schema.json`.

The manifest must include:

- variant ID,
- frame width/height,
- sheet path,
- animation state list,
- row/column frame locations,
- FPS,
- loop flag,
- provenance.

## Visual quality checklist

- Buddy remains recognizable in every state.
- Pixel edges stay crisp.
- No blurry interpolation.
- Palette stays coherent.
- Frame boxes line up.
- Feet/baseline do not jitter unintentionally.
- Attack frames read at small size.
- Effects do not obscure Buddy unless intentionally dramatic.
