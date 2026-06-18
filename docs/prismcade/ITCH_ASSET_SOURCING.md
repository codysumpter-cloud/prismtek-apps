# Prismcade itch.io Asset Sourcing Notes

Status: planning and acquisition guide. Do not import binaries from itch.io without a provenance receipt.

## Discovery pages

- Free pixel art game assets: https://itch.io/game-assets/free/tag-pixel-art
- Free pixel art UI assets: https://itch.io/game-assets/free/tag-pixel-art/tag-user-interface
- Free tileset assets: https://itch.io/game-assets/free/tag-tileset

## Import rule

Every external asset needs a receipt before it becomes a Prismcade runtime asset:

1. Source URL
2. Download date
3. Author / credit string
4. License text captured in repo docs
5. Exact files imported
6. Target Prismcade surface or game
7. Notes about whether raw asset redistribution is allowed

## Good candidates found

| Candidate | Author | Best Prismcade use | License posture |
| --- | --- | --- | --- |
| Complete UI Essential Pack | Crusenho | card frames, buttons, HUD, menus, dialog boxes | High priority. Page lists CC BY 4.0, so attribution is required. |
| Sprout Lands UI Pack | Cup Nooble | cozy UI reference, icons, dialog feel | Use carefully. Free tier is non-commercial only; premium tier is needed for commercial use. |
| Sunnyside World | danieldiggle | cozy world, social hub, farm/town UI examples | High priority. Page allows commercial projects and modification, but no raw asset resale/repackaging. |
| Ansimuz Legacy Collection | ansimuz | side-view and top-down worlds, backgrounds, characters, effects | High priority, but capture explicit license text before production import. |
| Anokolisa Topdown 16x16 Pack | Anokolisa | roguelike maps, heroes, enemies, weapons | Useful candidate, but verify license text before import. |
| Pixel Art Top Down - Basic | Cainos | 32x32 top-down prototypes and maps | Useful candidate, but verify license text before import. |
| 32rogues | Seth | 32x32 roguelike tiles and sprites | Useful candidate, but verify formal license before import. |

## How this plugs into Prismcade

PR #187 added `data/prismcade/repo-asset-packs.json` for repo-local assets. External itch.io candidates should be added later as a separate `external` section or imported only after their receipt exists.

Recommended next code slice:

1. Add `data/prismcade/external-asset-sources.json` with metadata-only candidate records.
2. Add `tools/prismcade/check-asset-receipts.mjs`.
3. Require a receipt before any external asset appears in `apps/prismcade/` runtime UI.
4. Add UI filters for `repo-local`, `external-candidate`, `license-reviewed`, and `runtime-ready`.
