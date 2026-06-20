# Buck Borris Mini-Game

Native Prismcade mini-game using real Buck Borris frames.

## Controls

- Click/tap/Space: jump.
- After game over: click/tap/Space restarts.

## Built

- Buck Borris visible as the player using real `run_00` through `run_03` frames.
- Small side-scrolling jump/dodge/collect loop.
- Hazards, pickups, score, game over, restart, local high score.

## Verification

Receipt: `apps/prismcade-native/verification-screenshots/buck-runtime-verification.json`

Snapshot: `apps/prismcade-native/verification-screenshots/buck-runtime-snapshot.png`

Verified: Buck sprite visible, jump works, hazards spawn, pickup collection works, score changes, game-over/restart works.

## Provenance

- Art used: `/Users/prismtek/Documents/Libresprite/Buck Borris/sensible_frames/frames/run/run_00.png`
- Art used: `/Users/prismtek/Documents/Libresprite/Buck Borris/sensible_frames/frames/run/run_01.png`
- Art used: `/Users/prismtek/Documents/Libresprite/Buck Borris/sensible_frames/frames/run/run_02.png`
- Art used: `/Users/prismtek/Documents/Libresprite/Buck Borris/sensible_frames/frames/run/run_03.png`
- Additional curated Buck strips copied for future animation expansion.

The final `prismtek-site` pass did not find Buck, Borris, or Boris game assets. The native app uses the local Buck Borris LibreSprite folder assets instead of any placeholder player art.
