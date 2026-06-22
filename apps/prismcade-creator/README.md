# Prismcade Creator MVP

Tiny manifest-first creator prototype plus the first Prismcade Character Creation Station.

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
| `character-station.html` | Build an outfit-safe 64×64 avatar recipe from the female beta and male alpha source-pack contract. |

## Character Station notes

The Character Station intentionally exports a recipe first. Final runtime sprites should come from sliced, transparent, 64×64 atlas parts after the seller/source files are committed or attached in the source asset package.

Body-only public exports are blocked. Every user-facing recipe must include starter clothing or an outfit layer.
