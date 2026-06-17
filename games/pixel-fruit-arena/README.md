# Pixel Fruit Arena

Pixel Fruit Arena is a Prismtek platform-fighting MVP. Players create an original fighter, equip modular fruit powers, and battle locally with stocks, knockback, ring-outs, and awakening meters.

Current honest label: **verified local web/browser MVP with a locally verified ZIP packaging path and DS source receipt; not yet a fully verified cross-platform downloadable game.**

## Quick Start

The game is plain HTML/JS/CSS with no install step. Because it uses ES modules, serve it over HTTP instead of relying on `file://` browser behavior.

From `games/pixel-fruit-arena/`:

```bash
npx serve -l 4173 .        # Node
python -m http.server 4173 # Python
```

Then open:

```text
http://localhost:4173
```

Use `Fight CPU` from the main menu for the fastest playable match. Local 2P, 3P, and 4P setup remains available from the same menu.

## Build the web version

From `games/pixel-fruit-arena/`:

```bash
npm test
npm run build
npm run validate:dist
```

What this proves:

- Runtime smoke tests pass in Node.
- `dist/` exists and includes the static web app shell.
- `dist/assets/reference` is not present.
- No `.gif` files leak into release output.

Manual QA steps live in [`docs/LOCAL_QA_CHECKLIST.md`](docs/LOCAL_QA_CHECKLIST.md).

## Create a downloadable ZIP

From `games/pixel-fruit-arena/`:

```bash
npm run package:zip
```

Expected local artifact path:

```text
artifacts/pixel-fruit-arena-web.zip
```

The ZIP contains the contents of `dist/` at the archive root, including `index.html`. The `artifacts/` folder is git-ignored; do not claim a public downloadable release exists until this ZIP is attached to a GitHub release, uploaded to itch.io, or otherwise published with a receipt.

## Nintendo DS source

A compact DS source layout lives in [`ds-homebrew/`](ds-homebrew/).

```bash
cd ds-homebrew
make
```

Expected local DS output:

```text
pixel_fruit_arena_ds.nds
```

CI validates the DS source receipt. The `.nds` output still needs a devkitPro/libnds build and device or emulator receipt.

## Platform readiness

Full details live in [`docs/PLATFORM_READINESS.md`](docs/PLATFORM_READINESS.md).

| Platform | Status | Evidence / gap |
| --- | --- | --- |
| Web browser | Verified | Local browser QA has passed for the web MVP; the game runs over HTTP, starts `Fight CPU`, accepts keyboard input, and renders fighters/stage/VFX. |
| Downloadable ZIP / itch.io | Partially verified | ZIP packaging flow is scripted and has a local artifact path; public upload/download verification is still required. |
| Windows | Partially verified | PowerShell helpers exist for test/build/serve, but no native Windows package or fresh Windows ZIP runtime receipt exists. |
| macOS | Unverified | No macOS runtime, package, or browser/device receipt exists. |
| Linux / Steam Deck | Unverified | No Linux/Steam Deck runtime, package, controller, or device receipt exists. |
| RGDS Android mode | Unverified | No Android WebView/browser-on-RGDS runtime receipt, APK, or RGDS Android control receipt exists. |
| RGDS Linux mode | Unverified | No RGDS Linux runtime, PortMaster-style package, or device receipt exists. |
| Nintendo DS | Partially verified | DS source layout exists and is statically validated; `.nds` build/device receipt is still required. |

## Controls

P1 keyboard: arrows to move and jump, `/` move, `.` special 1, `,` special 2, right Shift dodge, Enter awaken.

P2 keyboard: WASD to move and jump, F/G/H abilities, left Shift dodge, T awaken.

Controllers: left stick move, face buttons jump and abilities, shoulder dodge and awaken, start menu.

## Character Creator

Character identity is independent from fruit powers. Players can edit name, body sprite, hair style, combat style, hair color, skin tone, outfit colors, and accessory colors. Combat style is independent from fruit powers and currently supports Duelist, Brawler, Striker, Ranger, Guardian, and Trickster.

## Fruit System

Fruits are equipment modules in `src/fruits`. The MVP includes Flame, Frost, Volt, Shadow, Rubber, and Gravity. Each fruit has three abilities and a unique awakening mode. Switching fruits does not reset mastery.

## Combat And Awakening

Combat uses stock count, damage-scaled knockback, hit stun, double jumps, dodges, respawns, and ring-outs. Awakening meter gains from survival, damage dealt, and damage taken. Activating awakening grants temporary speed, cooldown, and power boosts with fruit-colored effects.

## Multiplayer

Match setup supports 2, 3, or 4 players. Local keyboard and controller input share the same action model so online play can later feed the same input stream.

## Asset Pipeline

Playable runtime art is loaded from locally available free pixel-art packs with credit/license notes under `assets/licenses`. Elemental VFX from user-provided packs live under `assets/effects/elemental-vfx` with a license verification note. Verify those pack licenses before public release. The shipped runtime does not use the One Piece reference GIFs.

Reference assets are development-only. `USE_REFERENCE_TEST_ASSETS=true` is allowed for local testing only. Release builds remove `assets/reference` from `dist` and fail if any `.gif` remains in the release artifact.

## Known Limitations

- Multiplayer is local-only; there is no online multiplayer yet.
- All character/stage art is placeholder pixel art, not final production art.
- Downloaded elemental VFX packs are wired for local playability; confirm their licenses before any public release.
- Controller support depends on the browser's Gamepad API; button numbering may vary by pad and browser.
- Combat balance is a first pass and intentionally rough.
- CPU opponents use simple placeholder behavior.
- Native Windows, macOS, Linux, Steam Deck, RGDS Android, and RGDS Linux packages are not implemented yet.
- Nintendo DS source exists, but the `.nds` output is not build-verified yet.
- itch.io/downloadable status is not verified until a real ZIP/release/upload receipt exists.

## Adding Fruits

Add a fruit definition to `src/fruits/fruits.js` and mirror static metadata in `data/fruits/fruits.json`. Fruit abilities should remain data-driven and use the shared combat kinds before adding custom systems.

## Adding Stages

Add a stage module in `src/stages`, then add data under `data/stages`. A stage needs platforms, ring-out bounds, and at least four respawn points.

## Adding Cosmetics And Animations

Cosmetics belong to character appearance data and should not affect fruit ownership. Add animation manifests under `assets/characters` with 64x64 frames, origin, hurtbox, and hitbox metadata. Validate with `tools/validate_sprites.py`.
