# TamerNet Reference: Pokemon Showdown

## Why this matters

Pokemon Showdown is the best public reference for competitive battle infrastructure:

- simulator/server separation
- battle protocol design
- replayable battle logs
- team validation
- battle formats/rulesets
- data-driven move/species/item/ability lookup
- command-line simulator usage
- server/client/login-server separation

This is a technical reference only. TamerNet's combat direction remains real-time overworld command combat, not a turn-based clone.

## Licensing note

The `smogon/pokemon-showdown` server repository is MIT licensed. If TamerNet copies or adapts meaningful code, keep the MIT copyright notice and attribution.

Do not copy Pokemon names, sprites, audio, or franchise presentation into Prismtek-owned default content.

## Useful source references

- `README.md`: documents Showdown as a website, JavaScript battle simulator library, command-line simulator, web API, and game server.
- `ARCHITECTURE.md`: splits the system into game server, client, and login server.
- `sim/README.md`: documents the Node package surface for simulation, teams, and Dex data.
- `sim/SIMULATOR.md`: documents stream-based simulator inputs and outputs.
- `sim/SIM-PROTOCOL.md`: documents battle messages, request/update handling, split public/private messages, and replay-style logs.
- `sim/TEAMS.md`: documents human export format, JSON team format, packed format, random team generation, and validation.
- `sim/DEX.md`: documents move/species/item/ability/nature/stat lookup.
- `data/moves.ts`: shows data-driven move records with base power, category, flags, target, secondary effects, callbacks, and type.

## What to borrow architecturally

### 1. Split battle simulation from app UI

TamerNet should not bury combat rules inside the browser sandbox. The next step should be:

```text
packages/tamernet-battle-core/
  src/entities.ts
  src/moves.ts
  src/commands.ts
  src/collision.ts
  src/simulation.ts
  src/protocol.ts
  src/replay.ts
```

The browser sandbox should become only a renderer/input shell.

### 2. Use command/event streams

Showdown's simulator model is useful because it writes player choices and reads simulator protocol messages.

TamerNet equivalent:

```text
client command stream:
  move_input
  dodge
  command_move
  swap_creature
  recall
  capture_attempt

server event stream:
  entity_spawned
  movement_accepted
  move_started
  hitbox_created
  damage_applied
  status_applied
  cooldown_started
  creature_swapped
  capture_resolved
  battle_ended
```

This gives us replay logs, audit trails, server debugging, tournament review, and deterministic test fixtures.

### 3. Separate private and public battle views

Showdown distinguishes player-specific/private messages from public spectator-safe messages. TamerNet needs the same boundary:

```text
private player view:
  exact cooldowns
  exact hidden stats where allowed
  capture odds if design allows
  inventory/party state

public/spectator view:
  visible movement
  visible attacks
  approximate HP if rules require
  public statuses
  raid contribution bands, not exact hidden rolls
```

### 4. Treat teams/parties as first-class validated data

Showdown's team formats point to a useful TamerNet split:

```text
human export:
  readable creature build import/export

JSON format:
  canonical app/server data

packed format:
  compact storage, share codes, replay logs, market listings
```

TamerNet party validation should eventually live outside UI code:

```text
validate party size
validate active move slots
validate cooldown metadata
validate PvP ruleset legality
validate held item rules
validate legendary custody restrictions
validate alpha/raid-only flags
```

### 5. Keep Dex-style data lookup separate

Showdown's Dex pattern is the right mental model, but TamerNet should use original data tables:

```text
BattleDex.moves.get(id)
BattleDex.creatures.get(id)
BattleDex.items.get(id)
BattleDex.abilities.get(id)
BattleDex.formats.get(id)
```

Avoid loading game content directly from UI components.

## What not to borrow directly

- Turn-based action queue as the primary gameplay loop.
- Pokemon franchise assets or branding.
- Exact competitive formats as product identity.
- Browser-era client architecture where a cleaner modern stack is available.

## Real-time adaptation

Showdown action:

```text
>p1 move 1
```

TamerNet action:

```json
{
  "type": "command_move",
  "playerId": "p1",
  "creatureId": "p1.active",
  "slot": 1,
  "aim": {"x": 702, "y": 318},
  "clientTick": 88341
}
```

Showdown battle event:

```text
|-damage|p2a: Target|75/100
```

TamerNet battle event:

```json
{
  "type": "damage_applied",
  "sourceEntityId": "p1.active",
  "targetEntityId": "p2.active",
  "amount": 24,
  "hpAfter": 76,
  "serverTick": 88345
}
```

## Recommended next PR

Build `packages/tamernet-battle-core` with:

1. `BattleCommand` types.
2. `BattleEvent` types.
3. `BattleState` and entity models.
4. Deterministic fixed-step simulation.
5. Hitbox/collision helpers.
6. Replay log serialization.
7. A tiny test fixture that feeds command events and verifies damage/cooldowns.
8. Browser sandbox adapter consuming the shared simulation.

## Product boundary

Use Showdown for simulator architecture lessons. Use TamerNet for the actual product identity:

> Real-time creature-command MMO combat with PvP outplay, alpha raids, persistent progression, marketplace loops, and original Prismtek default content.
