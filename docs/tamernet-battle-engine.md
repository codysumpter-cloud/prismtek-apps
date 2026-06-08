# TamerNet Battle Engine Direction

## Product thesis

The differentiated product is not a turn-based clone. It is a battle-first creature MMO:

- PokeMMO-style persistence, trading, breeding pressure, marketplace loops, and server economy.
- Real-time overworld creature-command combat.
- PvP outplay through timing, spacing, cooldown tracking, dodge, guard, swaps, and terrain.
- PvE alpha battles as large-scale group events.
- Legendary handling through temporary custody and event rewards rather than permanent economy-breaking ownership.

## Current sandbox

`apps/tamernet-battle-sandbox` is the first local prototype. It is intentionally tiny and browser-native so the combat toy can be tested before building MMO infrastructure.

## Public reference: maierfelix/PokeMMO

The public `maierfelix/PokeMMO` project is useful as a technical reference for a browser-based Pokémon-style engine, but it should not be treated as official PokeMMO source. The useful categories to study are:

- browser rendering loop
- map/collision structure
- editor concepts
- minimap patterns
- server folder structure
- project organization

Do not copy copyrighted assets or depend on that project as the canonical implementation. Borrow architecture ideas only where licensing and attribution allow it.

## Combat model

Trainer is directly controlled. The active creature follows and executes commands.

Core commands:

- move trainer
- dodge
- command move slot 1-4
- swap active creature
- guard/recall
- capture wild target

Production moves should use this lifecycle:

```text
input -> windup -> active frames -> recovery -> cooldown
```

## PvP principles

No move should be simultaneously:

- fast
- safe
- high damage
- low cooldown
- hard crowd control
- large AoE

Strong moves need visible telegraphs and punish windows.

## PvE alpha principles

Alpha creatures should be public or instanced MMO events with:

- telegraphed AoE
- charge lines
- phase changes
- contribution tracking
- support/healing/shield contribution
- loot and capture eligibility gates
- anti-leech checks

## Server-authority requirement

The local sandbox is not authoritative. Production must move these decisions server-side:

- movement validity
- cooldown validity
- hit results
- damage
- capture success
- rewards
- inventory changes
- trade and market mutations

## Recommended next PR

Create a shared battle package:

```text
packages/tamernet-battle-core/
  src/entities.ts
  src/moves.ts
  src/simulation.ts
  src/collision.ts
  src/commands.ts
  src/replay.ts
```

Then make the browser sandbox consume that package instead of owning all simulation logic inline.
