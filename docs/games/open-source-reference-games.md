# Open source reference games and engines

This document is the Prismtek Apps intake policy for external game references, catalogs, engines, and art sources.

## Rule of thumb

Use external projects as reference material first. Do not ship third-party code, art, audio, data files, binaries, game modules, or branded content from these sources until the exact files have a clear license and provenance record.

A public repository is not automatically safe to vendor. A game engine can be open source while its content still depends on proprietary original assets.

## Registry location

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

## Engine and framework batch

| Reference | Status | Best Prismtek use |
| --- | --- | --- |
| Godot | Candidate engine spike | Broad 2D/3D, desktop, mobile, RGDS Android/Linux experiments. |
| Phaser | Preferred web engine reference | Existing browser arcade games and web-first upgrades. |
| raylib | Candidate handheld engine spike | Low-resource arcade and handheld/Linux experiments. |
| Bevy | Research engine reference | Rust ECS, simulation, AI, and future native systems. |
| libGDX | Candidate handheld engine spike | Android/desktop Java runtime comparisons. |
| LÖVE | Candidate arcade engine spike | Lua arcade prototypes and small game experiments. |
| HaxeFlixel | Candidate web/native 2D engine | Pixel-art arcade and cross-target 2D experiments. |
| MonoGame | Reference engine | C#/XNA-style desktop/mobile architecture reference. |
| Flame | Candidate mobile engine spike | Flutter/mobile-first minigame surfaces. |
| GDevelop | Tooling reference | Visual/event-based rapid prototyping workflow. |
| O3DE | Research engine reference | Heavyweight 3D and simulation research. |
| Stride | Research engine reference | C# 2D/3D research. |
| OGRE | Rendering reference | Rendering architecture only. |
| Solarus | Reference only | 2D action-RPG patterns with copyleft review. |
| Defold | Caution reference | Source-available/cross-platform reference; verify license before adoption. |
| Cocos2d-x | Reference engine | Mature C++ 2D cross-platform architecture. |
| PixiJS | Preferred web rendering reference | Browser 2D rendering, effects, particles, and UI. |
| three.js | Web 3D reference | Browser 3D experiments and product scenes. |
| Babylon.js | Web 3D reference | Browser 3D/WebXR/product visualization experiments. |
| PlayCanvas Engine | Web 3D reference | Open web 3D engine reference. |
| Panda3D | Research engine reference | Python-friendly 3D simulations and AI/game research. |
| jMonkeyEngine | Research engine reference | Java 3D and Android/desktop comparisons. |
| Urho3D | Research engine reference | Lightweight C++ 2D/3D experiments. |
| Fyrox | Research engine reference | Rust 2D/3D/editor-driven workflows. |
| macroquad | Candidate arcade engine spike | Tiny Rust 2D arcade prototypes. |
| Ren'Py | Reference engine | Narrative/dialogue-heavy game systems. |
| Minetest / Luanti | Research engine reference | Voxel/world simulation and survival reference. |
| OpenRA | Reference only | RTS architecture; avoid franchise assets. |
| SuperTuxKart | Reference only | Kart/racing architecture. |
| Wesnoth | Reference only | Turn-based strategy architecture. |
| Veloren | Reference only | Open-world multiplayer RPG reference. |

## Asset-source batch

