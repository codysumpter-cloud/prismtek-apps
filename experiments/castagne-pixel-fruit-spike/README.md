# Castagne Pixel Fruit Spike

This experiment evaluates Castagne as a future combat architecture option for Pixel Fruit Arena.

## Goal

Answer whether Castagne should influence or replace parts of Pixel Fruit Arena combat logic.

## Reference import

Use the registry helper from the repo root:

```bash
node tools/reference-games/import-reference-game.mjs castagne
```

The checkout remains local under `.external/reference-games/castagne/`.

## Test character

Use an original Pixel Fruit Arena test character and map only a tiny move kit:

- jab
- launcher
- directional special
- awakened special
- dodge or defensive option

## Questions to answer

- Is move authoring faster than the current browser combat code?
- Are hitboxes and hurtboxes easier to tune?
- Does the workflow support directional variants cleanly?
- Does it help future rollback/netcode plans?
- Can it coexist with the current web/PWA build?

## Decision

Outcome must be one of:

- adopt Castagne for a dedicated combat prototype
- borrow concepts only
- reject for Pixel Fruit Arena
