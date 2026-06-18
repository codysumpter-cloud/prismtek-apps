# Prismcade Creator Asset Browser

The asset row runtime makes Prismcade asset rows loadable. The creator asset browser turns those rows into a UI-ready model.

## Runtime module

```txt
src/prismcade/assetBrowser.ts
```

It builds tabs, cards, counts, locked-state badges, and filter options from the loaded registry.

## Basic usage

```ts
import { loadPrismcadeAssetRows } from "../src/prismcade/assetRegistry";
import { buildPrismcadeAssetBrowser } from "../src/prismcade/assetBrowser";

const registry = await loadPrismcadeAssetRows({ baseUrl: "/" });
const browser = buildPrismcadeAssetBrowser(registry, {
  family: "characters",
  viewMode: "side",
  includeLocked: false,
});
```

## Browser tabs

The model exposes tabs for:

```txt
characters
vfx
worlds
items
ui
audio
```

Each tab includes total, usable, and locked counts.

## Cards

Each card includes:

```txt
id
displayName
family
sourcePath
status
licenseStatus
views
roles
tags
type
size
locked
lockReason
```

This lets the UI show usable assets as selectable and candidate/reference assets as locked or cleanup-needed.

## Filters

Supported filters:

```txt
family
viewMode
status
role
search
usableOnly
includeLocked
sortBy
```

Recommended creator defaults:

```ts
buildPrismcadeAssetBrowser(registry, {
  family: "all",
  viewMode: "all",
  includeLocked: true,
  usableOnly: false,
});
```

Recommended game picker defaults:

```ts
buildPrismcadeAssetBrowser(registry, {
  family: "characters",
  viewMode: "side",
  includeLocked: false,
  usableOnly: true,
});
```

## Next UI wiring

1. Add a creator route or panel.
2. Load the registry once.
3. Build the browser model for the selected tab/filter state.
4. Render cards with status and lock badges.
5. Let creators pick only unlocked cards.

This keeps Prismcade honest: every shiny asset can be visible, but only reviewed/template-ready assets should be selectable for export.
