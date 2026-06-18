# Using Prismcade Asset Rows

The row registries under `data/prismcade/asset-rows/` are now loadable from TypeScript through:

```txt
src/prismcade/assetRegistry.ts
```

This is the bridge between the asset warehouse metadata and the Prismcade creator UI.

## Runtime load

```ts
import {
  loadPrismcadeAssetRows,
  getAssetsByFamily,
  getAssetsByViewMode,
  getUsableCreatorAssets,
} from "../src/prismcade/assetRegistry";

const registry = await loadPrismcadeAssetRows({ baseUrl: "/" });
const characters = getAssetsByFamily(registry, "characters");
const lowTopDown = getAssetsByViewMode(registry, "low_top_down");
const usable = getUsableCreatorAssets(registry);
```

## Creator browser flow

The Prismcade creator should use the loader to populate tabs:

```txt
characters
vfx
worlds
items
ui
audio
```

Each row should show:

```txt
name
family
source path
view support
status
license status
```

Rows with `reference_only` or `unknown_do_not_ship` should remain visible for planning, but locked from direct game export.

## Game integration flow

Games should ask for candidates by view mode and role instead of hardcoded asset paths.

```ts
const sideCandidates = getCandidateAssetsForGame(registry, {
  family: "characters",
  viewMode: "side",
});
```

That gives Pixel Fruit Arena a path to find side-view characters, while the Prismcade hub can query low-top-down characters and worlds.

## Validation

Run the shape validator directly:

```bash
node tools/prismcade/check-asset-rows.mjs
```

The validator checks that all required row files exist, each file has rows, each row has an id/name/source path, and blocked/reference rows are not marked as game-ready.

## Next wiring target

1. Prismcade creator browser loads asset rows.
2. Pixel Fruit Arena queries side-view character candidates.
3. Prismcade hub queries low-top-down character/world candidates.
4. Effect rows become normalized effect templates.
