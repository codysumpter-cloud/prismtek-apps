# PixelLab character states workflow

PixelLab is the generation and consistency step. Use it to create the base character, directional views, and rough animation states. Do not treat a PixelLab export as final game art until the Prismcade validator and a human polish pass say it is ready.

## Use PixelLab for

- base character creation;
- consistent visual identity across states;
- 4-direction or 8-direction source sets;
- animation-state generation;
- init-image/inpaint iteration;
- re-running failed or weak states.

## Prismcade rules

1. Preserve the source direction mode. A 4-direction export remains 4-dir unless a real 8-dir derivative is generated.
2. Keep source identity locked: head shape, hair, outfit palette, proportions, and silhouette should not drift between states.
3. Export or normalize toward 64x64 transparent frames unless a game explicitly approves another size.
4. Never commit credentials, bearer tokens, or private PixelLab API URLs with secrets.
5. Do not call a source game-ready until it has a character manifest, provenance, animation metadata, and checked loops.

## Import checklist

```bash
node packages/prismcade-character-pipeline/tools/import-pixellab-states.mjs \
  ./downloads/buddy-pixellab \
  packages/game-assets/characters/buddy \
  --character-id buddy \
  --display-name Buddy \
  --frame-width 64 \
  --frame-height 64

node packages/prismcade-character-pipeline/tools/validate-character-pack.mjs \
  packages/game-assets/characters/buddy \
  --strict-assets
```

## What usually needs cleanup

- feet clipped by the bottom frame edge;
- idle/walk baseline drift;
- inconsistent head height;
- hair changing between frames;
- hands popping in/out;
- anti-aliased or blurred resizes;
- inconsistent shadow pixels;
- animation ids that do not map to Prismcade canonical slots.
