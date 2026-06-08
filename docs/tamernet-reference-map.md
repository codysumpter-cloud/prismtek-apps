# TamerNet Source Reference Map

This document maps the external projects worth studying for TamerNet. The goal is to borrow architecture and product lessons, not to import copyrighted assets or accidentally pull incompatible licensing into Prismtek apps.

## Reference priority

| Priority | Reference | Use for | Copy code? |
| --- | --- | --- | --- |
| 1 | smogon/pokemon-showdown | simulator architecture, protocol, replay logs, team validation, data-driven moves | Only if MIT attribution is preserved |
| 2 | PokeAPI/pokeapi | normalized data/API design, resource taxonomy, REST/GraphQL/data-import patterns | Be cautious; preserve license/attribution |
| 3 | maierfelix/PokeMMO | browser engine/editor/map/collision inspiration | Avoid direct copy unless license compatibility is reviewed |
| 4 | aaron5670/PokeMMO-Online-Realtime-Multiplayer-Game | Phaser + Colyseus realtime multiplayer prototype patterns | Possible for networking ideas, avoid assets |
| 5 | Fiereu/OpenMMO | PokeMMO-like server organization and private-server warning surface | Do not import unless willing to satisfy AGPL obligations |
| 6 | pret/pokefirered, pret/pokeemerald, pret/pokeheartgold, pret/pokecrystal | game behavior, data layout, map/event/movement reference, ROM-hash/BYO-file validation concepts | Do not copy into Prismtek default code/content |

## pret projects

### Repos

- `pret/pokefirered`
- `pret/pokeemerald`
- `pret/pokeheartgold`
- `pret/pokecrystal`

### Use for

- Understanding classic map/event data organization.
- Understanding overworld interaction patterns.
- Understanding encounter tables, map scripts, movement constraints, NPC event loops, and save-model concepts.
- BYO-file validation patterns using known hashes as a conceptual reference.
- Historical behavior parity notes.

### Do not use for

- Copying copyrighted game content.
- Shipping ROM-building workflows.
- Importing decomp/disassembly source into Prismtek app code.
- Shipping maps, text, sprites, audio, region names, trainer data, or Pokémon-specific content.

## PokeAPI

### Use for

- API/data taxonomy.
- REST resource modeling.
- GraphQL possibilities.
- Data import pipeline shape.
- Stable IDs and normalized reference tables.

### TamerNet adaptation

Create our own original data service later:

```text
services/tamernet-data-api/
  creatures
  moves
  items
  abilities
  regions
  encounters
  forms
  variants
```

Keep Prismtek default content original.

## Pokemon Showdown

See `docs/tamernet-showdown-reference.md` for full details.

Best lessons:

- simulator separate from server and client
- command/event streams
- battle replay logs
- public/private event views
- team formats: human export, JSON, packed
- Dex-style lookup
- team validation outside UI

## aaron5670/PokeMMO-Online-Realtime-Multiplayer-Game

### Use for

- Simple Phaser 3 client/server split.
- Colyseus realtime room concept.
- Tiled map workflow.
- Multiple players on multiple maps.

### Do not overvalue

The README marks Pokémon themselves as not added, so this is primarily a realtime multiplayer movement/map prototype, not a full MMO or battle engine.

## OpenMMO

### Use for

- High-level private-server architecture research.
- Understanding how PokeMMO-like server alternatives think about service boundaries.
- Reviewing documentation language around ToS/private-server risk.

### License boundary

OpenMMO is AGPL-licensed. Do not import code into Prismtek apps unless the project intentionally accepts AGPL network-service obligations.

## TamerNet architecture synthesis

The best path is not cloning any one project. It is combining the lessons:

```text
Showdown:
  battle-core architecture, protocol, replay, validation

PokeAPI:
  normalized data service shape

pret:
  reference behavior and BYO-file validation concepts

maierfelix/PokeMMO:
  browser engine/editor/map inspiration

aaron5670 realtime prototype:
  simple multiplayer room/map flow

OpenMMO:
  private-server/server-boundary lessons, but no direct dependency
```

## Next implementation plan

1. Keep the current `apps/tamernet-battle-sandbox` as a playable toy.
2. Create `packages/tamernet-battle-core`.
3. Move commands, entities, hitboxes, cooldowns, and replay events into that package.
4. Add deterministic simulation tests.
5. Add a small server-authoritative duel service.
6. Add map/event data only after combat feels good.
7. Add normalized creature/move/item schemas inspired by Showdown/PokeAPI patterns, with original Prismtek content.

## Hard rules

- No ROMs.
- No ripped sprites.
- No copied audio.
- No imported Pokémon/Nintendo/TPC text or maps in default Prismtek content.
- No direct AGPL server imports without an explicit licensing decision.
- Attribute MIT/BSD/permissive code if copied or adapted.
- Prefer architecture notes over source import.
