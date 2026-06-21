# Prismtek Dino Dash

Original native Prismcade dinosaur runner using the four local DinoSprites sheets.

## Controls

- Character select: click/tap a dinosaur; on macOS 1-4 also selects.
- Click/tap/Space: jump.
- After game over: click/tap/Space returns to select/restarts flow.

## Built

- Character select with four real dinos: `doux`, `mort`, `tard`, `vita`.
- Side-scrolling runner with animated selected dino, jump, styled cactus obstacles, pixel ground scroll, layered `Background_Hills_v1` image backdrop, score, speed ramp, collision, restart, local high score.

## Sprite notes

- Source sheets: 576x24, sliced into 24 frames at 24x24 per frame.
- Facing: all four DinoSprites sheets face right; no flip was needed.
- Runtime gameplay size: 84x84 for every selected dino.
- Character select display: 96x96 with selected-card emphasis only.
- QA contact sheet: `apps/prismcade-native/verification-screenshots/dino-source-contact-sheet.png`

## Verification

Receipt: `apps/prismcade-native/verification-screenshots/dino-runtime-verification.json`

Snapshot: `apps/prismcade-native/verification-screenshots/dino-runtime-snapshot.png`

Verified: all four dinos found and selected, real sprites visible, consistent gameplay scale, right-facing sprites, jump works, styled obstacles spawn, score changes, speed ramps, game-over/restart works.

## Provenance

- Art used: `/Users/prismtek/Documents/Libresprite/dinoCharactersVersion1/sheets/DinoSprites - doux.png`
- Art used: `/Users/prismtek/Documents/Libresprite/dinoCharactersVersion1/sheets/DinoSprites - mort.png`
- Art used: `/Users/prismtek/Documents/Libresprite/dinoCharactersVersion1/sheets/DinoSprites - tard.png`
- Art used: `/Users/prismtek/Documents/Libresprite/dinoCharactersVersion1/sheets/DinoSprites - vita.png`
- Background used: `/Users/prismtek/Documents/Libresprite/Background_Hills_v1/_PNG/background1.png` through `background4.png`
- Background Hills license note from `_license.txt`: commercial use is allowed; credit is not required but appreciated.
- Excluded: copied Google/Chrome Dino assets; none were used.

The final `prismtek-site` pass found only incidental dino-like references in companion/pet content, not a safer or more complete Dino Dash asset set. The native app therefore keeps the four local DinoSprites sheets.
