# Crossy Pixel

Crossy Pixel is migrated from the Prismtek-site arcade inventory as a first-class browser game under `games/crossy-pixel/`.

## Source provenance

- Source inventory: `codysumpter-cloud/prismtek-site/src/arcade/games/CrossyPixelGame.tsx`
- Shared Prismtek-apps runtime: `games/_shared/prismtek-arcade/arcade-core.js`
- Migration receipt: `docs/games/prismtek-site-arcade-migration-queue.md`

## Run

```bash
cd games/crossy-pixel
npm test
npm run dev
```

Open `http://localhost:4173`.

## Package

```bash
cd games/crossy-pixel
npm run package:zip
```

This creates `artifacts/crossy-pixel-web.zip`.

## Controls

- WASD / Arrow keys: move
- Restart button: reset run

## Shared Prismtek Arcade feel

Lane-crossing dodge/run match with readable hazards, streak pressure, distance clout, and local-first replayability.

## Platform matrix

| Platform | Status |
| --- | --- |
| Browser | Verified by smoke test |
| Static web ZIP | Partially verified by package script |
| Windows/macOS/Linux | Unverified until packaged ZIP is device-tested |
| RGDS Android/Linux | Unverified until device-tested |
| Nintendo DS | Missing; separate homebrew port required |
