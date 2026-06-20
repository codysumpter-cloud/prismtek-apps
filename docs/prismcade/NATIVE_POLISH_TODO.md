# Native Prismcade Polish TODO

This TODO is for the next branch/PR. It should not be treated as proof that the games are polished.

## Game identity cleanup

- Rename `Buck Borris Mini-Game` to `Beat Em Up Buck` once the gameplay becomes a tiny fighter/brawler.
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
