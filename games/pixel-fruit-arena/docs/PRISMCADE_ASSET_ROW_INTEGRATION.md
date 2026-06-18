# Prismcade Asset Row Integration

Pixel Fruit Arena now has a first bridge from the shared Prismcade creator-library asset rows into its playable roster.

## Files

```txt
games/pixel-fruit-arena/data/characters/asset_row_map.json
games/pixel-fruit-arena/src/characters/prismcadeRoster.js
games/pixel-fruit-arena/tools/validate_prismcade_roster.mjs
```

## What changed

The playable roster still uses the browser-canvas runtime and the existing generated 64x64 sheets. The new part is provenance and selection wiring:

- each runtime roster entry now carries `assetRowId` and `assetRowPath`;
- `prismcadeRosterGuest()` passes the selected `prismcadeAssetRow` through to generated CPU guests;
- the roster validator now reads `data/prismcade/asset-rows/character-assets.json` and confirms every playable PFA character maps to a side-view Prismcade asset row.

## Current mappings

```txt
buddy -> buddy-main-pack
prismtek -> prismtek-fixed-hair
prismtek-jones -> normal-hair-guy
female-blue-hoodie -> female-blue-hoodie
ponytail-guy -> ponytail-guy
prismtek-pixel-god -> prismtek-fixed-hair
prismbot-pixel-god -> buddy-main-pack
```

## Why this matters

This is the first game-side integration after the creator asset picker. PFA can now prove the path:

```txt
Prismcade row registry -> PFA playable roster -> runtime sprite key -> generated 64x64 character sheets
```

## Validation

Run from the repo root:

```bash
npm --prefix games/pixel-fruit-arena run validate:prismcade-roster
```

The validator fails if a playable character is not represented in the shared Prismcade character asset rows.

## Next pass

After this merges, the next PFA work is to show the row provenance in the character-select UI and let reviewed/ready side-view rows become selectable fighters.
