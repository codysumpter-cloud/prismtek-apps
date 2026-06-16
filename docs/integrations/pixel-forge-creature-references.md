# Pixel Forge Creature Creator References

Status: **reference-only / clean-room translation required**

These sources are useful for Prismtek Pixel Forge and future Prismtek creature games, but neither creature references nor editor references should be bulk-imported into production assets.

## Source: FakemonCreator

URL: `https://github.com/Jerakin/FakemonCreator`

Observed facts:

- Public GitHub repository for an application that builds Fakemon packages for Pokedex5E.
- Repository code is MIT licensed.
- README recommends starting from similar Pokemon or moves because there are many fields to fill.
- README describes saving a package before custom moves/Fakemons become available to other created Fakemons.
- README describes publishing a `.fkmn` package by submitting it for review.

### Safe Prismtek use

Use this as a reference for:

- creature package editor UX,
- field-heavy creator flows,
- custom creature + move relationships,
- save-before-reference rules,
- package review/submission workflow,
- desktop packaging/release ideas.

### Blocked Prismtek use

Do not use this as a shipping template for Pokemon-adjacent content.

Blocked:

- copied Pokemon/Pokedex naming,
- upstream sample data as Prismtek game content,
- package imports that include third-party/franchise creatures,
- screenshots or example creatures as shipped assets,
- claims of official Pokemon compatibility.

## Source: Pokengine Mongratis Collection

URL: `https://pokengine.org/collections/107s7x9x/Mongratis?about`

Observed facts:

- The page describes Mongratis as a community-sourced dex made from donated fan creatures.
- The page says Mongratis creatures are available for use on and off Pokengine.
- The page says this is not true for every Pokengine dex and that other dexes are the IP of their independent creators.
- The page asks users who make missing icons/backs/overworlds/details for their own use to share them back where possible.

### Safe Prismtek use

Use this as a reference for:

- community-dex contribution models,
- explicit collection-level rights labels,
- creator attribution expectations,
- missing-asset completion workflows,
- separating front sprites, backs, icons, overworlds, forms, and metadata.

### Blocked Prismtek use

Do not treat fan-game permission as a blanket commercial license.

Blocked:

- bulk-importing Mongratis art into Prismtek commercial games,
- using any non-Mongratis Pokengine dex asset without explicit creator permission,
- copying Pokemon-like identity or presentation,
- shipping assets without creator/source/provenance receipts.

## Source: Pix2D

URL: `https://pix2d.com`

Repository: `https://github.com/gritsenko/pix2d`

Observed facts:

- Pix2D presents itself as a free/open-source pixel art and sprite editor.
- The website lists sprites, pixel art, animations, palette control, layers, onion skin, custom grids, text tools, mobile support, and browser use.
- The GitHub README describes cross-platform support for Windows, Linux, Android, and Web.
- The GitHub README says public APIs and the plugin system are under development.
- The repository presents MIT licensing.

### Safe Prismtek use

Use this as a reference for:

- mobile-first pixel editor UX,
- local-first browser editing,
- custom project file format design,
- plugin architecture planning,
- sprite and animation export expectations,
- tablet/phone ergonomics for Pixel Forge.

### Blocked Prismtek use

Do not treat Pix2D as a vendored dependency yet.

Blocked:

- copying Pix2D branding, UI identity, website copy, or sample art,
- depending on under-development plugin APIs as Prismtek contracts,
- vendoring code without dependency and maintenance review,
- committing telemetry or app-store secrets from any upstream build flow.

## Source: Pixelorama

URL: `https://pixelorama.org`

Repository: `https://github.com/Orama-Interactive/Pixelorama`

Observed facts:

- Pixelorama describes itself as an open-source pixel art multitool.
- Pixelorama supports frame-by-frame animation, onion skinning, frame tags, real-time drawing during playback, multi-layer projects, audio sync, spritesheet/GIF/video export, and importing from Aseprite, Photoshop, and Krita.
- Pixelorama supports tilemap layers, custom user data, and command-line export automation.
- The GitHub license is MIT.

### Safe Prismtek use

Use this as a reference for:

- animation tags,
- tilemap layer metadata,
- custom user data,
- CLI/bulk export workflows,
- spritesheet/GIF/video export expectations,
- Aseprite/Photoshop/Krita import interoperability.

### Blocked Prismtek use

Do not embed or fork Pixelorama into Prismtek without a separate maintenance decision.

Blocked:

- copying Pixelorama branding, screenshots, sample assets, or UI identity,
- treating editor import compatibility as asset-rights compatibility,
- shipping user projects without separate provenance and license receipts,
- wholesale vendoring without dependency and release review.

## Source: GitHub Pixel Art Tools Collection

URL: `https://github.com/collections/pixel-art-tools`

Observed facts:

- GitHub's collection is a discovery index for pixel art apps/tools.
- It lists projects such as Aseprite, Piskel, pixel-art-react, poxi, Data Pixels, pixel8, Goya, rx, Pixelorama, LibreSprite, Lospec pixel-editor, PixelCraft, PixiEditor, pixel-paint, Pixa.Pics, Pixed, and voidsprite.

### Safe Prismtek use

Use this as a discovery index for:

- finding candidate editor patterns,
- comparing browser/canvas implementations,
- evaluating export formats,
- identifying small focused tools worth separate review.

### Blocked Prismtek use

Blocked:

- treating collection membership as a license grant,
- bulk-copying collection projects,
- skipping per-repo license/dependency/asset review.

## Translation into Prismtek Pixel Forge

Pixel Forge should add a first-class creature pack schema later:

```txt
creature-pack/
  pack.json
  creatures/
    <creature-id>/
      creature.json
      sprites/
        front.png
        back.png
        icon.png
        overworld.png
      animations/
        idle.png
        walk.png
        attack.png
      receipts/
        provenance.json
```

Recommended schema fields:

- `creatureId`
- `displayName`
- `creator`
- `sourceUrl`
- `license`
- `commercialUseAllowed`
- `fanGameOnly`
- `requiresAttribution`
- `derivativeAllowed`
- `frontSprite`
- `backSprite`
- `iconSprite`
- `overworldSprite`
- `animationManifest`
- `moves`
- `abilities`
- `evolutionOrGrowthPath`
- `validationStatus`

Pixel Forge should also add an editor-adapter schema later:

```txt
editor-adapter/
  adapter.json
  importers/
    aseprite.json
    pixelorama.json
    pix2d.json
  exporters/
    spritesheet.json
    gif-preview.json
    tilemap.json
```

Recommended adapter fields:

- `adapterId`
- `sourceTool`
- `sourceUrl`
- `license`
- `supportedImportFormats`
- `supportedExportFormats`
- `animationTagSupport`
- `tilemapSupport`
- `customUserDataSupport`
- `cliSupport`
- `mobileWorkflowNotes`
- `blockedUse`
- `validationStatus`

## Next implementation step

Add a `packages/creature-pack-contract/` package that defines the JSON schema and validation helpers for original Prismtek creature packs. Pixel Forge can then generate or validate creature packs without relying on Pokemon/Fakemon naming or unsafe third-party asset assumptions.

After that, add `packages/pixel-editor-adapter-contract/` so Pixel Forge can track safe import/export adapter contracts for Aseprite, Pixelorama, Pix2D, and browser-first editors without copying entire editor apps into the repo.
