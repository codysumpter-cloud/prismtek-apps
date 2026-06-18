# Prismcade Top-Down Character Animation Guide

Reference: SLYNYRD Pixelblog 55, "Top Down Character Animation" by Raymond Schlitter, March 31, 2025.

This guide turns the SLYNYRD top-down animation breakdown into Prismcade rules for `top_down` and `low_top_down` character variants.

## Projection target

Prismcade should treat `top_down` and `low_top_down` as a 3/4 top-down projection, not a straight overhead camera.

That means characters need to show:

- a readable front or back face;
- the top of the head/hair;
- enough torso/limb volume to communicate direction;
- clear feet/ground contact;
- stable identity across rotations.

## Direction tiers

Prismcade should support two tiers.

### Economy tier: 4-facing / 8-movement

Use this when a small game needs cheap production cost.

Characters face:

- south;
- north;
- east;
- west.

The game may still allow diagonal movement, but the character orientation snaps to one of the four facings. This is acceptable for hubs, cozy games, simple RPGs, and early social spaces.

### Full tier: 8-facing / 8-action

Use this when combat, aiming, attacks, dodging, or precise facing matter.

Characters need:

- south;
- south-east;
- east;
- north-east;
- north;
- north-west;
- west;
- south-west.

For symmetrical characters, east/west and diagonal pairs can be mirrored. For asymmetrical equipment, hair, shields, weapons, or backpacks, unique frames may be required for all eight directions.

## Recommended base size

The SLYNYRD example uses a compact 26x32px neutral front-facing figure that roughly conforms to two stacked 16x16 tiles.

For Prismcade, the default low-top-down runtime should remain `64x64`, but the actual painted character can occupy a smaller internal footprint inside the frame.

Recommended default footprint:

```txt
internal body footprint: about 26x32px to 36x48px
runtime cell: 64x64
anchor / baseline: stable feet position inside the 64x64 cell
```

This keeps the character compatible with tile-grid worlds while preserving room for hair, weapons, shadows, emotes, and effects.

## Required rotation QA

Before a top-down or low-top-down character is promoted, assemble the standing orientations into a rotation preview.

The review should check:

- appendage thickness stays consistent;
- head size stays consistent;
- torso volume does not pop;
- hair silhouette stays recognizable;
- equipment does not teleport;
- feet remain grounded;
- one-pixel changes do not create visible jank.

## Idle animation rule

Idle should be subtle. Avoid constant robotic motion.

Preferred idle behavior:

- hold the extremes slightly longer than the in-between frames;
- keep the feet/baseline stable;
- use small head/hair/shoulder motion;
- do not let highlights jitter randomly.

## Run/walk cycle rule

A six-frame run/walk cycle is the Prismcade default for full top-down variants.

Review points:

- head bob is the main expression of motion;
- shoulder pivots need to track logically;
- arm and leg swing should match the same cycle across all directions;
- diagonal frames should be compared in a circle, not only in a flat row;
- up/down motion should bounce naturally instead of using a constant sine-wave feel.

## Character design rule

Static design and animated design are different jobs.

Keep top-down avatar designs:

- simple enough to read while moving;
- low-noise in the torso/feet area;
- consistent in value balance;
- clear around hands, forearms, boots, hair, and equipment;
- layer-friendly for future clothing and gear systems.

Prismcade should favor layered construction where possible:

```txt
base body
hair
face
shirt/jacket
pants
boots
weapon
shield/backpack
emote/effect
```

This supports future outfits, hairstyles, gear, and creator-made cosmetics.

## Required slots by tier

### Economy low-top-down

```txt
idle_south
walk_south
idle_north
walk_north
idle_side
walk_side
interact
emote
```

### Full top-down / action

```txt
idle_south
walk_south
run_south
idle_south_east
walk_south_east
run_south_east
idle_east
walk_east
run_east
idle_north_east
walk_north_east
run_north_east
idle_north
walk_north
run_north
idle_north_west
walk_north_west
run_north_west
idle_west
walk_west
run_west
idle_south_west
walk_south_west
run_south_west
attack_directional
block_directional
dodge_directional
hurt
emote
```

## Prismcade promotion checklist

A top-down character variant is not game-ready until:

- each required facing exists;
- each required movement loop exists;
- the rotation preview is stable;
- walk/run loops share consistent timing across directions;
- mirrored directions are intentional;
- asymmetrical designs have unique frames or documented mirrored-equipment behavior;
- the pack declares `viewVariants.low_top_down` or `viewVariants.top_down`;
- the view-mode validator passes.

## Platform consequence

This source confirms the strategy behind PR #187: Prismcade needs camera/view contracts first, then character variants.

The loader should know whether a game needs `side`, `top_down`, `low_top_down`, `isometric`, or only `profile_lobby` before it chooses a runtime.
