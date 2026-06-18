# Prismcade Character Pipeline

Status: repo-side character-pack standard and tooling.

This package provides the Prismcade-owned bridge between generated/editable pixel characters and game-ready character packs.

## Purpose

PixelLab is the generation step. Pixelorama is the cleanup step. Prismcade owns the final validated package format.

## Commands

From this package:

```bash
npm run validate
npm run gif:plan
npm run showcase:plan
```

From the repo root:

```bash
npm --prefix packages/prismcade-character-pipeline run validate
```

## Pack shape

```txt
metadata.json
manifest.json
PROVENANCE.md
spritesheets/*.png
gifs/
showcase.gif
```

## Core tools

```bash
node packages/prismcade-character-pipeline/tools/import-pixellab-states.mjs <input-dir> <output-pack-dir>
node packages/prismcade-character-pipeline/tools/import-pixelorama-sheet.mjs --sheet <sheet.png> --output <output-pack-dir> --animation walk
node packages/prismcade-character-pipeline/tools/validate-character-pack.mjs <pack-dir> --strict-assets
node packages/prismcade-character-pipeline/tools/normalize-sprite-sheet.mjs <sheet.png> --frame-width 64 --frame-height 64
node packages/prismcade-character-pipeline/tools/export-animation-gifs.mjs <pack-dir> --plan-only
node packages/prismcade-character-pipeline/tools/export-showcase-gif.mjs <pack-dir> --plan-only
```

## Validator focus

The validator checks frame metadata, required slots, anchors, baselines, hitboxes, hurtboxes, provenance, PNG dimensions when assets exist, and extra idle/walk foot-coverage rules.

Games should consume normalized packs only, not raw PixelLab packets.
