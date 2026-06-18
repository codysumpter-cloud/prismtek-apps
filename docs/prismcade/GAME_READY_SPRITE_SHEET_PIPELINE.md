# Prismcade Game-Ready Sprite Sheet Pipeline

Status: foundation workflow.

Generated sprite sheets are not game-ready until they are sliced, normalized, made transparent, and paired with manifests.

## Goal

Turn approved generated sprite-sheet images into runtime assets that Prismcade games can load immediately.

## Required outputs

Each generated character pack should output:

```txt
packages/game-assets/characters/{characterId}/
  manifest.prismcade-character.json
  source-sheets/
  runtime/
    64/
      frames/{slot}/*.png
      strips/{slot}_64.png
      gifs/{slot}_64.gif
      atlas/atlas.png
      manifest.json
```

The same folder shape can also include 32, 48, 96, 128, 192, and 256 frame sizes when the source quality supports it.

## Pipeline

1. Save the approved generated sheets.
2. Remove generated checkerboard or solid backgrounds.
3. Use row config to identify animation slots and expected frame counts.
4. Slice each row into frame crops.
5. Remove labels and orphan fragments.
6. Normalize each frame into square Prismcade cells.
7. Export individual frame PNGs.
8. Export per-slot horizontal strips.
9. Export GIF previews.
10. Export atlas image and JSON manifest.
11. Mark frames with embedded props/effects using `containsProp`.
12. Review the 64x64 contact sheet before promotion.

## Repeatability contract

Every generated sheet intake should include a row config:

```json
{
  "sheet": "locomotion",
  "slot": "walk",
  "y0": 180,
  "y1": 360,
  "frames": 6,
  "gap": 35,
  "duration": 110,
  "containsProp": false,
  "x_min": 150
}
```

The config makes slicing repeatable even when generated sheets use labels or irregular spacing.

## Runtime rule

Games should prefer `runtime/64/atlas/atlas.png` and `runtime/64/manifest.json` for first integration. Use larger sizes only when the game declares a higher sprite tier.

## Quality rule

If slicing produces label fragments, cut-off frames, unstable floor alignment, or prop-heavy character rows, the pack remains `draft` until fixed. Do not promote a generated sheet directly into game runtime without this slicing and QA pass.
