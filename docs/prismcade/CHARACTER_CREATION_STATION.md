# Prismcade Character Creation Station

The Character Creation Station is the first user-facing Prismcade avatar builder surface. It uses the uploaded 64×64 seller/source packs as a **recipe contract first**, then swaps to atlas-backed rendering after the source art is sliced into normalized transparent frames.

## Current scope

```txt
apps/prismcade-creator/character-station.html
  Browser-only character recipe builder
  Safe procedural 64×64 preview
  Local source-sheet preview upload
  JSON recipe export

data/prismcade/character-creator-packs.json
  Female and male source-pack status
  Slot schema for body, skin, face, hair, outfit, accessory, emote, animation
  Safe export policy
```

## Source pack status

| Pack | Status | Notes |
| --- | --- | --- |
| `female-64-v1-2-body-update` | `creator_ready_beta` | Strongest current base. Has broad face, hair, emote, body, clothing, walking, and breathing coverage. |
| `male-64-v1-0-alpha` | `creator_ready_alpha` | Good base/head/hair foundation, but the uploaded copy is missing male clothing parity and needs normalized animation rows. |

## Safety rule

The creator should never ship a public body-only avatar. The body layers are construction parts. Every exported recipe must include an outfit or starter suit.

```txt
internal base body: allowed
public body-only export: blocked
starter outfit required: yes
```

## Run locally

Serve the repo root so the creator can fetch `data/prismcade/character-creator-packs.json`:

```bash
python3 -m http.server 4174
open http://localhost:4174/apps/prismcade-creator/character-station.html
```

If you run from `apps/prismcade-creator`, the page still opens, but it will not be able to fetch the repo-root data file. Serve the repo root for the full station.

## Next implementation pass

1. Commit or attach the seller/source binaries in the agreed asset-source package path.
2. Slice the female pack into transparent 64×64 parts using the slot contract.
3. Add the seller's remaining male clothing/animation files when available.
4. Replace the procedural preview with atlas-backed canvas composition.
5. Save recipes to Prismcade profile/customization storage.
6. Wire exported recipes into games such as Pixel Fruit Arena.