| Source | Status | Best Prismtek use |
| --- | --- | --- |
| Screaming Brain Studios | Preferred asset source | Pixel textures, tiles, effects, and small game-art packs. |
| OpenGameArt | Per-asset review | General 2D/3D/audio assets with varied licenses. |
| Kenney | Preferred asset source | 2D, UI, 3D, audio, and icons. |
| itch.io Game Assets | Per-asset review | Pixel packs, UI packs, game templates, audio. |
| CraftPix Freebies | Per-pack review | 2D characters, tiles, UI, effects. |
| GameDev Market | Per-asset review | Marketplace assets with file-specific terms. |
| Lospec | Per-resource review | Pixel palettes, references, and community resources. |
| Game-icons.net | Attribution required | Icons for UI, abilities, status effects. |
| Google Fonts | Per-font review | UI and display fonts. |
| Open Font Library | Per-font review | Open fonts with varied licenses. |
| Poly Haven | Preferred 3D asset source | HDRIs, textures, models. |
| ambientCG | Preferred texture source | Materials and textures. |
| Quaternius | Preferred 3D asset source | Low-poly models, creatures, props, vehicles. |
| Sketchfab | Per-model review | 3D models. |
| CGTrader free models | Per-model review | 3D marketplace models. |
| Freesound | Per-sound review | Sound effects and ambient audio. |
| FreePD | Preferred music source | Prototype music. |
| Incompetech | Attribution required | Music with track-level license review. |
| Audionautix | Attribution required | Music with attribution review. |
| ZapSplat | Caution audio source | SFX with account/attribution/redistribution checks. |
| Sonniss GDC audio bundles | Bundle review | Large game-audio packs. |
| Pixabay | Per-asset review | Photos, audio, music, and media references. |
| Mixkit | Per-asset review | Music, SFX, video, and templates. |
| Pexels | Per-asset review | Mood/reference imagery and video. |
| Unsplash | Per-asset review | Mood/reference imagery. |
| LibreGameAssets / FreeGameDev | Reference catalog | Discovery only. |
| Liberated Pixel Cup | Caution asset source | Pixel style reference; review share-alike/copyleft terms. |

## Existing specialized references

| Reference | Status | Best Prismtek use |
| --- | --- | --- |
| Awesome Game Remakes | Reference catalog | Discover open-source remakes and source ports; review every linked project separately. |
| Open Source Game Clones | Reference catalog | Discovery source for clone/remake projects; review every linked project separately. |
| T-Rex Runner DS | Reference only | devkitPro Nintendo DS project layout and simple game loop. |
| TerrariaDS | Reference only | DS tile-world, survival, inventory, crafting, and touch patterns. |
| Minicraft DS Edition | Reference only | DS dual-screen survival UI, save/load, map, culling, and inventory patterns. |
| Castagne | Candidate engine spike | Pixel Fruit Arena combat architecture and fighting-game tooling. |
| OpenBOR | Candidate engine spike | Original Prismtek side-scrolling brawler modules. |
| Ikemen GO | Candidate engine spike | Traditional 2D fighter experiments and RGDS Android/Linux viability checks. |
| TORCS | Reference only | Racing AI, vehicle simulation, track systems, and race-bot experiments. |

## Safe implementation path

1. Import a reference locally with the helper when it is a git target.
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
npm run references:validate
node tools/reference-games/import-reference-game.mjs godot
node tools/reference-games/import-reference-game.mjs phaser
node tools/reference-games/import-reference-game.mjs raylib
node tools/reference-games/import-reference-game.mjs openbor
node tools/reference-games/import-reference-game.mjs ikemen-go
node tools/reference-games/import-reference-game.mjs terrariads
```

Catalogs or websites that are not git repositories should be opened manually and recorded in the manifest.

## Active experiment scaffolds

The first reference-to-product spikes now live under `experiments/`:

| Experiment | Purpose | Status |
| --- | --- | --- |
| `experiments/openbor-prismtek-brawler/` | Evaluate OpenBOR for an original Prismtek arcade brawler path. | Scaffolded |
| `experiments/castagne-pixel-fruit-spike/` | Evaluate Castagne for Pixel Fruit Arena combat architecture. | Scaffolded |
| `experiments/ikemen-prismtek-fighter/` | Evaluate Ikemen GO for a traditional 2D Prismtek fighter path. | Scaffolded |
| `experiments/fighting-engine-bakeoff/` | Compare current PFA combat, Castagne, and Ikemen GO. | Scaffolded |

## Remaining recommended builds

- `experiments/godot-prismtek-prototype/`
- `experiments/raylib-handheld-arcade/`
- `experiments/phaser-arcade-upgrade/`
- `experiments/torcs-racing-ai/`
- `tools/ds-homebrew-kit/templates/runner/`
- `tools/ds-homebrew-kit/templates/tile-world/`
- `tools/ds-homebrew-kit/templates/dual-screen-survival/`

The goal is not to become a museum of external projects. The goal is to turn proven open-source patterns into original Prismtek games that can ship cleanly.
