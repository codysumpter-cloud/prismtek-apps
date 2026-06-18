# Prismcade Existing Asset Usage Map

Status: **repo-local asset map added**

This map exists because Prismcade already has many usable asset packs in `prismtek-apps`. The UI should not behave like there are only planned assets.

## Source shelves inspected

- `game-assets/README.md`
- `game-assets/characters/README.md`
- `games/pixel-fruit-arena/assets/uploaded/asset-manifest.json`
- `games/pixel-fruit-arena/src/assets/assetManifest.js`
- `games/prismwilds-echo-dominion/data/assets.json`

The machine-readable Prismcade-facing map now lives at:

```txt
 data/prismcade/repo-asset-packs.json
```

## Character / avatar packs

| Asset | Repo path | Prismcade use |
| --- | --- | --- |
| Normal Hair Guy | `game-assets/characters/Normal_Hair_Guy.zip` | Preferred young male avatar/NPC source template |
| Female Character Blue Hoodie | `game-assets/characters/Female_Character_Blue_Hoodie.zip` | Matching female/chibi base template |
| Buddy main source | `game-assets/characters/Buddy (2).zip` | Protected Buddy identity source/reference |
| Buddy Grok 64 | `game-assets/characters/Buddy_Grok_64.zip` | Compact 64px runtime/reference pack |
| Buddy Grok Showcase | `game-assets/characters/Buddy_Grok_Showcase.zip` | Preview/readme/visual QA material |
| Prism Dude runtime | `games/pixel-fruit-arena/assets/characters/tiny-hero/dude/idle_4.png` | Direct preview/runtime fallback |
| Prism Owlet runtime | `games/pixel-fruit-arena/assets/characters/tiny-hero/owlet/idle_4.png` | Direct preview/runtime fallback |

## Creator cosmetics / inventory assets

| Asset | Repo path | Prismcade use |
| --- | --- | --- |
| RPG Weapons Sheet | `games/pixel-fruit-arena/assets/uploaded/weapons/RPG_Weapons.png` | Weapon icons, pickups, loadout previews |
| Loose Items 7 | `games/pixel-fruit-arena/assets/uploaded/items/items_7.png` | Inventory icons, pickups, props |
| Hairstyle GIF | `games/pixel-fruit-arena/assets/uploaded/cosmetics/hair/Hairstyle.gif` | Hair animation reference; extract PNG frames before runtime |
| Clothes Pack | `games/pixel-fruit-arena/assets/uploaded/Clothes.zip` | Character-creator outfit candidates after review |

## World / UI texture candidates

| Asset | Repo path | Prismcade use |
| --- | --- | --- |
| Trees+ | `game-assets/tilesets-environment/Trees+.png` | Home art card, forest cover, Prismwilds preview |
| Surplus Trees | `game-assets/tilesets-environment/Surplus Trees.png` | Home art card, stealth cover, forest biome |
| TinyRanch Crops | `game-assets/tilesets-environment/TinyRanch_Crops.png` | Food/resource icons, cozy hub props |
| TinyRanch Animals | `game-assets/tilesets-environment/TinyRanch_Animals.png` | NPC/feeder animal previews |
| Fruit+ | `game-assets/props-items/Fruit+.png` | Fruit power icons, food/inventory preview |
| Water+ | `game-assets/props-items/Water+.png` | Resource icons, water UI, survival HUD |

## VFX assets

| Asset | Repo path | Prismcade use |
| --- | --- | --- |
| Flame Fireball | `games/pixel-fruit-arena/assets/effects/elemental-vfx/flame-fireball.png` | Ability preview, card art, combat effect |
| Hit Spark | `games/pixel-fruit-arena/assets/effects/elemental-vfx/hit-spark.png` | UI feedback, impact preview, combat effect |

## UI integration now added

`apps/prismcade-avatar/index.html` now loads:

```txt
../../data/prismcade/repo-asset-packs.json
```

The locker lets the user pick a real repo asset pack. It includes the chosen pack in the export plan as `sourceAssetPack` and directly previews PNG/GIF assets when possible.

## Remaining product work

1. Make `apps/prismcade/index.html` use the same registry for game-card art strips and background panels.
2. Promote the best loose PNGs into a dedicated `apps/prismcade/assets/` UI skin folder when licenses/provenance are clear.
3. Unpack reviewed ZIPs into normalized runtime folders instead of linking directly to source ZIPs.
4. Add `assetPackId` and `avatarSupport` fields to `data/prismcade/game-manifests.json`.
5. Replace CSS placeholder avatars with resolved runtime sprites where available.
