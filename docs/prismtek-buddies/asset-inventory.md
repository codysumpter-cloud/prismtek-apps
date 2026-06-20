# Prismtek Buddies — Asset Inventory

Provenance and ship-safety inventory for art/asset packs considered for the
`apps/prismtek-buddies-native/` SwiftUI app.

**Scope of this pass:** documentation only. No third-party pack is bundled into
the app. Counts below were re-verified with `find` on 2026-06-20 and match the
recon data. `safe-to-ship` reflects owner (Cody) classification: all itch.io
free packs are owner-attested ship-safe **except `fishing_free`**, which carries
an explicit non-commercial license.

## Third-party packs (NOT bundled this pass)

| Name | Path | Files | Images | Bundled license file | Safe to ship | Intended use | Notes |
|---|---|---|---|---|---|---|---|
| Christmas update | `~/Downloads/Christmas update` | 88 | 88 | none | yes | seasonal room decor (future) | itch.io free, owner-stated |
| Clover Valley V2 Free | `~/Downloads/Clover Valley V2 Free` | 34 | 33 | `READ ME.txt` (free pack, "consider buying full"; no explicit grant) | yes | room/environment art (future) | owner-stated ship-safe |
| Garden_Planters | `~/Downloads/Garden_Planters` | 8 | 7 | `ReadMe.txt` (0-mem0ry.itch.io) | yes | decor/plant props (future) | owner-stated ship-safe |
| Package | `~/Downloads/Package` | 3 | 3 | none | yes | misc art (future) | owner-stated ship-safe |
| Semi realist room generator sprites appartment | `~/Downloads/Semi realist room generator sprites appartment` | 219 | 219 | none | yes | room generator art (future) | owner-stated ship-safe |
| Sunnyside_World_ARCHIVED_ASSETS | `~/Downloads/Sunnyside_World_ARCHIVED_ASSETS` | 11 | 1 | none | yes | environment art (future) | owner-stated ship-safe |
| Sunnyside_World_ASSET_PACK_V2.1 | `~/Downloads/Sunnyside_World_ASSET_PACK_V2.1` | 6369 | 5869 | none | yes | large environment/tileset library (future) | owner-stated ship-safe |
| Tiny RPG Character Asset Pack -Demo Soldier&Orc | `~/Downloads/Tiny RPG Character Asset Pack -Demo Soldier&Orc` | 16 | 16 | none | yes | character sprites (future) | owner-stated ship-safe |
| Tiny RPG Character Asset Pack v1.02 -Free Soldier&Orc | `~/Downloads/Tiny RPG Character Asset Pack v1.02 -Free Soldier&Orc` | 36 | 36 | none | yes | character sprites (future) | owner-stated ship-safe |
| Tiny RPG Character Asset Pack v1.03 -Free Soldier&Orc | `~/Downloads/Tiny RPG Character Asset Pack v1.03 -Free Soldier&Orc` | 49 | 49 | none | yes | character sprites (future) | owner-stated ship-safe |
| char free | `~/Downloads/char free` | 3 | 3 | none | yes | character art (future) | owner-stated ship-safe |
| **fishing_free** | `~/Downloads/fishing_free` | 4 | 2 | `license.txt` — **explicitly NON-COMMERCIAL**: "can't be used in any commercial project, resold/redistributed, even if modified" | **NO** | prototype-only / non-shipping experiments | **NOT ship-safe — non-commercial license. Excluded from any shipping build.** |
| interior free | `~/Downloads/interior free` | 2 | 1 | `read me.txt` (free, no terms) | yes | interior decor (future) | owner-stated ship-safe |
| mini-timekeeper | `~/Downloads/mini-timekeeper` | 4 | 0 | none | yes | non-art / tool reference | owner-stated ship-safe; **0 images** (non-art/tool) |

## Owner-IP and integrated assets (SAFE — own IP)

| Name | Path | Safe to ship | Notes |
|---|---|---|---|
| Bitbud pet (source) | `~/.codex/pets/bitbud/` | yes | Cody's own pet. Already integrated into the app as extracted PNG frames under `Shared/Resources/BitbudFrames/`. Source `spritesheet.webp` (1,819,242 bytes) is **not** committed to the repo. |
| Buddy showcase GIF | `~/Documents/Buddy_showcase.gif` | yes | Cody's own art |
| Buddy rotations GIF | `~/Documents/Buddy_rotations_8dir.gif` | yes | Cody's own art |
| Buddy desktop art | `~/Desktop/Buddy-*.png` / `~/Desktop/Buddy-*.webp` | yes | Cody's own art |
| Buddy Grok showcase | repo `Buddy_Grok_64_showcase.gif` | yes | Cody's own art |

## Excluded (not an asset pack)

| Name | Path | Files | Images | Reason |
|---|---|---|---|---|
| Mac (misc) | `~/Documents/Mac` | 2457 | 31 | Miscellaneous/system files, not an asset pack. Excluded from inventory. |

## Verification notes

- Pack file/image counts re-run via `find ... -type f` (and image-extension
  filter) on 2026-06-20; all matched recon data exactly.
- `fishing_free/license.txt` read directly — non-commercial wording confirmed
  verbatim.
- Bitbud source `spritesheet.webp` size verified: `stat -f "%z"` → `1819242`.
- itch.io "free pack" terms are confirmed on each pack's itch.io page per owner;
  not all bundled files contain an explicit license grant (see per-row notes).
