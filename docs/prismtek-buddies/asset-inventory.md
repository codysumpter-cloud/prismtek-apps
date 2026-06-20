# Prismtek Buddies — Asset Inventory

Provenance and ship-safety inventory for art/asset packs considered for the
`apps/prismtek-buddies-native/` SwiftUI app.

## Current bundled assets

### Bitbud

| File set | Source | Safe to ship | Notes |
|---|---|---|---|
| `Shared/Resources/BitbudFrames/*.png` | Cody/Prismtek Bitbud pet atlas | yes | Extracted PNG frames only. Source WebP atlas is not committed and must not be mutated. |
| `Shared/Resources/bitbud-pet.json` | Cody/Prismtek pet manifest | yes | Provenance copy for the integrated pet. |

### Room props

| File | Dims (px) | Source | Safe to ship | Notes |
|---|---:|---|---|---|
| `chair.png` | 13x19 | slice of owner-attested `interior free` pack | yes | curated prop only; no raw pack committed |
| `couch.png` | 30x37 | slice of owner-attested `interior free` pack | yes | curated prop only |
| `picture.png` | 13x16 | slice of owner-attested `interior free` pack | yes | curated prop only |
| `plant.png` | 14x32 | slice of owner-attested `interior free` pack | yes | curated prop only |
| `shelf.png` | 16x15 | slice of owner-attested `interior free` pack | yes | curated prop only |
| `window.png` | 48x64 | slice of owner-attested `interior free` pack | yes | curated prop only |
| `computer.png` | 22x22 | original Prismtek pixel prop | yes | own IP |
| `desk.png` | 40x24 | original Prismtek pixel prop | yes | own IP |
| `music_player.png` | 24x16 | original Prismtek pixel prop | yes | own IP |
| `rug.png` | 48x20 | original Prismtek pixel prop | yes | own IP |

### Room tiles

| File | Dims (px) | Source | Safe to ship | Notes |
|---|---:|---|---|---|
| `RoomArt/RoomTiles/wall_tile.png` | 16x16 | original Prismtek pixel tile | yes | tiled wall texture; replaces flat SwiftUI wall fill |
| `RoomArt/RoomTiles/floor_tile.png` | 16x16 | original Prismtek pixel tile | yes | tiled wood floor texture; replaces flat SwiftUI floor fill |
| `RoomArt/RoomTiles/baseboard.png` | 16x4 | original Prismtek pixel tile | yes | repeated wall/floor separation strip |

### Selectable Buddy variants

| File | Dims (px) | Source | Safe to ship | Notes |
|---|---:|---|---|---|
| `Buddies/buddy_classic.png` | 64x64 | Cody/Prismtek Buddy desktop art (`Buddy-64.png`) | yes | static selectable Buddy |
| `Buddies/buddy_green.png` | 64x64 | Cody/Prismtek Buddy desktop art (`Buddy-variant-green-64.png`) | yes | static selectable Buddy |
| `Buddies/buddy_pink.png` | 64x64 | Cody/Prismtek Buddy desktop art (`Buddy-variant-pink-64.png`) | yes | static selectable Buddy |
| `Buddies/buddy_purple.png` | 64x64 | Cody/Prismtek-owned local variant | yes | static selectable Buddy |

Dims were checked with `file` and `sips` on 2026-06-20. Room tiles are tiny PNGs
with hard pixel edges; the app renders them with `.interpolation(.none)`.

## Local packs searched/considered

A local asset search was run across Downloads, Documents, Desktop, Documents/Mac,
and this repo for image and Aseprite assets. Relevant finds included the desktop
Buddy PNGs, `dinoCharactersVersion1`, Buck Borris Aseprite files, multiple
Sunnyside/Tiny RPG/Jungle packs, and existing Prismtek game assets. This pass did
not import those additional raw packs because the app already had enough curated
room props and original Prismtek tiles.

## Third-party packs not bundled this pass

| Name | Path | Status | Notes |
|---|---|---|---|
| `interior free` | `~/Downloads/interior free` | partially curated | six small prop slices only; raw pack not committed |
| `fishing_free` | `~/Downloads/fishing_free` | excluded | bundled license is non-commercial |
| Sunnyside / Tiny RPG / Jungle / other local packs | `~/Downloads/...` | not bundled | not needed for this polish pass; would require per-pack license/provenance update before use |

No itch.io downloads were performed in this pass. No full third-party packs were
committed.

## LibreSprite / PixelLab verification

LibreSprite paths verified:

```text
/Applications/LibreSprite.app/Contents/MacOS/libresprite
~/Library/Application Support/LibreSprite/scripts/PixelLab.js
```

LibreSprite is the approved local inspection/export tool for the Buddy Studio
workflow. PixelLab generation remains disabled unless explicitly approved because
it may use credits.

## Excluded assets

- `fishing_free` and other non-commercial assets.
- Full raw third-party packs.
- Copyrighted/franchise/ripped assets.
- Bitbud source WebP atlas.
- Raw LibreSprite/Aseprite project files unless intentionally documented.
