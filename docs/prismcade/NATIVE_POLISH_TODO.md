# Native Prismcade Polish TODO

This TODO is for the next branch/PR. It should not be treated as proof that the games are polished.

## Game identity cleanup

- `Beat Em Up Buck` is the canonical Buck Borris game direction.
- The current merged runtime is still the earlier Buck Borris jump/dodge prototype until the next polish PR replaces it.
- Keep `Flappy Pixel` and `Prismtek Dino Dash` as canonical launch names.

## Hub preview cleanup

The current hub preview cards should not keep rectangle-only placeholder drawings. Replace them with either:

- real app-side runtime snapshots,
- real sprite-backed preview composites,
- or curated static card art produced from the actual game assets.

## Runtime gates

The next PR must include runtime receipts for:

- Flappy flight/input/gravity/scoring/collision/restart,
- Dino select/jump/run/collision/restart,
- Buck brawler movement/attack/hit/KO/restart.
