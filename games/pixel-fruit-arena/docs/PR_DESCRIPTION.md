# Make Pixel Fruit Arena Playable

## PR Summary

Follow-up to the merged MVP PR. Adds runtime pixel-art character sheets, textured stage art, downloaded elemental VFX sheets, selectable combat styles, and a quick `Fight CPU` path. It fixes creator/menu routing, CPU/winner match flow, improves fruit ability behavior, and expands release validation so reference assets stay dev-only.

This update also adds an opt-in local fan/dev reference mode for the One Piece GIFs in Downloads. The install script copies those files into a git-ignored reference folder and the renderer only loads them from localhost when `?referenceAssets=true` is set. They are not committed and release builds remove `assets/reference`.

## Gameplay Summary

Playable local platform-fighter MVP with animated fighters, a textured Sky Ruins arena, stock-based combat, knockback scaling, double jumps, dodge, ring-outs, respawn invulnerability, CPU placeholders, and 2-4 player match setup. `Fight CPU` starts a quick one-player match against an AI opponent.

The character creator now supports body sprite selection, hair style, palette customization, and selectable combat styles: Duelist, Brawler, Striker, Ranger, Guardian, and Trickster. Combat style modifies movement, jump, damage, knockback, range, cooldowns, weight, and dodge behavior independently from fruit powers.

Fruit behavior is more distinct and visually readable: Frost slows, Shadow can null special use, Gravity/Shadow pulls drag opponents, Volt chain attacks add extra stun, Rubber bounce improves recovery, and Blink moves immediately before the hit check. Flame, Frost, Volt, Shadow, Rubber, and Gravity abilities now map to sprite-sheet VFX instead of only canvas debug strokes.

## Asset Pipeline Summary

Added GIF frame extraction, animation manifest generation, and sprite validation tools. Uploaded GIFs are reference-only and release builds remove `assets/reference`. Runtime character and stage art are separated from references and documented with license/credit files under `assets/licenses`.

Downloaded elemental VFX packs from the user's Downloads folder are staged under `assets/effects/elemental-vfx` with `README_LICENSE_NOTE.txt`. They are used to make the local fan/dev build feel playable now; licenses should be verified before public release.

## Test Results

Passed from the repository root:

```bash
powershell -ExecutionPolicy Bypass -File games/pixel-fruit-arena/tools/test.ps1
powershell -ExecutionPolicy Bypass -File games/pixel-fruit-arena/tools/validate_sprites.ps1 games/pixel-fruit-arena/assets/characters/prismtek_placeholder_character.json
powershell -ExecutionPolicy Bypass -File games/pixel-fruit-arena/tools/build.ps1
```

The build script removes `games/pixel-fruit-arena/dist/assets/reference` so reference GIF outputs are excluded from release artifacts.

Browser QA passed on `http://localhost:4184/` via `tools/serve.ps1`: the main menu loaded, Creator opened, body/hair/style selections persisted to HUD, Fruits opened, Gravity equipped, `Fight CPU` started an active match, keyboard attack input was accepted, HUD stayed in fight mode, animated fighters, stage art, and VFX rendered, and no browser console errors were reported on the fresh build.

Local reference mode QA passed with `?referenceAssets=true`: One Piece GIF attack overlays and the local reference backdrop loaded from ignored `assets/reference/onepiece-test/runtime` files.

Merged-main PR content was also validated from a clean `main` snapshot on `http://localhost:4174/` with the same browser QA flow. Node/npm/Python are still unavailable on PATH here, so package-managed JS checks could not be run directly.

## Future Roadmap

- Replace prototype renderer with authored Prismtek sprite sheets.
- Add hitbox editor and animation preview tooling.
- Add netcode abstraction for rollback or delay-based online play.
- Add more stages, cosmetics, and fruit balance data.
- Add audio, training mode, and accessibility settings.

## Known Limitations

- Visuals use placeholder Prismtek runtime integration over locally available free pixel-art/VFX packs and are not final production art.
- Downloaded elemental VFX pack licenses need verification before public release.
- One Piece reference files are local fan/dev-only and must be removed/replaced before any release or public distribution.
- CPU behavior is intentionally simple.
- Multiplayer is local only.
- No package-managed engine dependency is used in this workspace MVP.
- Browser QA was blocked in an earlier environment by the OS sandbox error `CreateProcessAsUserW failed: 5`, but passed in the current Codex desktop run using `tools/serve.ps1`.
- Local `git`, `node`, `npm`, and real Python were not available on PATH in this workspace. GitHub CLI was available.
