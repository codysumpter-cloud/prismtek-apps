# Prismcade World Builder

The Prismcade World Builder is a dependency-free web creator surface at `apps/prismcade-creator/world-builder.html`.

## What it does now

- Move a builder ghost around a large scene with WASD or arrow keys.
- Place prototype objects anywhere with click or tap.
- Select and drag existing objects.
- Remove misplaced objects with Erase mode.
- Edit object name, position, size, layer, collision, interaction, and notes.
- Save and load locally with browser storage.
- Export a `prismcade-world-scene-v0` scene JSON.
- Export a generated `prismcade-game-v0` manifest.

## Scene contract

The first fixture is `data/prismcade/world-scenes/starter-world.scene.json`.

Each object uses a simple prefab kind such as `spawn`, `block`, `platform`, `wall`, `crate`, `tree`, `house`, `water`, `coin`, `sign`, `enemy`, or `portal`.

## Native bridge

Native Prismcade can point at the same local web surface through `apps/prismcade-native/Shared/Resources/Creator/world-builder-link.json`.

That keeps the web, Windows HTML, macOS, and iOS creator path aligned while a later SpriteKit-native editor is built.

## Next runtime step

The next PR should add a scene runtime adapter that reads `prismcade-world-scene-v0`, maps prefab kinds to promoted Prismcade assets, and creates a playable generated game folder from the exported manifest.
