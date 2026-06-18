# Prismcade character pack standard

A Prismcade character pack is the normalized, game-ready contract between generated art and Prismcade games.

## Required files

```txt
metadata.json
manifest.json
PROVENANCE.md
spritesheets/*.png
```

`source/`, `states/`, `animations/`, `gifs/`, and `showcase.gif` are recommended but not always required for early packs.

## `metadata.json`

Required fields:

- `schemaVersion`: `prismcade-character-pack-v0`
- `characterId`
- `displayName`
- `sourceTool`: `pixellab`, `pixelorama`, `manual`, `generated`, `mixed`, or `contract`
- `assetMode`: `assets-required` or `contract-only`
- `targetFrame.width`
- `targetFrame.height`
- `transparentBackground`
- `provenance[]`

## `manifest.json`

Required fields:

- `schemaVersion`: `prismcade-animation-manifest-v0`
- `characterId`
- `frameWidth`
- `frameHeight`
- `anchor`
- `baselineY`
- `requiredAnimations[]`
- `animations[]`

Each animation must include `id`, `source`, frame data, `fps`, `loop`, `anchor`, `baselineY`, `hitbox`, `hurtbox`, and `tags[]`.

## Canonical animation ids

Use Prismcade canonical slot names where possible:

```txt
idle walk run jump fall land hurt ko
melee_slash melee_thrust melee_spin cast projectile impact
victory defeat emote_happy emote_angry emote_shocked thinking
```

## Anchor and baseline

The default 64x64 character anchor is:

```json
{ "x": 32, "y": 56 }
```

The default baseline is `56`. This leaves a small safety margin under the feet so idle/walk frames do not get clipped in-game.
