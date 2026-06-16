# Open source reference games and engines

This document is the Prismtek Apps intake policy for external game references, catalogs, engines, and art sources.

## Rule of thumb

Use external projects as reference material first. Do not ship third-party code, art, audio, data files, binaries, game modules, or branded content from these sources until the exact files have a clear license and provenance record.

A public repository is not automatically safe to vendor. A game engine can be open source while its content still depends on proprietary original assets.

## Added reference sources

The canonical machine-readable registry lives at:

```txt
data/reference-games/open-source-reference-games.json
```

The local import helper is:

```bash
node tools/reference-games/import-reference-game.mjs <reference-id>
```

Local checkouts are written to:

```txt
.external/reference-games/
```

That path is ignored by git.

## Current registry

| Reference | Status | Best Prismtek use |
| --- | --- | --- |
| Awesome Game Remakes | Reference catalog | Discover open-source remakes and source ports; review every linked project separately. |
| Open Source Game Clones | Reference catalog | Discovery source for clone/remake projects; review every linked project separately. |
| Screaming Brain Studios | Preferred asset source | CC0/public-domain-style assets for original Prismtek games. |
| OpenGameArt | Asset source with per-asset review | Good source for art/audio, but every asset needs exact license and attribution capture. |
| T-Rex Runner DS | Reference only | devkitPro Nintendo DS project layout and simple game loop. |
| TerrariaDS | Reference only | DS tile-world, survival, inventory, crafting, and touch patterns. |
| Minicraft DS Edition | Reference only | DS dual-screen survival UI, save/load, map, culling, and inventory patterns. |
| Castagne | Candidate engine spike | Pixel Fruit Arena combat architecture and fighting-game tooling. |
| OpenBOR | Candidate engine spike | Original Prismtek side-scrolling brawler modules. |
| Ikemen GO | Candidate engine spike | Traditional 2D fighter experiments and RGDS Android/Linux viability checks. |
| TORCS | Reference only | Racing AI, vehicle simulation, track systems, and race-bot experiments. |

## Safe implementation path

1. Import a reference locally with the helper.
2. Inspect the license and content boundaries.
3. Write notes into a Prismtek-owned design doc.
4. Rebuild the useful pattern with original Prismtek code and assets.
5. Only copy third-party files after creating a provenance record.

## Provenance record required before committing third-party files

Every imported file needs:

- source URL
- source project name
- original author or uploader
- exact license
- attribution text if required
- whether modified
- whether commercial use is permitted
- whether redistribution is permitted
- destination path in this repository

## Starter commands

```bash
node tools/reference-games/import-reference-game.mjs awesome-game-remakes
node tools/reference-games/import-reference-game.mjs openbor
node tools/reference-games/import-reference-game.mjs ikemen-go
node tools/reference-games/import-reference-game.mjs torcs
node tools/reference-games/import-reference-game.mjs terrariads
```

Catalogs or websites that are not git repositories should be opened manually and recorded in the manifest.

## Recommended next builds

- `experiments/castagne-pixel-fruit-spike/`
- `experiments/ikemen-prismtek-fighter/`
- `experiments/openbor-prismtek-brawler/`
- `experiments/torcs-racing-ai/`
- `tools/ds-homebrew-kit/templates/runner/`
- `tools/ds-homebrew-kit/templates/tile-world/`
- `tools/ds-homebrew-kit/templates/dual-screen-survival/`

The goal is not to become a museum of external projects. The goal is to turn proven open-source patterns into original Prismtek games that can ship cleanly.
