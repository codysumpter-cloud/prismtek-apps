# Nintendo DS Port Plan

The browser arcade workspace cannot run directly on Nintendo DS. DS support requires separate homebrew ports that target `.nds` output.

## User-supplied references

- YouTube guide: https://youtu.be/LYeYQ9lYP_M?is=CPxiPLgGppiE4wIJ
- Archive entry: https://archive.org/details/Install520
- Setup repo: https://github.com/DigitalDesignDude/DS-Game-Maker-5-Setup

## Rules

- Do not vendor unknown installer binaries into this repo.
- Do not ship proprietary Nintendo SDK files.
- Keep DS ports source-first and reproducible.
- Mark a game as DS-supported only after a `.nds` artifact builds.

## Port order

1. Pixel Stacker
2. Flappy Pixel
3. Neon Brick Breaker
4. Crossy Pixel
5. Pixel Snake local mode

## Planned layout

```text
ports/nds/
  pixel-stacker/
  flappy-pixel/
  neon-brick-breaker/
  crossy-pixel/
  pixel-snake/
```
