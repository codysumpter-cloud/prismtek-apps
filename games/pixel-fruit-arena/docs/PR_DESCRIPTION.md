# Make Pixel Fruit Arena Playable

## PR Summary

Follow-up to the merged MVP PR. Adds runtime pixel-art character sheets and textured stage art, wires them into the canvas renderer, adds a quick `Fight CPU` path, fixes CPU/winner match flow, and expands release validation so reference assets stay dev-only.

## Gameplay Summary

Playable local platform-fighter MVP with animated fighters, a textured Sky Ruins arena, stock-based combat, knockback scaling, double jumps, dodge, ring-outs, respawn invulnerability, CPU placeholders, and 2-4 player match setup. `Fight CPU` starts a quick one-player match against an AI opponent.

## Asset Pipeline Summary

Added GIF frame extraction, animation manifest generation, and sprite validation tools. Uploaded GIFs are reference-only and release builds remove `assets/reference`. Runtime character and stage art are separated from references and documented with license/credit files under `assets/licenses`.

## Test Results

Passed from the repository root:

```bash
powershell -ExecutionPolicy Bypass -File games/pixel-fruit-arena/tools/test.ps1
powershell -ExecutionPolicy Bypass -File games/pixel-fruit-arena/tools/validate_sprites.ps1 games/pixel-fruit-arena/assets/characters/prismtek_placeholder_character.json
powershell -ExecutionPolicy Bypass -File games/pixel-fruit-arena/tools/build.ps1
```

The build script removes `games/pixel-fruit-arena/dist/assets/reference` so reference GIF outputs are excluded from release artifacts.

Browser QA passed on `http://localhost:4173/` via `tools/serve.ps1`: the main menu loaded, `Fight CPU` started an active match, keyboard jump/attack input was accepted, HUD stayed in fight mode, animated fighters and stage art rendered, and no browser console errors were reported.

Merged-main PR content was also validated from a clean `main` snapshot on `http://localhost:4174/` with the same browser QA flow. Node/npm/Python are still unavailable on PATH here, so package-managed JS checks could not be run directly.

## Future Roadmap

- Replace prototype renderer with authored Prismtek sprite sheets.
- Add hitbox editor and animation preview tooling.
- Add netcode abstraction for rollback or delay-based online play.
- Add more stages, cosmetics, and fruit balance data.
- Add audio, training mode, and accessibility settings.

## Known Limitations

- Visuals use placeholder Prismtek runtime integration over locally available free pixel-art packs and are not final production art.
- CPU behavior is intentionally simple.
- Multiplayer is local only.
- No package-managed engine dependency is used in this workspace MVP.
- Browser QA was blocked in an earlier environment by the OS sandbox error `CreateProcessAsUserW failed: 5`, but passed in the current Codex desktop run using `tools/serve.ps1`.
- Local `git`, `node`, `npm`, and real Python were not available on PATH in this workspace. GitHub CLI was available.
