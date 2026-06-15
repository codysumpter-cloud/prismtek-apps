# Pixel Fruit Arena DS Homebrew

This folder contains a Nintendo DS homebrew source layout for a compact DS version of Pixel Fruit Arena.

It targets devkitPro/libnds and produces a `.nds` file when built in a devkitPro NDS shell. The repository records the source receipt only; the binary is not committed.

## Build

1. Install devkitPro with the Nintendo DS toolchain.
2. Open a devkitPro shell in this folder.
3. Run `make`.
4. Copy `pixel_fruit_arena_ds.nds` to your normal DS homebrew loader or emulator.

## Controls

- D-pad: move Prism fighter
- A: close-range fruit move
- B: fruit dash
- X: awaken when the meter is ready
- Start: restart the round

## Scope

The DS version is intentionally smaller than the web game: it keeps stocks, knockback, ring-outs, meter, and fruit-flavored actions while using simple framebuffer shapes instead of the browser sprite/VFX pipeline.
