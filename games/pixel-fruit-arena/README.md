# Pixel Fruit Arena

Pixel Fruit Arena is a Prismtek platform-fighting MVP. Players create an original fighter, equip modular fruit powers, and battle locally with stocks, knockback, ring-outs, and awakening meters.

## Run

Open `index.html` in a browser, or serve the folder with any static server.

```bash
npm test
npm run build
python tools/validate_sprites.py assets/characters/prismtek_placeholder_character.json
```

Windows fallback when Node or Python are not on PATH:

```powershell
powershell -ExecutionPolicy Bypass -File games/pixel-fruit-arena/tools/test.ps1
powershell -ExecutionPolicy Bypass -File games/pixel-fruit-arena/tools/validate_sprites.ps1 games/pixel-fruit-arena/assets/characters/prismtek_placeholder_character.json
powershell -ExecutionPolicy Bypass -File games/pixel-fruit-arena/tools/build.ps1
```

## Controls

P1 keyboard: arrows to move and jump, `/` attack, `.` special 1, `,` special 2, right Shift dodge, Enter awaken.

P2 keyboard: WASD to move and jump, F/G/H abilities, left Shift dodge, T awaken.

Controllers: left stick move, face buttons jump and abilities, shoulder dodge and awaken, start menu.

## Character Creator

Character identity is independent from fruit powers. Profiles persist locally as:

```json
{
  "name": "",
  "appearance": {},
  "owned_fruits": [],
  "equipped_fruit": ""
}
```

Players can edit name, hair color, skin tone, outfit colors, and accessory colors.

## Fruit System

Fruits are equipment modules in `src/fruits`. The MVP includes Flame, Frost, Volt, Shadow, Rubber, and Gravity. Each fruit has three abilities and a unique awakening mode. Switching fruits does not reset mastery.

## Combat And Awakening

Combat uses stock count, damage-scaled knockback, hit stun, double jumps, dodges, respawns, and ring-outs. Awakening meter gains from survival, damage dealt, and damage taken. Activating awakening grants temporary speed, cooldown, and power boosts with fruit-colored effects.

## Multiplayer

Match setup supports 2, 3, or 4 players. Local keyboard and controller input share the same action model so online play can later feed the same input stream.

## Asset Pipeline

Reference GIF tooling lives in `tools/`:

```bash
python tools/extract_gif_frames.py path/to/reference.gif --out assets/reference/onepiece-test --animation walk
python tools/generate_animation_manifest.py assets/reference/onepiece-test/walk --animation walk --fps 12 --loop
python tools/validate_sprites.py assets/characters/prismtek_placeholder_character.json
```

Reference assets are development-only. `USE_REFERENCE_TEST_ASSETS=true` is allowed for local testing only. Release builds force reference assets off by removing `assets/reference` from `dist`.

## Adding Fruits

Add a fruit definition to `src/fruits/fruits.js` and mirror static metadata in `data/fruits/fruits.json`. Fruit abilities should remain data-driven and use the shared combat kinds before adding custom systems.

## Adding Stages

Add a stage module in `src/stages`, then add data under `data/stages`. A stage needs platforms, ring-out bounds, and at least four respawn points.

## Adding Cosmetics And Animations

Cosmetics belong to character appearance data and should not affect fruit ownership. Add animation manifests under `assets/characters` with 64x64 frames, origin, hurtbox, and hitbox metadata. Validate with `tools/validate_sprites.py`.
