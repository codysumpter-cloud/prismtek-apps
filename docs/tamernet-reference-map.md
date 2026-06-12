# TamerNet Source Reference Map

This document maps the external projects worth studying for TamerNet. The goal is to borrow architecture and product lessons, not to import copyrighted assets or accidentally pull incompatible licensing into Prismtek apps.

## Reference priority

| Priority | Reference | Use for | Copy code? |
| --- | --- | --- | --- |
| 1 | smogon/pokemon-showdown | simulator architecture, protocol, replay logs, team validation, data-driven moves | Only if MIT attribution is preserved |
| 2 | PokeAPI/pokeapi | normalized data/API design, resource taxonomy, REST/GraphQL/data-import patterns | Be cautious; preserve license/attribution |
| 3 | pagefaultgames/pokerogue | roguelite progression, biome waves, endless runs, stacking item economy, boss pacing | Do not import code/assets unless AGPL/CC obligations are intentionally accepted |
| 4 | maierfelix/PokeMMO | browser engine/editor/map/collision inspiration | Avoid direct copy unless license compatibility is reviewed |
| 5 | aaron5670/PokeMMO-Online-Realtime-Multiplayer-Game | Phaser + Colyseus realtime multiplayer prototype patterns | Possible for networking ideas, avoid assets |
| 6 | Fiereu/OpenMMO | PokeMMO-like server organization and private-server warning surface | Do not import unless willing to satisfy AGPL obligations |
| 7 | pret/pokefirered, pret/pokeemerald, pret/pokeheartgold, pret/pokecrystal | game behavior, data layout, map/event/movement reference, ROM-hash/BYO-file validation concepts | Do not copy into Prismtek default code/content |
| 8 | LibHunt topic indexes | discovery of adjacent engines/tools/repos | Use only as a discovery index; verify every repo directly |

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

## PokéRogue

### Use for

- Roguelite run structure.
- Endless battle pacing.
- Biome progression.
- Boss/mini-boss cadence.
- Stacking items and temporary run power.
- Meta-progression ideas.
- Event variety without requiring a full region map first.

### TamerNet adaptation

PokéRogue suggests a strong early game mode for TamerNet before building a full MMO region:

```text
TamerNet Alpha Gauntlet
  enter instanced run
  clear overworld combat waves
  choose creature/item rewards
  hit biome breaks
  fight alpha bosses
  extract rewards to persistent account
  feed marketplace/breeding economy later
```

This can test battle balance, encounter pacing, rewards, alpha mechanics, and item synergies without needing the entire MMO world finished.

### License boundary

PokéRogue marks project source as AGPL-v3.0-only and docs/assets mostly as CC-BY-NC-SA-4.0/REUSE-managed. Do not import code or assets into Prismtek apps unless the project intentionally accepts those obligations.

## maierfelix/PokeMMO

### Use for

- Browser engine organization.
- Editor mode concepts.
- Map/collision/minimap patterns.
- Canvas/WebGL split ideas.
- Scripting and tool structure.

### Do not use for

- Treating it as official PokeMMO source.
- Copying assets.
- Copying code before license compatibility is reviewed.

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

## LibHunt topic indexes

### Use for

- Finding adjacent repos.
- Discovering old engines, battle bots, data tools, fan engines, and emulation/research projects.
- Prioritizing what to inspect next.

### Do not use for

- Licensing decisions.
- Architecture decisions without reading the upstream repo.
- Copying code by popularity ranking.

Every LibHunt candidate must be rechecked directly on GitHub for:

```text
license
activity
assets
server/client split
build health
security posture
whether it ships copyrighted content
```

## TamerNet architecture synthesis

The best path is not cloning any one project. It is combining the lessons:

```text
Showdown:
  battle-core architecture, protocol, replay, validation

PokeAPI:
  normalized data service shape

PokéRogue:
  roguelite run loop, biome/wave pacing, stacking rewards, boss cadence

pret:
  reference behavior and BYO-file validation concepts

maierfelix/PokeMMO:
  browser engine/editor/map inspiration

aaron5670 realtime prototype:
  simple multiplayer room/map flow

OpenMMO:
  private-server/server-boundary lessons, but no direct dependency

LibHunt:
  discovery index only
```

## Recommended game-mode roadmap

1. Keep `games/tamernet-battle-sandbox` as a playable toy.
2. Create `packages/tamernet-battle-core`.
3. Move commands, entities, hitboxes, cooldowns, and replay events into that package.
4. Add deterministic simulation tests.
5. Add a small server-authoritative duel service.
6. Add `Alpha Gauntlet`, a PokéRogue-inspired original roguelite combat mode for fast balance testing.
7. Add normalized creature/move/item schemas inspired by Showdown/PokeAPI patterns, with original Prismtek content.
8. Add map/event data only after combat and gauntlet pacing feel good.
9. Add marketplace, breeding, and legendary custody after persistence is stable.

## Hard rules

- No ROMs.
- No ripped sprites.
- No copied audio.
- No imported Pokémon/Nintendo/TPC text or maps in default Prismtek content.
- No direct AGPL server/client imports without an explicit licensing decision.
- Attribute MIT/BSD/permissive code if copied or adapted.
- Prefer architecture notes over source import.
