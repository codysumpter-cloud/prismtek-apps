# Asset source adapter contracts

Asset source adapters keep large free/open asset sources useful without blindly mixing incompatible licenses, styles, or raw archives into shipped games.

The machine-readable source of truth is [`../../data/integrations/asset-source-adapters.json`](../../data/integrations/asset-source-adapters.json).

## Contract stance

An asset adapter is a controlled intake path. It does not mean an asset source is approved for release, and it definitely does not mean every free asset belongs inside every game.

The asset system should answer five questions before any file reaches a game folder:

1. **Where did this come from?**
2. **Who made it?**
3. **What license applies to this exact file or pack?**
4. **Does it visually fit the target game?**
5. **What changed between the raw source and the promoted game asset?**

## Current adapter contracts

| Adapter | Status | Primary use | Best first target | Guardrail |
| --- | --- | --- | --- | --- |
| Screaming Brain Studios Asset Intake | Contract-only | Textures, tiles, and pixel-art experiments. | World tiles, environment texture studies, prototype backgrounds. | Confirm pack-level license before promotion. |
| OpenGameArt Asset Intake | Contract-only | Discovery for sprites, VFX, audio, UI, and tilesets. | Ability icons, VFX references, placeholder audio. | Every asset needs exact page URL, author, license, and attribution. |
| Local Uploaded Asset Pack Intake | Contract-only | User-uploaded packs already stored in the repo. | Existing Prismtek asset archives and packs. | Unknown-origin archives and fonts must stay out of shipped paths until reviewed. |

## Candidate expansion queue

These sources are worth modeling as future adapters, but each one still needs source-specific rules before promotion is safe.

| Candidate source | Likely adapter family | Useful for | Review requirement |
| --- | --- | --- | --- |
| Kenney assets | Pack intake adapter | UI, tiles, icons, prototypes. | Per-pack license and attribution check. |
| itch.io free game assets | Marketplace intake adapter | Sprites, tiles, UI, audio, fonts. | Per-creator and per-pack license review. |
| Game-icons.net | Icon source adapter | Ability icons, status effects, UI glyphs. | License/attribution review and style pass. |
| Freesound | Audio source adapter | SFX, ambience, prototype audio. | Exact sound page, author, license, attribution. |
| ambientCG | Material source adapter | Textures/materials for 3D experiments. | Per-asset license and derivative notes. |
| Poly Haven | 3D/HDR/material source adapter | HDRIs, materials, 3D studies. | Per-asset license, file size, and target-game review. |
| Lospec palettes | Palette source adapter | Pixel-art palette direction. | Palette author/page record. |
| CraftPix freebies | Marketplace intake adapter | Prototype sprites/tiles/UI. | Exact pack license and attribution check. |
| Font sources | Font intake adapter | Pixel fonts and UI typography. | Strict font-license review before commit or release. |

## Intake vs promotion

`game-assets/intake/**` is a quarantine area, not a shipping surface. Games should not load directly from intake folders.

Use intake folders for:

- raw archives;
- unpacked source material;
- source receipts;
- screenshots/contact sheets;
- license notes;
- style-review notes.

Use game-local asset folders for:

- reviewed/promoted assets only;
- converted file formats;
- final names and expected dimensions;
- manifests the game can load;
- credits/attribution data when required.

## Promotion manifest

Promotion into a game should create or update a game-local manifest that records:

```json
{
  "assetId": "pixel-fruit-flame-vfx-001",
  "sourceAdapterId": "opengameart-assets",
  "sourceUrl": "exact asset page URL",
  "sourceAuthor": "author name",
  "license": "exact license",
  "attributionRequired": true,
  "attributionText": "required credit text",
  "rawPath": "game-assets/intake/...",
  "promotedPath": "games/pixel-fruit-arena/assets/...",
  "targetGame": "pixel-fruit-arena",
  "targetUse": "flame fruit awakened special effect",
  "derivativeNotes": "cropped to 64x64, palette reduced, timing adjusted",
  "styleReview": "approved | needs edits | blocked",
  "reviewedBy": "reviewer or automation name",
  "reviewedAt": "YYYY-MM-DD"
}
```

## Style-fit gate

Many asset packs are good in isolation but bad together. Before promotion, check:

- sprite scale and tile size;
- outline thickness;
- palette saturation and contrast;
- animation timing;
- UI readability;
- perspective and camera angle;
- whether effects match the combat readability needs;
- whether the art supports the target game fantasy.

For Pixel Fruit Arena specifically, avoid mixing chunky UI packs, top-down RPG sprites, side-view fighter sprites, and smooth particle effects without a deliberate conversion pass.

## License/provenance gate

Every promoted asset needs enough evidence that a future release can be audited.

Minimum required provenance:

- source adapter id;
- exact source URL or upload source;
- original file or archive name;
- original author when known;
- license;
- attribution requirement;
- commercial-use status when the target release is public;
- derivative edit notes;
- destination path.

If any of those fields are unknown, the asset can remain in intake but should not be promoted into a shipped game path.

## Raw archive policy

Raw archives can be stored only when they are useful as source material and have a receipt. They should not be game runtime dependencies.

Do not ship:

- `.zip`, `.rar`, `.7z`, or `.aseprite` files directly from game runtime paths unless the game explicitly consumes them and the license is reviewed;
- unknown-origin font files;
- mixed-style sprites directly in a playable build;
- generated sprite sheets without a receipt.

## Promotion stages

| Stage | Meaning | Allowed path |
| --- | --- | --- |
| `raw-intake` | Source material exists but has not been reviewed. | `game-assets/intake/**` only. |
| `metadata-recorded` | Provenance and license fields exist. | Intake and docs receipts. |
| `style-reviewed` | Art direction fit has been checked. | Intake and candidate folders. |
| `converted` | File has been resized, renamed, optimized, or animated. | Candidate/promoted staging. |
| `promoted` | Asset can be loaded by a game. | Game-local asset folder plus manifest. |
| `shippable` | Release use is approved. | Game build/release artifacts. |

## Game-specific asset gates

| Game/surface | Extra gate |
| --- | --- |
| Pixel Fruit Arena | 64x64 character scale, readable combat silhouettes, directional move clarity, awakened-state VFX readability. |
| TamerNet | Creature readability, taming/battle UI clarity, overworld tile consistency. |
| Spin Street Showdown | Stadium/top readability, cyber UI restraint, Slayblade-inspired physics/menu clarity without copying. |
| Wildlands: Critter Clash | Match existing world/tile style and itch release structure. |
| Shared arcade games | Small filesize, offline loading, simple attribution path. |

## Next implementation slice

The safest first asset plugin should not promote files yet. It should:

1. Read `data/integrations/asset-source-adapters.json`.
2. Validate adapter structure.
3. Scan `game-assets/intake/**` for missing receipts.
4. Emit a report.
5. Fail only when a shipped game path references an unreviewed intake asset.

That gives the repo real protection without blocking raw asset gathering.
