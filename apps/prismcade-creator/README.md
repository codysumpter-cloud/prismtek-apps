# Prismcade Creator MVP

Tiny manifest-first game creator prototype plus the first Prismcade Character Creation Station.

## Run

From the repo root:

```bash
python3 -m http.server 4173
```

Open:

```txt
http://localhost:4173/apps/prismcade-creator/
http://localhost:4173/apps/prismcade-creator/character-station.html
```

## Surfaces

| Surface | Purpose |
| --- | --- |
| `index.html` | Choose a game template, browse Prismcade asset rows, select reviewed rows, and export a Prismcade game manifest. |
| `character-station.html` | Build an outfit-safe 64x64 avatar recipe, Prismcade character manifest, and preview PNG from the female beta and male alpha source-pack contract. |

## Character Station notes

The Character Station exports both:

- `prismcade-character-recipe-v0`
- `prismcade-character-manifest-v0`

The backing registry is:

```text
data/prismcade/character-creator-packs.json
```

Sample exports live at:

```text
data/prismcade/character-recipes/starter-avatar.recipe.json
data/prismcade/character-manifests/starter-avatar.manifest.json
```

Pixel Fruit Arena can consume the sample shape through:

```text
games/pixel-fruit-arena/src/characters/prismcadeCreatorAdapter.js
```

Final runtime sprites should come from sliced, transparent, 64x64 atlas parts after the seller/source files are committed or attached with license receipts.

Body-only public/runtime exports are blocked. Every user-facing recipe must include starter clothing or an outfit layer.

## Native Prismcade link

The SwiftUI Prismcade hub includes a Creator Tools card for the station. Start the repo-root HTTP server above, run the native Xcode app, and use **Open Creator** from the hub. The native pointer is bundled at:

```text
apps/prismcade-native/Shared/Resources/Creator/character-station-link.json
```

## Validate

```bash
npm run prismcade:validate-character-creator-packs
```
