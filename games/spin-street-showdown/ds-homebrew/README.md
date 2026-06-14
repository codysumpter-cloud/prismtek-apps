# Spin Street Showdown DS Homebrew

This folder contains a Nintendo DS homebrew source layout for a simplified version of the same game.

It is intended for devkitPro/libnds. I could not verify a `.nds` binary in this workspace because the DS toolchain is not installed here.

## Build

1. Install devkitPro with the NDS toolchain.
2. Open a devkitPro shell in this folder.
3. Run `make`.
4. Copy the produced `.nds` file to flashcart, TWiLight Menu++, or an emulator.

## Controls

- D-pad: steer
- A: charge burst
- L/R: choose shop slot
- X: buy/equip offered part
- Start: restart after win/loss

## Design Notes

The DS version uses simple 2D shapes and fixed-point friendly movement so it can be expanded into sprites later without changing the core loop.

It includes four slots with 64 generated parts each: Attack Ring, Weight Core, Driver Tip, and Spirit Chip. That gives the DS source a 256-part catalogue without storing bulky asset data.
