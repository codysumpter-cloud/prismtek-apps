# Prismcade Creator MVP

Status: **manifest-first creator slice**

The first Prismcade creator should be boringly useful: pick a template, enter metadata, choose starter assets, preview a manifest, and export JSON.

It should not start as a full map editor, marketplace, online UGC runtime, or moderation system.

## MVP loop

```txt
template -> title/tags/controls -> starter assets -> manifest JSON -> catalog slot -> package/play
```

## Current static prototype

```txt
apps/prismcade-creator/index.html
```

Open it directly or serve the repo root and visit:

```txt
/apps/prismcade-creator/
```

## Starter templates

| Template | Purpose |
| --- | --- |
| `arcade-one-button` | Flappy-style reflex arcade. |
| `arcade-lane-dodge` | Crossy-style hazard lanes. |
| `arcade-snake` | Route-control score game. |
| `arcade-breakout` | Paddle/combo game. |
| `arcade-stacker` | Timing/precision game. |
| `platform-fighter-lite` | Pixel Fruit Arena-style focused fighter. |
| `top-battle-arena-lite` | Spin Street-style dome clash. |
| `creature-battle-lite` | TamerNet-style creature battle. |
| `survival-lite` | Prismwilds/Wildlands-style large showcase starter. |

## Next creator features

1. Save generated manifests to a local file.
2. Let Pixel Forge import/validate selected sprite sheets.
3. Add thumbnail generation handoff.
4. Add local preview for simple arcade templates.
5. Add safe zip export.
6. Add user-created game folders only after manifests validate.
