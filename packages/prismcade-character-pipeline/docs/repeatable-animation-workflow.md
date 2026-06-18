# Repeatable animation workflow

This is the repeatable path for Buddy, Prismtek, Female Blue Hoodie, and future Prismcade characters.

## Pipeline

```txt
PixelLab generation
  -> Pixelorama cleanup
  -> Prismcade import
  -> Prismcade validation
  -> GIF/showcase preview
  -> game-local roster integration
```

## Step 1: generate or refresh source states

Use PixelLab to generate the character identity and animation states. Keep prompts and source ids in provenance notes. Do not paste private bearer tokens or API keys into repo files.

## Step 2: clean frames

Use Pixelorama to fix feet, baseline, hair drift, palette drift, and rough silhouettes. Export PNG strips per state.

## Step 3: import

Use either:

```bash
node packages/prismcade-character-pipeline/tools/import-pixellab-states.mjs <input-dir> <output-pack-dir>
```

or:

```bash
node packages/prismcade-character-pipeline/tools/import-pixelorama-sheet.mjs --sheet <sheet.png> --output <output-pack-dir> --animation walk
```

## Step 4: validate

```bash
node packages/prismcade-character-pipeline/tools/validate-character-pack.mjs <output-pack-dir> --strict-assets
```

## Step 5: preview

```bash
node packages/prismcade-character-pipeline/tools/export-animation-gifs.mjs <output-pack-dir> --plan-only
node packages/prismcade-character-pipeline/tools/export-showcase-gif.mjs <output-pack-dir> --plan-only
```

If ImageMagick is installed, remove `--plan-only` for the per-animation GIF exporter.

## Step 6: wire into games

Games should consume the normalized character pack or a game-local copy derived from it. Pixel Fruit Arena should only use packs that pass validation and keep stable anchors/hitboxes.

## Done means

- assets are Prismtek-owned or policy-approved;
- `metadata.json` and `manifest.json` pass validation;
- PNG strips match frame grid;
- idle/walk loops show no foot clipping;
- GIF preview exists or an export plan is committed;
- provenance is updated;
- game roster integration passes its own validator.
