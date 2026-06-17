# Prismcade Playable Roster

Pixel Fruit Arena now has a Prismcade/Pixellab roster slice wired into the playable browser runtime.

Runtime roster:

```txt
games/pixel-fruit-arena/data/characters/prismcade_playable_roster.json
games/pixel-fruit-arena/src/characters/prismcadeRoster.js
```

Generated runtime sheets:

```txt
games/pixel-fruit-arena/assets/characters/prismcade-pixellab/
```

## Playable Characters

| Character | Source variant | Runtime sprite key | Animation fidelity |
| --- | --- | --- | --- |
| Buddy | `buddy` | `prismcade_buddy` | source-animation-normalized |
| Prismtek | `prismtek` | `prismcade_prismtek` | source-animation-normalized |
| Prismtek Jones | `prismtek-jones` | `prismcade_prismtek_jones` | rotation-derived |
| Female Blue Hoodie | `female-character-blue-hoodie` | `prismcade_female_blue_hoodie` | rotation-derived |
| Ponytail Guy | `ponytail-guy` | `prismcade_ponytail_guy` | rotation-derived |
| Prismtek Pixel God | `prismtek-pixel-god` | `prismcade_prismtek_pixel_god` | rotation-derived |
| PrismBot Pixel God | `prismbot-pixel-god` | `prismcade_prismbot_pixel_god` | rotation-derived |

`source-animation-normalized` means the importer found PixelLab animation frames and converted them into 64x64 Pixel Fruit Arena strips.

`rotation-derived` means the character is playable now, but the animation strip is a movement/action placeholder derived from a reviewed rotation frame. Queue PixelLab animation jobs before calling those final production animations.

## Repeatable Import

From `games/pixel-fruit-arena/`:

```powershell
powershell -ExecutionPolicy Bypass -File tools/import_pixellab_prismcade_roster.ps1 -AllowDownload
```

The importer reads local PixelLab export zips from `Downloads` first, then uses registry download URLs when `-AllowDownload` is passed. It writes normalized 64x64 runtime outputs and per-character manifests. Raw PixelLab export packets are not committed.

Validation:

```bash
npm run validate:prismcade-roster
npm test
```

Repository-level Prismcade validation:

```bash
npm run prismcade:validate:all
```

## Engine Boundary

OpenBOR, MUGEN, and Ikemen are reference paths for future fighter/brawler adapter work. They are not imported into Pixel Fruit Arena in this slice because the current repo adapter records mark them as contract-only, and downloaded MUGEN packs can contain third-party characters/stages.

BMO remains held back as a 4-direction source group. Do not invent diagonal frames for it; either use it in a cardinal-direction game mode or generate a real 8-direction derivative.
