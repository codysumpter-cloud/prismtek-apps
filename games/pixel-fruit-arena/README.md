# Pixel Fruit Arena

Original Prismtek pixel-art platform fighting MVP.

Players create a custom 64x64-style pixel brawler, equip one modular Mystic Fruit, and fight in local multiplayer on an original arena stage. Character identity, fruit equipment, progression, combat, input, stages, and UI are intentionally separated so the game can grow into controller-friendly handheld/Steam Deck play and future online modes.

## Run

```bash
cd games/pixel-fruit-arena
npm install
npm run dev
```

Open the local Vite URL. The game also supports a dependency-light static build:

```bash
npm run build
npm run validate
```

## Controls

Player 1 keyboard:

- Move: `A` / `D`
- Jump / double jump: `W`
- Attack: `J`
- Special 1 / 2 / 3: `K` / `L` / `;`
- Dodge: left `Shift`
- Awaken: `I`

Player 2 keyboard:

- Move: arrow left / right
- Jump: arrow up
- Attack: numpad `1`
- Special 1 / 2 / 3: numpad `2` / `3` / `4`
- Dodge: numpad `0`
- Awaken: numpad `5`

Controller support polls browser Gamepad API:

- Left stick: move
- Face buttons: jump / attack / specials
- Shoulder: dodge
- Trigger: awakening

Unfilled local slots become CPU placeholders.

## Character Creator

The creator edits:

- name
- hair style
- hair color
- skin tone
- outfit colors
- accessory color

Character identity is stored in `data/characters/default-profile.json` and remains separate from equipped fruit power.

## Fruit System

Fruits are modular equipment in `data/fruits/core-fruits.json` and runtime helpers live under `src/fruits/`.

Playable fruits:

- Flame Fruit — Fireball, Flame Dash, Burning Uppercut; Awakening: Inferno Mode
- Frost Fruit — Ice Spike, Freeze Field, Ice Slide; Awakening: Frozen Domain
- Volt Fruit — Lightning Bolt, Blink Dash, Chain Shock; Awakening: Thunderstorm
- Shadow Fruit — Pull Field, Shadow Burst, Null Zone; Awakening: Abyss Form
- Rubber Fruit — Stretch Punch, Bounce Jump, Giant Fist; Awakening: Freedom Form
- Gravity Fruit — Pull, Slam, Float Strike; Awakening: Singularity Mode

Mastery persists per fruit on the profile map. Switching fruits never resets mastery.

## Awakening System

Each fighter has an awakening meter. It gains from:

- damage dealt
- damage taken
- survival time

At 100 meter, activate Awakening for a temporary boost and fruit-colored visual effect. The MVP currently applies boost modifiers and visual state; future work should add bespoke transformations per fruit.

## Combat System

Implemented basics:

- platform movement
- jumping and double jump
- basic attack
- three fruit specials
- hit stun
- knockback scaling by damage percentage
- ring outs
- respawn
- stock count
- CPU placeholders

This is a platform fighter model, not a traditional health-bar fighter.

## Stage System

Stage data lives in `data/stages/sky-ruins-arena.json`.

Current stage:

- Sky Ruins Arena
- multiple platforms
- 4 spawn points
- ring-out zones
- simple wind-rune hazard
- original environment concept

## Asset Pipeline

Reference GIF tools are dev-only:

```bash
python3 tools/extract_gif_frames.py "/path/to/reference.gif" --out assets/reference/onepiece-test
python3 tools/generate_animation_manifest.py
python3 tools/validate_sprites.py
```

Reference output belongs only in `assets/reference/onepiece-test/` and is guarded by `README_REFERENCE_ASSETS.md`.

`USE_REFERENCE_TEST_ASSETS=true` may be used for local development only.

Release builds force:

```bash
USE_REFERENCE_TEST_ASSETS=false
```

The build script validates that reference extraction outputs are not included when building production artifacts.

## Add a Fruit

1. Add the fruit to `data/fruits/core-fruits.json`.
2. Define exactly three abilities and one awakening name.
3. Add or tune behavior in `src/combat/combatState.js` by ability `type`.
4. Add icon/art under `assets/fruits/` when original art exists.
5. Update tests if the schema changes.

## Add a Stage

1. Add a JSON file under `data/stages/`.
2. Include `size`, `ringOut`, 4 `spawns`, `platforms`, and optional `hazards`.
3. Register it in `src/stages/stageRegistry.js` when multi-stage selection lands.
4. Add original pixel art under `assets/stages/`.

## Add Cosmetics

1. Extend `appearance` in `data/characters/default-profile.json`.
2. Add UI inputs in `src/systems/game.js` creator screen.
3. Render the cosmetic in `src/ui/render.js`.
4. Keep cosmetics independent from fruit equipment.

## Add Animations

1. Update `data/characters/prismtek-placeholder.animations.json`.
2. Use `tools/generate_animation_manifest.py` for a skeleton.
3. Add original frames under `assets/characters/`.
4. Keep sprite dimensions 64x64 for MVP compatibility.

## Architecture

```txt
assets/      original and dev-only reference asset folders
data/        fruit, stage, character, and animation definitions
src/combat/  match state, physics, attacks, knockback, respawn
src/fruits/  fruit registry and progression helpers
src/stages/  stage loading and collision helpers
src/ui/      canvas renderer and CSS
src/systems/ app orchestration and screen flow
src/multiplayer/ keyboard/controller input
```

## Current Limitations

- Original shipped character is a simple generated placeholder, not final production art.
- Online play is not implemented yet, but state/input boundaries are shaped for it.
- Controller support depends on browser Gamepad API support.
- Fruit awakenings share generic boost behavior in MVP.
- CPU is a placeholder behavior loop, not a real fighting AI.
- Static build copies files and validates data; asset packing can be upgraded later.
