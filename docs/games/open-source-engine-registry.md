# Open source engine registry

This document summarizes the expanded engine/framework batch tracked in `data/reference-games/open-source-reference-games.json`.

## Best next engine spikes

| Engine | Why it matters | Suggested experiment |
| --- | --- | --- |
| Godot | Best broad 2D/3D open engine candidate for Prismtek desktop/mobile/RGDS experiments. | `experiments/godot-prismtek-prototype/` |
| Phaser | Best fit for improving existing browser arcade games without leaving the web stack. | `experiments/phaser-arcade-upgrade/` |
| raylib | Best low-resource C engine candidate for handheld/Linux arcade experiments. | `experiments/raylib-handheld-arcade/` |
| PixiJS | Strong 2D renderer for browser effects, particles, and polished UI. | `experiments/pixijs-arcade-renderer/` |
| Bevy | Strong Rust ECS/simulation research target; not first shipping choice. | `experiments/bevy-simulation-lab/` |

## Full engine/reference batch

| Reference | Status | Best Prismtek use |
| --- | --- | --- |
| Godot | Candidate engine spike | Broad 2D/3D game development. |
| Phaser | Preferred web engine reference | Browser arcade and web-first games. |
| raylib | Candidate handheld engine spike | Low-resource desktop/Linux/handheld prototypes. |
| Bevy | Research engine reference | Rust ECS, simulation, AI, and future native systems. |
| libGDX | Candidate handheld engine spike | Android/desktop Java runtime comparisons. |
| LÖVE | Candidate arcade engine spike | Lua arcade prototypes. |
| HaxeFlixel | Candidate web/native 2D engine | Pixel-art 2D games. |
| MonoGame | Reference engine | C#/XNA-style game architecture. |
| Flame | Candidate mobile engine spike | Flutter/mobile-first minigames. |
| GDevelop | Tooling reference | Visual/event-based authoring workflows. |
| O3DE | Research engine reference | Heavy 3D/simulation research. |
| Stride | Research engine reference | C# 2D/3D exploration. |
| OGRE | Rendering reference | Rendering architecture only. |
| Solarus | Reference only | 2D action-RPG patterns with copyleft review. |
| Defold | Caution reference | Verify custom/source-available terms before adoption. |
| Cocos2d-x | Reference engine | Mature C++ 2D cross-platform architecture. |
| PixiJS | Preferred web rendering reference | Browser rendering, effects, UI, particles. |
| three.js | Web 3D reference | Browser 3D experiments. |
| Babylon.js | Web 3D reference | Browser 3D/WebXR/product scenes. |
| PlayCanvas Engine | Web 3D reference | Open web 3D runtime reference. |
| Panda3D | Research engine reference | Python-friendly 3D simulations. |
| jMonkeyEngine | Research engine reference | Java 3D and Android/desktop comparison. |
| Urho3D | Research engine reference | Lightweight C++ 2D/3D reference. |
| Fyrox | Research engine reference | Rust 2D/3D/editor workflows. |
| macroquad | Candidate arcade engine spike | Tiny Rust 2D arcade prototypes. |
| Ren'Py | Reference engine | Narrative/dialogue-heavy games. |
| Minetest / Luanti | Research engine reference | Voxel/world simulation and survival reference. |
| OpenRA | Reference only | RTS architecture. |
| SuperTuxKart | Reference only | Kart/racing architecture. |
| Wesnoth | Reference only | Turn-based strategy architecture. |
| Veloren | Reference only | Open-world multiplayer RPG reference. |

## Adoption rules

- Prefer Phaser/PixiJS for browser games already in `games/`.
- Prefer raylib for tiny native/handheld arcade experiments.
- Prefer Godot for bigger standalone 2D/3D prototypes.
- Treat copyleft engines and full games as reference-only unless the project intentionally accepts their obligations.
- Treat source-available/custom-licensed engines as caution references until terms are reviewed.
- Do not vendor engine source into shipped paths until the exact license, build model, and distribution obligations are captured.
