# Prismcade Reusable Animation Template

Status: foundation contract.

Prismcade characters need a reusable animation template so a game does not need custom animation work for every new outfit or avatar.

The rule is simple: if a character matches the template dimensions, anchors, view family, and layer rules, the existing animation set should work in every compatible game.

## Platform rule

Animate the template once. Reuse it many times.

A created character, outfit, hairstyle, or accessory must conform to the template instead of inventing a new body layout per game.

## Canonical sprite sizes

Prismcade should allow template rigs up to 256x256, but smaller sizes should remain the default for quick-play games.

- 32x32 mini
- 48x48 compact
- 64x64 standard chibi
- 96x96 fighter
- 128x128 boss or showcase
- 192x192 premium showcase
- 256x256 maximum avatar, boss, cutscene, or high-detail fighter frame

A game should declare its max supported frame size. If a player avatar is larger than a game supports, the game should use a smaller baked sheet, portrait, mini avatar, palette identity, or badge fallback.

## Template requirements

Each animation template should define:

- view family: side, top_down, low_top_down, or isometric
- frame width and frame height
- allowed frame sizes, capped at 256x256
- origin point
- floor point
- head anchor
- hand anchors when needed
- body bounds
- safe clothing bounds
- safe hair bounds
- animation slot names
- frame timing
- layer order
- fallback pose

## Required side-view slots

- idle
- walk
- run
- jump
- fall
- land
- hurt
- defeat
- victory
- basic
- strong
- popup
- skill
- big_skill

## Required top-down slots

- idle_south
- walk_south
- walk_east
- walk_north
- walk_west
- interact
- hurt
- victory

## Layer order

1. shadow
2. base body
3. bottom clothing
4. shoes
5. top clothing
6. hair back
7. face
8. hair front
9. accessory
10. effect overlay

## Compatibility levels

- exact_template: same frame size and anchors; animations can be reused directly
- scaled_template: same proportions at another approved size
- compatible_template: same anchors but needs palette or layer baking
- adapted_template: same view family but needs conversion
- incompatible_template: custom animation required

## Game requirement

Every Prismcade game should declare the animation templates it accepts and its maximum supported frame size. A game should prefer template IDs over one-off per-character animation logic.

## Creator requirement

The creator must validate new characters against the selected template before letting them be used as portable avatars.
