# Add Pixel Fruit Arena MVP

## PR Summary

Adds a playable Pixel Fruit Arena MVP under `games/pixel-fruit-arena` with character creation, six modular fruit powers, local 2-4 player arena combat, awakening, stock/ring-out rules, one stage, original placeholder assets, and dev-only reference asset tooling.

## Gameplay Summary

Playable local platform-fighter MVP with stock-based combat, knockback scaling, double jumps, dodge, ring-outs, respawn invulnerability, CPU placeholders, and 2-4 player match setup.

## Asset Pipeline Summary

Added GIF frame extraction, animation manifest generation, and sprite validation tools. Uploaded GIFs are reference-only and release builds remove `assets/reference`.

## Test Results

Passed from the repository root:

```bash
powershell -ExecutionPolicy Bypass -File games/pixel-fruit-arena/tools/test.ps1
powershell -ExecutionPolicy Bypass -File games/pixel-fruit-arena/tools/validate_sprites.ps1 games/pixel-fruit-arena/assets/characters/prismtek_placeholder_character.json
powershell -ExecutionPolicy Bypass -File games/pixel-fruit-arena/tools/build.ps1
```

The build script removes `games/pixel-fruit-arena/dist/assets/reference` so reference GIF outputs are excluded from release artifacts.

## Future Roadmap

- Replace prototype renderer with authored Prismtek sprite sheets.
- Add hitbox editor and animation preview tooling.
- Add netcode abstraction for rollback or delay-based online play.
- Add more stages, cosmetics, and fruit balance data.
- Add audio, training mode, and accessibility settings.

## Known Limitations

- Visuals are original placeholder pixel art, not final production art.
- CPU behavior is intentionally simple.
- Multiplayer is local only.
- No package-managed engine dependency is used in this workspace MVP.
- Browser QA was blocked in this environment by the OS sandbox error `CreateProcessAsUserW failed: 5`.
- Local branch, commit, push, and PR creation could not run here because this workspace has no `.git` directory and `git`/`gh` are not available on PATH.
