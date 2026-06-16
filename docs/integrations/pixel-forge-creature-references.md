# Pixel Forge Creature Creator References

Status: **reference-only / clean-room translation required**

These sources are useful for Prismtek Pixel Forge and future Prismtek creature games, but neither should be bulk-imported into production assets.

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

## Next implementation step

Add a `packages/creature-pack-contract/` package that defines the JSON schema and validation helpers for original Prismtek creature packs. Pixel Forge can then generate or validate creature packs without relying on Pokemon/Fakemon naming or unsafe third-party asset assumptions.
