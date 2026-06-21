# Native Prismcade Polish TODO

This TODO tracks what remains after the native launch polish pass. It should not be treated as a replacement for runtime receipts.

## Game identity cleanup

- `Beat Em Up Buck` is the canonical Buck Borris game direction.
- The Buck Borris jump/dodge prototype has been replaced by the native SpriteKit Beat Em Up Buck brawler.
- Keep `Flappy Pixel` and `Prismtek Dino Dash` as canonical launch names.

## Hub preview cleanup

The hub preview cards should eventually use real game/sprite previews instead of Canvas-drawn symbolic previews. Replace them with either:

- real app-side runtime snapshots,
- real sprite-backed preview composites,
- or curated static card art produced from the actual game assets.

## Runtime gates

The launch polish pass produced runtime receipts for:

- Flappy flight/input/gravity/scoring/collision/restart,
- Dino select/jump/run/collision/restart,
- Buck brawler movement/attack/hit/KO/restart.

Remaining polish items:

- add audio,
- add richer Beat Em Up Buck enemy/move data,
- replace symbolic hub cards with sprite-backed preview art,
- wire native scores into Prismcade catalog/score services when ready.

## 2026-06-21 follow-up (Claude/Buddy review of PR #205)

Landed in the follow-up commit (builds + app-side runtime snapshots verified):

- Flappy: removed the black `skylineBlocks` ("large black squares" gone).
- Flappy: onocentaur birds now sample column 3 (right-facing) instead of column 0
  (left-facing); they were facing against the direction of travel.
- Dino: added opaque `groundFill` (no more hills-cloud artifacts under the floor) and
  removed the placeholder `ridgeBlocks`.

Open Codex items (details + exact asset paths in
`docs/prismcade/NATIVE_POLISH_FINDINGS_2026-06-21.md`):

- Flappy: fix the far-right parallax background gap; consider trimming the 50-bird roster
  (select grid overflows); onocentaur birds are static (pack has angles, no flap frames);
  map real species names from `Birds by Onocentaur/reference.png`.
- Buck: replace the sky-only `RTB_v1` plate with a real desert/street stage
  (`BG_DesertMountains/`), tile a real floor (`Starter Tiles Platformer/`), swap the
  procedural Training Bruiser for `Enemy_Animations_Set/` (skeleton2 or vampire — full
  idle/walk/attack/hurt/death), clean the `attacks_80x32` frames (the "black bar" on
  attack), and use `Free Pixel Effects Pack/10_weaponhit` for hit sparks.
- Confirm/clear license provenance for `Weather Effects Assets Pack Pixel Art` (CraftPix),
  `BG_DesertMountains`, and `dinoCharactersVersion1` before committing curated frames.
- Make the autoverify cycle an onocentaur bird and assert measured facing (current receipts
  hard-code `birdFacesRight`/`backgroundImagesUsed` and only test a garden bird).
- Catalog parity: add Dino Dash + Beat Em Up Buck to `data/prismcade/game-manifests.json`;
  resolve `prismcade-fighter` to Beat Em Up Buck identity. See `game-catalog-parity.md`.
