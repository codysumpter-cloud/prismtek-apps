# Neon Brick Breaker

Neon Brick Breaker is migrated from the Prismtek-site arcade inventory as a first-class browser game under `games/neon-brick-breaker/`.

## Source provenance

- Source inventory: `codysumpter-cloud/prismtek-site/src/arcade/games/NeonBrickBreakerGame.tsx`
- Shared Prismtek-apps runtime: `games/_shared/prismtek-arcade/arcade-core.js`
- Migration receipt: `docs/games/prismtek-site-arcade-migration-queue.md`

## Run

```bash
cd games/neon-brick-breaker
npm test
npm run dev
```

Open `http://localhost:4173`.

## Package

```bash
cd games/neon-brick-breaker
npm run package:zip
```

This creates `artifacts/neon-brick-breaker-web.zip`.

## Controls

- A/D or Arrow keys: move paddle
- Restart button: reset run

## Shared Prismtek Arcade feel

Paddle-and-tile score match with clean rebounds, combo streaks, accuracy/rank clout, and local-first replayability.

## Platform matrix

| Platform | Status |
| --- | --- |
| Browser | Verified by smoke test |
| Static web ZIP | Partially verified by package script |
| Windows/macOS/Linux | Unverified until packaged ZIP is device-tested |
| RGDS Android/Linux | Unverified until device-tested |
| Nintendo DS | Missing; separate homebrew port required |
