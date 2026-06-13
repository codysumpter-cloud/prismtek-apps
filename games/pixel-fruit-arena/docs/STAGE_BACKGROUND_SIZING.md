# Stage Background Sizing

Pixel Fruit Arena renders at a fixed internal arena size of `960 x 540`.

Stage images should not be repeated or stretched directly. The renderer now uses a fitted-image helper for stage textures:

- `cover` fills the whole arena and center-crops overflow.
- `contain` preserves the full image and letterboxes inside the arena.

Stage texture metadata can set:

```json
{
  "stageTexture": {
    "src": "assets/stages/example/background.png",
    "fit": "cover",
    "alpha": 0.22
  }
}
```

Default behavior is `cover`, which avoids repeated tiles and incorrect source image sizing.

Regression guard:

```bash
npm test
```

The test suite checks that stage background textures use `drawFittedStageImage` and are not drawn as repeated texture patterns.
