# Prismcade World / Item / Font Asset Intake

Status: **mapped, not yet physically relocated**

Source commit:

```txt
6e7892e29113c06cbdc77a952292f292ed6d189e
```

This commit added a second direct-upload batch after the UI/font pack upload. The files are currently at the repository root and should be relocated into `game-assets/` by category.

The machine-readable map lives at:

```txt
data/prismcade/world-item-asset-intake.json
```

## Fonts

| Current root file | Intended path | Prismcade use |
| --- | --- | --- |
| `monogram-bitmap.json` | `game-assets/fonts/monogram/monogram-bitmap.json` | Bitmap font map |
| `monogram-bitmap.png` | `game-assets/fonts/monogram/monogram-bitmap.png` | Bitmap font sheet |
| `monogram.ttf` | `game-assets/fonts/monogram/monogram.ttf` | UI / dialog / HUD font |
| `monogram-extended-italic.ttf` | `game-assets/fonts/monogram/monogram-extended-italic.ttf` | UI font variant |
| `monogram.p8` | `game-assets/fonts/monogram/monogram.p8` | PICO-8/font source reference |
| `monogram.zip` | `game-assets/fonts/monogram/monogram.zip` | Source archive |

## UI

| Current root file | Intended path | Prismcade use |
| --- | --- | --- |
| `Pixel UI pack 3.zip` | `game-assets/ui/source-packs/Pixel UI pack 3.zip` | Pixel menus, panels, buttons |

## Items / props / inventory

| Current root file | Intended path | Prismcade use |
| --- | --- | --- |
| `16x16 RPG Item Pack.rar` | `game-assets/props-items/16x16 RPG Item Pack.rar` | Inventory and pickup icons |
| `16x16 RPG Item Pack.zip` | `game-assets/props-items/16x16 RPG Item Pack.zip` | Inventory and pickup icons |
| `Clothes.zip` | `game-assets/props-items/Clothes.zip` | Avatar clothing / cosmetics |
| `Clothes_snacks Asset Pack.zip` | `game-assets/props-items/Clothes_snacks Asset Pack.zip` | Clothes, snacks, shop items |
| `Food.png` | `game-assets/props-items/Food.png` | Food / healing icons |
| `FreePixelFood.zip` | `game-assets/props-items/FreePixelFood.zip` | Food / healing / survival items |
| `RPG_Weapons.png` | `game-assets/props-items/RPG_Weapons.png` | Weapon icons / loadout UI |
| `items_7.png` | `game-assets/props-items/items_7.png` | Loose inventory and pickup icons |

## Characters / NPCs / mobs

| Current root file | Intended path | Prismcade use |
| --- | --- | --- |
| `Blue Witch.zip` | `game-assets/characters/Blue Witch.zip` | Caster NPC / enemy / avatar reference |
| `Elementals_water_priestess_FREE_v1.1.zip` | `game-assets/characters/Elementals_water_priestess_FREE_v1.1.zip` | Water-element combat character reference |
| `elementals_wind_hashashin_FREE_v1.1.zip` | `game-assets/characters/elementals_wind_hashashin_FREE_v1.1.zip` | Wind/assassin combat character reference |
| `Lively_NPCs_v3.1.zip` | `game-assets/characters/Lively_NPCs_v3.1.zip` | Town NPCs / social hub population |
| `Monster Pack 1.7z` | `game-assets/characters/Monster Pack 1.7z` | Enemy mobs / RPG encounters |
| `Pixel Adventure 1.zip` | `game-assets/characters/Pixel Adventure 1.zip` | Platformer starter/reference assets |

## World / tiles / water

| Current root file | Intended path | Prismcade use |
| --- | --- | --- |
| `SBS - Tiny Texture Pack 2 - 128x128.rar` | `game-assets/tilesets-environment/SBS - Tiny Texture Pack 2 - 128x128.rar` | Tiny texture/world material pack |
| `water-example.tmx` | `game-assets/tilesets-environment/water-example.tmx` | Tiled water map reference |
| `watertiles-auto.tsx` | `game-assets/tilesets-environment/watertiles-auto.tsx` | Tiled/autotile source reference |

## VFX

| Current root file | Intended path | Prismcade use |
| --- | --- | --- |
| `Super Pixel Effects Gigapack (Free Version) v2.4.0.zip` | `game-assets/vfx/Super Pixel Effects Gigapack (Free Version) v2.4.0.zip` | Hit effects, attack effects, abilities, game-card VFX |

## Misc / deduplication

| Current root file | Intended path | Prismcade use |
| --- | --- | --- |
| `32rogues-0.4.0.zip` | `game-assets/misc/32rogues-0.4.0.zip` | Roguelike icons/tiles/prototypes |
| `32rogues-0.5.0.zip` | `game-assets/misc/32rogues-0.5.0.zip` | Roguelike icons/tiles/prototypes |

These two may already exist under `game-assets/misc/`. Check for duplicates before moving.

## Cleanup plan

Physically relocate the root files with `git mv`, then update `data/prismcade/world-item-asset-intake.json` so each `currentPath` equals its final `targetPath`.

Do not wire these directly into Prismcade runtime UI until license/provenance is captured and archive contents are inspected.
