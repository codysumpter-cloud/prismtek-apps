# Prismwilds Runtime Assets

This folder is reserved for normalized runtime-ready sprites, tiles, icons, effects, UI, and sounds extracted from the shared `game-assets/` library.

The first MVP uses procedural pixel fallbacks so the browser game can run before archive extraction. Do not blindly dump whole packs here.

Every imported asset should track:

- pack name
- license and attribution note
- normalized frame size
- animation metadata
- runtime approval status
- visual style compatibility check

Future layout:

```text
assets/runtime/
  creatures/
  feeders/
  roamers/
  tiles/
  props/
  effects/
  ui/
```

See `data/assets.json` for the current curation map.
