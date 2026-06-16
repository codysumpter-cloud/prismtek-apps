# Asset source policy

Prismtek Apps can use external asset sources, but every committed asset needs a provenance record.

## Preferred sources

### Screaming Brain Studios

Screaming Brain Studios is a preferred source because its site states that every asset pack is released under CC0 / Public Domain terms and can be used in commercial or non-commercial projects, modified or unmodified.

Still record the exact pack URL and file list before committing anything.

### OpenGameArt

OpenGameArt is a useful asset source, but licensing is per asset. Do not assume the whole site has one license.

Before committing an OpenGameArt asset, capture:

- asset page URL
- author/uploader
- exact license
- attribution text
- whether commercial use is allowed
- whether derivatives are allowed
- whether share-alike applies
- whether the uploaded work depends on another asset

Prefer CC0 assets for fast Prismtek game production. Use CC-BY assets only with attribution records. Use share-alike assets only when the target product can honor the license.

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
```

## Do not commit

- assets ripped from commercial games
- fan-game sprites using protected characters
- assets with non-commercial-only terms for products we may monetize
- assets with no clear author or license
- archives whose contents have mixed or unknown provenance
- generated binaries from external game engines

## Intake checklist

1. Download asset locally.
2. Inspect included license/readme files.
3. Create `ATTRIBUTION.md`.
4. Add the asset to a manifest.
5. Use the asset in a Prismtek-owned scene or prototype.
6. Keep visual style consistent with the target game.

No blind asset dumps. Use assets intentionally.
