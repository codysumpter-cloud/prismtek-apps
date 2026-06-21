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
