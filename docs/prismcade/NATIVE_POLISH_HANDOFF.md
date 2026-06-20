# Native Prismcade Polish Handoff

This document is intentionally small and exists to reduce local Codex burn for the next runtime-heavy polish pass.

## Current repo-side findings

The merged native Prismcade foundation exists at `apps/prismcade-native/` and currently ships three native game entries:

- `Flappy Pixel`
- `Prismtek Dino Dash`
- Buck Borris prototype, with `Beat Em Up Buck` as the canonical target direction

The next pass should polish these into launch-quality Prismcade entries, with special emphasis on:

1. replacing placeholder hub previews with real game/sprite previews,
2. polishing Flappy Pixel bird direction, flight feel, pipes, backgrounds, and collision feel,
3. polishing Dino Dash scale/facing/stage/obstacles for `doux`, `mort`, `tard`, and `vita`,
4. replacing the Buck Borris dodge/collector prototype with `Beat Em Up Buck`, a native SpriteKit micro-brawler inspired by lane brawlers and MUGEN/OpenBOR-style frame data.

## Work I can do from GitHub

Repo-side-only work can safely prepare:

- catalog docs,
- game identity cleanup,
- hub copy cleanup,
- TODO/removal notes for placeholder previews,
- duplicate/replacement mapping,
- PR review checklists.

## Work that still needs local Codex/runtime

Local Codex is still needed for:

- deep asset search in `~/Downloads`, `~/Documents`, `~/Documents/LibreSprite`, and local repo clones,
- LibreSprite/plugin inspection and slicing,
- XcodeGen regeneration,
- macOS/iOS builds,
- runtime verification,
- live input/physics testing,
- app-side snapshots if the closed Mac/Amphetamine setup returns black desktop screenshots.

## Do not call done until

- Flappy Pixel uses real bird frames, faces the correct direction, visibly flaps, flies upward on input, falls under gravity, scores, collides, restarts, and has coherent pixel background/obstacles.
- Dino Dash uses real `doux`, `mort`, `tard`, and `vita` sprites at consistent scale, with working character select, jump, scoring, collision, and restart.
- Beat Em Up Buck exists, with Buck as a real sprite, at least one enemy, movement, attack, hitboxes/hurtboxes, damage, knockback, health, score/KO counter, game-over, restart, and a coherent pixel stage.
