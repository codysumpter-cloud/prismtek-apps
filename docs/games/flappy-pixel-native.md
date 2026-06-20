# Flappy Pixel Native

Native SpriteKit version of Flappy Pixel for Prismcade.

## Controls

- Click/tap/Space: flap.
- After game over: click/tap/Space restarts.

## Built

- Animated real bird sprite from `Birds by Onocentaur/birds-2x.png`.
- Timer-driven gravity/flap loop.
- Scrolling gates, scoring, collision, game over, restart, local high score.

## Verification

Receipt: `apps/prismcade-native/verification-screenshots/flappy-runtime-verification.json`

Snapshot: `apps/prismcade-native/verification-screenshots/flappy-runtime-snapshot.png`

Verified: bird sprite appears, bird animates, flap moves upward, gravity applies, obstacles spawn, score changes, collision/game-over works, restart works.

## Provenance

- Source gameplay reference: `games/flappy-pixel/`
- Art used: `/Users/prismtek/Documents/Libresprite/Birds by Onocentaur/birds-2x.png`
- License note from `ABOUT.txt`: free for personal and professional projects; attribution appreciated.
- Excluded: `/Users/prismtek/Documents/Libresprite/Flappy_Bird_assets by kosresetr55.rar` to avoid copied Flappy Bird-style assets.

