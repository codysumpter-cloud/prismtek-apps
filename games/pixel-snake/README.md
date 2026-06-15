# Pixel Snake

Pixel Snake is migrated from the Prismtek-site arcade inventory as a first-class browser game under `games/pixel-snake/`.

## Source provenance

- Source inventory: `codysumpter-cloud/prismtek-site/src/arcade/games/PixelSnakeGame.tsx`
- Shared Prismtek-apps runtime: `games/_shared/prismtek-arcade/arcade-core.js`
- Migration receipt: `docs/games/prismtek-site-arcade-migration-queue.md`

## Run

```bash
cd games/pixel-snake
npm test
npm run dev
```

Open `http://localhost:4173`.

## Package

```bash
cd games/pixel-snake
npm run package:zip
```

This creates `artifacts/pixel-snake-web.zip`.

## Controls

- WASD / Arrow keys: turn snake
- Restart button: reset run

## Shared Prismtek Arcade feel

Classic route-control score match with tight movement, speed mastery, score/rank clout, and local-first replayability.

## Platform matrix

| Platform | Status |
| --- | --- |
| Browser | Verified by smoke test |
| Static web ZIP | Partially verified by package script |
| Windows/macOS/Linux | Unverified until packaged ZIP is device-tested |
| RGDS Android/Linux | Unverified until device-tested |
| Nintendo DS | Missing; separate homebrew port required |
