# Prismtek Dino Dash

Original native Prismcade dinosaur runner using the four local DinoSprites sheets.

## Controls

- Character select: click/tap a dinosaur; on macOS 1-4 also selects.
- Click/tap/Space: jump.
- After game over: click/tap/Space returns to select/restarts flow.

## Built

- Character select with four real dinos: `doux`, `mort`, `tard`, `vita`.
- Side-scrolling runner with animated selected dino, jump, obstacles, ground scroll, score, speed ramp, collision, restart, local high score.

## Verification

Receipt: `apps/prismcade-native/verification-screenshots/dino-runtime-verification.json`

Snapshot: `apps/prismcade-native/verification-screenshots/dino-runtime-snapshot.png`

Verified: all four dinos found and selected, real sprites visible, jump works, obstacles spawn, score changes, speed ramps, game-over/restart works.

## Provenance

- Art used: `/Users/prismtek/Documents/Libresprite/dinoCharactersVersion1/sheets/DinoSprites - doux.png`
- Art used: `/Users/prismtek/Documents/Libresprite/dinoCharactersVersion1/sheets/DinoSprites - mort.png`
- Art used: `/Users/prismtek/Documents/Libresprite/dinoCharactersVersion1/sheets/DinoSprites - tard.png`
- Art used: `/Users/prismtek/Documents/Libresprite/dinoCharactersVersion1/sheets/DinoSprites - vita.png`
- Excluded: copied Google/Chrome Dino assets; none were used.

The final `prismtek-site` pass found only incidental dino-like references in companion/pet content, not a safer or more complete Dino Dash asset set. The native app therefore keeps the four local DinoSprites sheets.
