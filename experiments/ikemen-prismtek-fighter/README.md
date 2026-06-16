# Ikemen GO Prismtek Fighter Spike

This experiment evaluates Ikemen GO as a traditional 2D fighter path for Prismtek-owned characters and stages.

## Goal

Decide whether Ikemen GO is useful for a Pixel Fruit Arena side mode, standalone Prismtek fighter, or Android/Linux handheld fighter prototype.

## Reference import

Use the registry helper from the repo root:

```bash
node tools/reference-games/import-reference-game.mjs ikemen-go
```

The checkout remains local under `.external/reference-games/ikemen-go/`.

## Content boundary

Use original Prismtek characters, stages, UI, audio, and effects only. MUGEN-format content is not assumed safe just because the engine can load it.

## Test scope

- one original Prismtek fighter
- one simple stage
- one basic move set
- one special move
- one super/finisher concept
- keyboard/controller mapping notes
- Android/RGDS build notes
- Linux/RGDS build notes

## Questions to answer

- Is authoring faster than the current Pixel Fruit Arena workflow?
- Is it too traditional-fighter-shaped for PFA's platform-fighter goals?
- Is Android output practical enough for RGDS mode?
- Is Linux output practical enough for handheld mode?

## Decision

Outcome must be one of:

- adopt Ikemen GO for a Prismtek fighter prototype
- keep as reference for data formats and tooling
- reject for current Prismtek priorities
