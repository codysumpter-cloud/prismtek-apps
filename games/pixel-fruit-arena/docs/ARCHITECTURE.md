# Pixel Fruit Arena Architecture

Pixel Fruit Arena is built around clear seams:

- **Character identity** is profile data and cosmetics.
- **Fruit powers** are equipment and progression data.
- **Combat state** owns movement, hit stun, knockback, ring outs, stocks, and awakening.
- **Input** is normalized before combat sees it.
- **Stages** are data-defined and collision-friendly.
- **UI** renders state but does not own gameplay rules.

This keeps future online play feasible: send compact input snapshots and deterministic-ish match state updates rather than coupling gameplay to DOM events.

## Key Modules

- `src/systems/game.js` — screen flow, boot, high-level orchestration.
- `src/multiplayer/input.js` — keyboard and controller normalization.
- `src/combat/combatState.js` — match lifecycle, ability spawning, CPU placeholders, result detection.
- `src/combat/physics.js` — platform physics, knockback, ring-out, hazard integration.
- `src/fruits/fruitRegistry.js` — fruit loading and mastery helpers.
- `src/characters/characterCreator.js` — profile mutation helpers.
- `src/stages/stageRegistry.js` — stage loading and rectangle collision helpers.
- `src/ui/render.js` — pixel canvas rendering.

## Asset Safety

Reference GIFs are allowed only as local development inputs. Extracted files must stay under `assets/reference/onepiece-test/` and must not be committed except for the warning README.

Release builds force `USE_REFERENCE_TEST_ASSETS=false` and run validation before copying build files.
