# Prismcade World Builder

The Prismcade World Builder is a dependency-free web creator surface at:

```text
apps/prismcade-creator/world-builder.html
```

Run it from the repo root:

```bash
python3 -m http.server 4173
```

Then open:

```text
http://localhost:4173/apps/prismcade-creator/world-builder.html
```

## What it does now

- Move a builder ghost around a large scene with WASD or arrow keys.
- Place prototype objects anywhere with click or tap.
- Select and drag existing objects.
- Remove misplaced objects with Erase mode.
- Edit object name, position, size, layer, collision, interaction, and notes.
- Save and load locally with browser storage.
- Export a `prismcade-world-scene-v0` scene JSON.
- Export a generated `prismcade-game-manifest-v0` manifest.

## Scene contract

The first fixture is:

```text
data/prismcade/world-scenes/starter-world.scene.json
```

Minimum shape:

```json
{
  "schemaVersion": "prismcade-world-scene-v0",
  "id": "starter-world",
  "title": "Starter World",
  "worldSize": { "width": 4096, "height": 3072 },
  "gridSize": 16,
  "builderStart": { "x": 256, "y": 256 },
  "objects": []
}
```

Each object uses a simple prefab kind such as `spawn`, `block`, `platform`, `wall`, `crate`, `tree`, `house`, `water`, `coin`, `sign`, `enemy`, or `portal`.

## Native bridge

Native Prismcade can point at the same local web surface through:

```text
apps/prismcade-native/Shared/Resources/Creator/world-builder-link.json
```

That keeps the web, Windows HTML, macOS, and iOS creator path aligned while a later SpriteKit-native editor is built.

## Next runtime step

The next PR should add a scene runtime adapter that reads `prismcade-world-scene-v0`, maps prefab kinds to promoted Prismcade assets, and creates a playable generated game folder from the exported manifest.
