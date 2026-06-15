# TamerNet Battle Sandbox DS Homebrew

This folder contains a Nintendo DS homebrew source layout for a compact DS version of TamerNet Battle Sandbox.

It targets devkitPro/libnds and produces a `.nds` file when built in a devkitPro NDS shell. The repository records the source receipt only; the binary is not committed.

## Build

1. Install devkitPro with the Nintendo DS toolchain.
2. Open a devkitPro shell in this folder.
3. Run `make`.
4. Copy `tamernet_battle_sandbox_ds.nds` to your normal DS homebrew loader or emulator.

## Controls

- D-pad: move trainer
- A: command active companion move
- B: dodge
- X: capture when the wild creature is low
- R: toggle alpha encounter mode
- Start: restart

## Scope

The DS version keeps the core local loop: trainer movement, companion command, cooldown, wild creature HP, alpha mode, contribution score, and capture chance. It uses simple framebuffer shapes so the game stays small and portable before a sprite pass.
