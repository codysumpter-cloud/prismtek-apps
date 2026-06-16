# Asset source policy

Prismtek Apps can use external asset sources, but every committed asset needs a provenance record.

The machine-readable source registry lives at:

```txt
data/reference-games/open-source-reference-games.json
```

## Source tiers

| Tier | Meaning | Commit posture |
| --- | --- | --- |
| Preferred asset source | The source commonly offers permissive assets and is worth checking first. | Still require pack/file provenance before committing. |
| Per-asset review | The source has many licenses or creator-specific terms. | Review every page/file. |
| Attribution required | The source can be usable, but attribution text must be recorded exactly. | Commit only with `ATTRIBUTION.md`. |
| Caution source | Useful, but terms/account restrictions/share-alike/copyleft risks may complicate shipping. | Reference or prototype only until reviewed. |
| Catalog/discovery | A list of other sources. | Do not treat catalog entries as approved assets. |

## Preferred starting sources

Use these first when creating original Prismtek assets:

| Source | Best for | Notes |
| --- | --- | --- |
| Screaming Brain Studios | Pixel textures, tiles, effects, small game art | Site states CC0 / Public Domain style terms. Record exact pack URL and file list. |
| Kenney | 2D sprites, UI, 3D props, audio, icons | Often CC0. Verify each pack page and keep provenance. |
| Poly Haven | HDRIs, textures, models | Good for 3D scenes and lighting references. Verify asset page. |
| ambientCG | Materials and textures | Good for 3D or stylized material workflows. Verify asset page. |
| Quaternius | Low-poly 3D models | Good for original creature, survival, and prototype scenes. Verify pack page. |
| FreePD | Music | Good for quick prototype music. Record track URL and license. |

## Per-asset review sources

These are useful but every asset needs its own record:

- OpenGameArt
- itch.io Game Assets
- CraftPix Freebies
- GameDev Market
- Sketchfab
- CGTrader free models
- Freesound
- Pixabay
- Mixkit
- Pexels
- Unsplash
- Open Font Library
- Google Fonts
- Lospec resources

## Attribution-required / caution sources

These can still be useful, but do not commit files without confirming requirements:

- Game-icons.net
- Incompetech
- Audionautix
- ZapSplat
- Sonniss GDC audio bundles
- Liberated Pixel Cup
- LibreGameAssets / FreeGameDev resource lists

## Before committing any asset

Capture:

- source URL
- source project/site name
- asset title or pack name
- original author/uploader
- exact license
- license URL or included license file
- attribution text if required
- whether modified
- whether commercial use is permitted
- whether redistribution is permitted
- whether derivatives are permitted
- whether share-alike/copyleft applies
- destination path in this repository

## Repository layout

Use this structure for approved third-party assets:

```txt
assets/third-party/<source>/<pack-name>/
  README.md
  LICENSE.txt
  ATTRIBUTION.md
  files...
```

Use this structure for original curated Prismtek game assets:

```txt
packages/game-assets/
  README.md
  manifests/
  sprites/
  tiles/
  ui/
  sfx/
  fonts/
  models/
  textures/
```

## Do not commit

- assets ripped from commercial games
- fan-game sprites using protected characters
- assets with non-commercial-only terms for products we may monetize
- assets with no clear author or license
- archives whose contents have mixed or unknown provenance
- generated binaries from external game engines
- marketplace downloads whose license forbids redistribution
- fonts without the font license file
- audio that requires account-only access or cannot be redistributed

## Intake checklist

1. Download asset locally.
2. Inspect included license/readme files.
3. Create `LICENSE.txt` and `ATTRIBUTION.md` beside the asset files.
4. Add the asset to a manifest.
5. Use the asset in a Prismtek-owned scene or prototype.
6. Keep visual style consistent with the target game.

No blind asset dumps. Use assets intentionally.
