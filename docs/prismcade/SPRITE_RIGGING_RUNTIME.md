# Prismcade Sprite Rigging Runtime

Status: foundation design.

Prismcade sprite rigging should be template rigging, not freeform per-character animation.

The engine should treat each compatible character as a set of layers, frames, anchors, slots, and sockets bound to a named template. If the character matches the template contract, the game can reuse the same animation logic across many characters and sizes.

## Core idea

A rig is a reusable coordinate system.

A character is compatible when it provides art that fits that rig.

A game plays animation slots from the rig, not hard-coded per-character frame logic.

## Runtime objects

1. Rig template
2. Character variant
3. Animation clip map
4. Layer stack
5. Anchor map
6. Hitbox and hurtbox map
7. Socket map
8. Size adapter

## Rig template fields

Each rig template should define:

- template id
- view family
- base frame size
- allowed frame sizes
- normalized origin
- normalized floor point
- normalized anchors
- layer order
- animation slots
- collision boxes
- sockets for weapons, tools, effects, and held items
- compatibility level rules

## Character variant fields

Each character should define:

- character id
- rig template id
- actual frame size
- sprite sheet paths
- layer paths when layered
- palette slots
- animation slot overrides when needed
- anchor corrections when needed
- fallback portrait or mini avatar

## Multiple sprite sizes

Use normalized coordinates for anchors and boxes.

Example:

- base rig is 64x64
- head anchor is 0.50, 0.28
- floor point is 0.50, 0.875

At runtime:

- 32x32 character head anchor becomes 16, 9
- 64x64 character head anchor becomes 32, 18
- 96x96 character head anchor becomes 48, 27

This lets the same rig support several pixel sizes without hand-authoring every coordinate again.

## Size strategy

Do not allow infinite arbitrary scaling. Use canonical sizes first:

- 32x32 mini
- 48x48 compact
- 64x64 standard chibi
- 96x96 fighter
- 128x128 boss or showcase

A sprite can be accepted only if it declares its size and passes anchor and bounds checks.

## Compatibility levels

- exact_template: same size, anchors, slots, and layer rules
- scaled_template: same proportions at another approved size
- compatible_template: same anchors but needs layer baking or palette mapping
- adapted_template: same view family but needs a converter
- incompatible_template: custom character, not portable

## Rendering rule

The renderer draws layers in template order, anchored to the same origin.

A clothing layer should never define new motion. It follows the template frame, anchor, and slot timing. Hair and accessories can define small per-slot offsets, but not a new body rig.

## Game logic rule

Game systems should read:

- rig id
- animation slot
- origin
- hurtbox
- hitbox
- sockets

Game systems should not care which character sheet is currently plugged in as long as it passes the template checks.

## Validation rule

The creator and asset pipeline should check:

- frame size is approved
- transparent background exists
- required animation slots exist
- required anchors exist
- layers match template order
- no layer exceeds safe bounds unless flagged as accessory or effect
- hitboxes fit expected slot timing
- fallback avatar exists

## Pipeline

1. Intake animation source pack.
2. Record license and source metadata.
3. Slice frames into animation slots.
4. Assign or create rig template.
5. Normalize anchors and boxes.
6. Validate frame size and layers.
7. Bake a preview sheet.
8. Test in one quick-play game.
9. Promote to platform template.

## First implementation target

Start with `compact-chibi-64-side`.

Then add:

- compact-chibi-64-top-down
- compact-chibi-64-low-top-down
- compact-chibi-64-isometric
- fighter-96-side
- creature-64-top-down
