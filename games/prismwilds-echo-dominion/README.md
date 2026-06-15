# Prismwilds: Echo Dominion

A first playable Prismtek creature-survival PvP prototype: dense pixel ecosystem, dinosaur-inspired playable species, feeder animals, rare roaming NPC dinosaurs, stealth terrain, edible vegetation, watering holes, and diveable/hidable water.

This is an original Prismtek game direction inspired by open-world creature-survival games. It does **not** ship external franchise assets, copied lore, copied creature names, or reference/test assets.

## Run it

From this folder:

```bash
npm run dev
# then open http://localhost:8080
```

You can also open `index.html` directly in a browser.

## Validate and package

```bash
npm test
npm run package:zip
```

Expected local web artifact:

```text
artifacts/prismwilds-echo-dominion-web.zip
```

## What is playable now

- Top-down open ecosystem map with a central conflict magnet: **Heartwater Caldera**.
- Eight playable original dinosaur-inspired creatures.
- Hunger, thirst, stamina, health, growth, oxygen, stealth, scent/noise, and simple combat.
- Herbivore/omnivore vegetation: berries, ferns, aquatic plants, roots, cactus fruit, and rare blooms.
- Carnivore food: feeder animals, fish, and carcasses.
- Watering holes, streams, swamp pools, a deep central lake, and hidden water pockets.
- Dive/hide water mechanics for aquatic and semi-aquatic creatures.
- Feeder NPC animals that flee and refill the world.
- Rare roaming NPC dinosaurs when the simulated world is underpopulated.
- Stealth cover: reeds, tall grass, caves, ruins, trees, mud, and deep water.
- Asset manifest mapping repo-local dinosaur/creature/world packs to intended runtime use.
- Browser smoke test and static ZIP packager.

## Controls

| Action | Input |
| --- | --- |
| Move | WASD / Arrow keys |
| Sprint | Shift |
| Crouch / stealth posture | C |
| Eat nearby food / carcass / fish | F |
| Drink nearby water | Q |
| Dive / surface in valid water | E |
| Basic attack | Space / Mouse click |
| Species ability | 1 |
| Scent pulse | R |
| Cycle creature | Tab |
| Reset creature | Enter |
| Pause | P |

## Survival design

The world is intentionally resource-driven:

- Herbivores and omnivores are pulled toward berry groves, fern beds, aquatic plants, roots, cactus fruit, and rare blooms.
- Carnivores and omnivores hunt feeder animals, fish, carcasses, and weakened creatures.
- Everyone needs water, but the best water is dangerous.
- The central lake is clean, deep, diveable, and full of conflict routes.
- Underwater players can hide, but bubbles, oxygen, splashing, and large-body wake give them away.
- Tall cover helps small/medium creatures. Large creatures cannot fully hide in small cover.

## World zones

| Zone | Purpose |
| --- | --- |
| Hatchling Grove | Safer outer spawn, berries, bugs, shallow water, hiding logs. |
| Reedwater Flats | Swamp/reed stealth, fish/frogs, murky pools, scent masking. |
| Stoneback Caves | Dark tunnels, mushrooms, hidden water, ambush and den play. |
| Sunspine Ridge | Open rocky highland, cactus fruit, cliff nests, visibility. |
| Heartwater Caldera | Central PvP pull: clean lake, rare blooms, carcasses, mutation stones, roaming apex routes. |

## Asset plan

Runtime currently uses procedural pixel shapes as guaranteed fallbacks so the prototype always runs. `data/assets.json` maps approved Prismtek-apps asset candidates from `game-assets/` for the next extraction pass, including dinosaur character packs, monster creature packs, TinyRanch animal/crop/tile sheets, tree sheets, cave/swamp/world tilesets, jungle ruins, and water map data.

Before public release, each archive must be unpacked, normalized to the Prismwilds sprite spec, and license/attribution checked.

## Platform readiness

| Platform | Status | Evidence / gap |
| --- | --- | --- |
| Web browser | Partially verified | Static browser runtime and smoke test exist. Needs real browser run receipt. |
| Downloadable ZIP / itch.io | Partially verified | `npm run package:zip` creates a local ZIP path. Public upload receipt still required. |
| Windows | Unverified | Browser source exists; Windows runtime receipt required. |
| macOS | Unverified | Browser source exists; macOS runtime receipt required. |
| Linux / Steam Deck | Unverified | Browser source exists; Linux/Steam Deck runtime/controller receipt required. |
| RGDS Android mode | Unverified | Needs Android browser/WebView and touch/control receipt. |
| RGDS Linux mode | Unverified | Needs RGDS Linux browser/launcher receipt. |
| Server-authoritative PvP | Missing | Local PvP-style sandbox only; WebSocket authority belongs in follow-up PR. |

## Next implementation PRs

1. Extract approved dinosaur/world asset packs into `assets/runtime/`.
2. Add authoritative WebSocket server room with server-owned survival/combat state.
3. Add persistent creature slots, death lineage rewards, and den/nest ownership.
4. Add pathfinding and migration events for roaming dinosaur herds.
5. Add gamepad/touch HUD for RGDS and mobile modes.
