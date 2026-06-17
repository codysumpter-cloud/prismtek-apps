# Flappy Pixel

Flappy Pixel is migrated from the Prismtek-site arcade inventory as a first-class browser game under `games/flappy-pixel/`.

## Source provenance

- Source inventory: `codysumpter-cloud/prismtek-site/src/arcade/games/FlappyPixelGame.tsx`
- Shared Prismtek-apps runtime: `games/_shared/prismtek-arcade/arcade-core.js`
- Migration receipt: `docs/games/prismtek-site-arcade-migration-queue.md`

## Run

```bash
cd games/flappy-pixel
npm test
npm run dev
```

Open `http://localhost:4173`.

## Package

```bash
cd games/flappy-pixel
npm run package:zip
```

This creates `artifacts/flappy-pixel-web.zip`.

## Controls

- Space / click / tap: flap
- Restart button: reset run

## Shared Prismtek Arcade feel

One-button reflex survival match with fast restarts, clean obstacle reads, score/rank clout, and local-first replayability.

## Platform matrix

| Platform | Status |
| --- | --- |
| Browser | Verified by smoke test |
| Static web ZIP | Partially verified by package script |
| Windows/macOS/Linux | Unverified until packaged ZIP is device-tested |
| RGDS Android/Linux | Unverified until device-tested |
| Nintendo DS | Missing; separate homebrew port required |
