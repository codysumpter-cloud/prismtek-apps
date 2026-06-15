# Pixel Stacker

Pixel Stacker is migrated from the Prismtek-site arcade inventory as a first-class browser game under `games/pixel-stacker/`.

## Source provenance

- Source inventory: `codysumpter-cloud/prismtek-site/src/arcade/games/PixelStackerGame.tsx`
- Shared Prismtek-apps runtime: `games/_shared/prismtek-arcade/arcade-core.js`
- Migration receipt: `docs/games/prismtek-site-arcade-migration-queue.md`

## Run

```bash
cd games/pixel-stacker
npm test
npm run dev
```

Open `http://localhost:4173`.

## Package

```bash
cd games/pixel-stacker
npm run package:zip
```

This creates `artifacts/pixel-stacker-web.zip`.

## Controls

- Space / click / tap: drop block
- Restart button: reset run

## Shared Prismtek Arcade feel

Timing/stacking precision match with one-more-try restarts, height streaks, badge clout, and local-first replayability.

## Platform matrix

| Platform | Status |
| --- | --- |
| Browser | Verified by smoke test |
| Static web ZIP | Partially verified by package script |
| Windows/macOS/Linux | Unverified until packaged ZIP is device-tested |
| RGDS Android/Linux | Unverified until device-tested |
| Nintendo DS | Missing; separate homebrew port required |
