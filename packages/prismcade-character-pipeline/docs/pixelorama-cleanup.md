# Pixelorama cleanup workflow

Pixelorama is the manual editor/fixer layer. Use it after generation and before committing a game-ready pack.

## Cleanup targets

- transparent background only;
- hard-edged pixels, no blur or anti-aliasing;
- stable baseline across every frame;
- no cropped feet, head, or hands;
- readable 64x64 silhouette;
- consistent palette and outline;
- clean loop timing for idle/walk/run;
- frame tags that map to Prismcade animation ids.

## Practical pass order

1. Open the PixelLab output in Pixelorama.
2. Set or verify the 64x64 frame grid.
3. Use onion skinning to check foot position and head height.
4. Fix outlier frames first: cropped feet, stray pixels, jittery hair, and broken hands.
5. Tag frames by animation state.
6. Export PNG strips and GIF previews.
7. Import or validate the edited sheets in this package.

## Validation after cleanup

```bash
node packages/prismcade-character-pipeline/tools/normalize-sprite-sheet.mjs ./walk.png --frame-width 64 --frame-height 64
node packages/prismcade-character-pipeline/tools/import-pixelorama-sheet.mjs \
  --sheet ./walk.png \
  --output packages/game-assets/characters/prismtek \
  --character-id prismtek \
  --display-name Prismtek \
  --animation walk
node packages/prismcade-character-pipeline/tools/validate-character-pack.mjs packages/game-assets/characters/prismtek --strict-assets
```

## Human review rule

If the validator passes but the animation looks bad, it is still not done. The validator catches structure. Pixelorama review catches taste, motion, and game feel.
