# Prismcade Character Pipeline

Status: **repo-side character-pack standard and tooling**

This package turns PixelLab/Pixelorama-style character work into Prismcade-ready game character packs. PixelLab can generate consistent characters, directions, and rough animation states. Pixelorama can fix frame-level issues like clipped feet, pivot drift, stray pixels, and bad loops. Prismcade owns the final format, validation, anchors, hitboxes, GIF previews, and game packaging.

## What this package owns

```txt
packages/prismcade-character-pipeline/
  docs/                 workflow docs for PixelLab, Pixelorama, and Prismcade
  schemas/              JSON schema contracts for packs and animation states
  tools/                import, validation, normalization, and GIF/export-plan scripts
  examples/             contract-only example pack for CI-safe validation
```

## Character pack shape

```txt
character-pack/
  metadata.json
  manifest.json
  PROVENANCE.md
  source/               optional raw reviewed source notes/files
  states/               optional source-state frames
  spritesheets/         game-ready PNG animation strips
  animations/           optional per-animation metadata/notes
  gifs/                 per-animation GIF previews or export plans
  showcase.gif          optional final showcase preview
```

A source packet is not game-ready just because PixelLab can download it. Game-ready means the pack has a Prismcade manifest, reviewed provenance, a transparent background target, stable anchors, hitboxes/hurtboxes, and checked loops.

## Commands

From this package:

```bash
npm run validate
npm run gif:plan
npm run showcase:plan
```

From the repo root:

```bash
npm run prismcade:validate-character-packs
npm run prismcade:validate:all
```

## Import PixelLab-style state exports

```bash
node packages/prismcade-character-pipeline/tools/import-pixellab-states.mjs \
  /path/to/pixellab/export \
  packages/game-assets/characters/buddy \
  --character-id buddy \
  --display-name Buddy \
  --frame-width 64 \
  --frame-height 64
```

Then validate:

```bash
node packages/prismcade-character-pipeline/tools/validate-character-pack.mjs \
  packages/game-assets/characters/buddy \
  --strict-assets
```

## Import a Pixelorama-cleaned sheet

```bash
node packages/prismcade-character-pipeline/tools/import-pixelorama-sheet.mjs \
  --sheet /path/to/walk.png \
  --output packages/game-assets/characters/prismtek \
  --character-id prismtek \
  --display-name Prismtek \
  --animation walk \
  --frame-width 64 \
  --frame-height 64 \
  --fps 10
```

## Validate a pre-normalized sprite sheet

```bash
node packages/prismcade-character-pipeline/tools/normalize-sprite-sheet.mjs \
  packages/game-assets/characters/buddy/spritesheets/walk.png \
  --frame-width 64 \
  --frame-height 64
```

This does not resample or edit pixels. It proves the sheet already lines up to the target frame grid. Use Pixelorama for actual canvas/pixel cleanup.

## GIF previews

The GIF scripts are safe in two modes:

```bash
node packages/prismcade-character-pipeline/tools/export-animation-gifs.mjs packages/game-assets/characters/buddy --plan-only
node packages/prismcade-character-pipeline/tools/export-showcase-gif.mjs packages/game-assets/characters/buddy --plan-only
```

Without `--plan-only`, the animation GIF exporter attempts to use ImageMagick (`magick` or `convert`) when it exists. If the tool is not installed, it writes an export plan instead of pretending it rendered GIFs.

## Strict idle/walk checks

`idle` and `walk` get extra strict baseline and hurtbox checks because cropped feet have already bitten us.

The validator checks:

- frame size metadata;
- no absolute paths or `..` traversal;
- required animation slots;
- duplicate animation ids;
- anchor/baseline bounds;
- hitbox/hurtbox bounds;
- idle/walk foot-area coverage;
- PNG sheet dimensions when assets are present;
- provenance notes.

## How this plugs into Prismcade

- `data/integrations/pixellab-character-export-registry.json` tracks PixelLab source candidates.
- `data/prismcade/character-template-registry.json` tracks reusable Buddy/Prismtek/Female template families.
- this package validates the final character packs before they are used by Pixel Fruit Arena, Prismcade Creator, or future Prismcade games.

The games should consume only normalized packs, not raw PixelLab packets.
