# Prismcade Fighter

Clean-room Prismtek anime-pixel fighting game foundation.

This folder defines the original Prismcade Fighter content model, starter roster, starter stages, and validation path.

## Goals

- Fast anime-pixel combat.
- Launchers, air chains, assists, supers, and readable hit sparks.
- Original Prismtek characters only.
- Web, RGDS Android/Linux, and Windows ZIP targets.

## Content model

Each fighter is a JSON manifest with sprite metadata, movement stats, animation clips, moves, and hitboxes. Each stage is a JSON manifest with bounds, camera limits, parallax layers, and optional music slot.

## Validate

```bash
node tools/prismcade-fighter/validate-fighter-content.mjs
```
