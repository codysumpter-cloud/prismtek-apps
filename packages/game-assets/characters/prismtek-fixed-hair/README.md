# Prismtek Fixed Hair — Game-Ready Prismcade Pack

Status: generated starter pack, game-usable, cleanup-friendly.

This package describes the **Prismtek Fixed Hair** side-view animation pack that was generated, sliced, and normalized for Prismcade games.

## What this pack is

This character pack is the **portable side-view avatar implementation** for Prismtek Fixed Hair.

It is intended to be stored at:

```txt
packages/game-assets/characters/prismtek-fixed-hair/
```

The generated binary assets should live under that folder in this shape:

```txt
packages/game-assets/characters/prismtek-fixed-hair/
  manifest.prismcade-character.json
  source-sheets/
  runtime/
    32/
    48/
    64/
    96/
    128/
    192/
    256/
```

## Default runtime target

- Default runtime size: `64x64`
- Allowed sizes: `32, 48, 64, 96, 128, 192, 256`

Games should use the `64x64` runtime by default unless they explicitly opt into a higher sprite tier.

## Included animation slots

- `idle`
- `walk`
- `run`
- `jump`
- `fall`
- `land`
- `climb`
- `crouch_idle`
- `crouch_walk`
- `wall_slide`
- `wall_land`
- `ledge_climb`
- `roll`
- `hurt`
- `death`
- `punch`
- `basic`
- `sword_idle`
- `sword_run`
- `sword_stab`
- `victory`
- `interact`

## How it is reusable

This pack is reusable because it follows Prismcade conventions:

1. **Canonical slot names**
   - Games ask for `walk`, `jump`, `hurt`, `victory`, and so on.
   - The character pack supplies those slots in a predictable format.

2. **Multiple normalized sizes**
   - The same character is available in all approved Prismcade sizes.
   - Tiny games can use `32` or `48`.
   - Standard portable avatar games use `64`.
   - Higher-detail fighters or showcase uses can opt into `96+`.

3. **Per-slot strips + atlas manifests**
   - A game can use per-slot strips for simplicity.
   - A game can use the atlas manifest for runtime loading.

4. **Portable avatar behavior**
   - The same character identity can appear across multiple Prismcade games.
   - Game logic uses slots and manifests, not one-off hardcoded character rules.

## How Prismcade games should use it

### Platformer / fighter style games

Use the pack directly.

Recommended runtime source:

```txt
runtime/64/manifest.json
runtime/64/atlas/atlas.png
```

Example slot usage:

- `idle` when standing
- `walk` / `run` during movement
- `jump` / `fall` / `land` for air state
- `hurt` and `death` for reaction state
- `punch`, `basic`, `sword_*` for combat
- `victory` at round/game end

### Games with smaller avatar needs

Use:

```txt
runtime/32/
runtime/48/
```

for low-cost mobile/arcade rendering.

### Games that do not use side-view gameplay

This pack still remains useful as:

- profile / catalog avatar
- lobby avatar
- portrait identity
- badge/cosmetic fallback
- basis for later top-down/isometric variants

## Props and cleanup

Some slots contain environment or prop content and are marked with:

```json
"containsProp": true
```

Examples:

- `climb`
- `wall_slide`
- `ledge_climb`
- `death`
- `sword_*`
- `interact`

These are usable now, but later should be split into:

- character-only layer
- environment prop layer
- effect layer

## Source and pipeline

This pack comes from the generated Prismtek sheets and the repeatable slicing pipeline.

Relevant repo pieces:

- `docs/prismcade/GAME_READY_SPRITE_SHEET_PIPELINE.md`
- `data/prismcade/sprite-sheet-jobs/prismtek-fixed-hair-game-ready.json`
- `tools/prismcade/slice_generated_sprite_sheet.py`

Repeatable command:

```bash
python tools/prismcade/slice_generated_sprite_sheet.py \
  --job data/prismcade/sprite-sheet-jobs/prismtek-fixed-hair-game-ready.json \
  --zip
```

## Promotion rule

This pack is good enough for integration and playtesting now.

Before calling it final production art, do a cleanup pass on the weakest or prop-heavy slots first:

- `ledge_climb`
- `roll`
- `death`
- `sword_run`
- `sword_stab`
- `interact`
