# Native Prismcade Polish Handoff

This document is intentionally small and records what the native launch polish pass completed plus what remains.

## Current repo-side findings

The native Prismcade app exists at `apps/prismcade-native/` and currently ships three native game entries:

- `Flappy Pixel`
- `Prismtek Dino Dash`
- `Beat Em Up Buck`

The launch polish pass completed:

1. Flappy Pixel bird direction, flight feel, pipes, backgrounds, collision, and runtime receipt.
2. Dino Dash scale/facing/stage/obstacles for `doux`, `mort`, `tard`, and `vita`.
3. Beat Em Up Buck as a native SpriteKit micro-brawler inspired by lane brawlers and MUGEN/OpenBOR-style frame data concepts.

## Work I can do from GitHub

Repo-side-only work can safely prepare future improvements:

- catalog docs,
- game identity cleanup,
- hub copy cleanup,
- TODO/removal notes for symbolic previews,
- duplicate/replacement mapping,
- PR review checklists.

## Work that still needs local Codex/runtime

Local Codex is still needed for future runtime-heavy changes:

- deep asset search in `~/Downloads`, `~/Documents`, `~/Documents/LibreSprite`, and local repo clones,
- LibreSprite/plugin inspection and slicing,
- XcodeGen regeneration,
- macOS/iOS builds,
- runtime verification,
- live input/physics testing,
- app-side snapshots if the closed Mac/Amphetamine setup returns black desktop screenshots.

## Do not call done until

- Flappy Pixel receipts continue to prove real bird frames, correct facing, visible flap, upward input, gravity, scoring, collision, restart, and coherent pixel background/obstacles.
- Dino Dash receipts continue to prove real `doux`, `mort`, `tard`, and `vita` sprites at consistent gameplay scale, with working character select, jump, scoring, collision, and restart.
- Beat Em Up Buck receipts continue to prove Buck as a real sprite, at least one enemy, movement, attack, hitboxes/hurtboxes, damage, knockback, health, score/KO counter, game-over, restart, and a coherent pixel stage.
