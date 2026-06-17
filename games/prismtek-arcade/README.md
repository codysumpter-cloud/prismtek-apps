# Prismtek Arcade

`prismtek-arcade` imports the verified arcade game set from `prismtek-site` into `prismtek-apps` as a first-class game workspace.

## Included games

- Flappy Pixel
- Crossy Pixel
- Pixel Snake
- Neon Brick Breaker
- Pixel Stacker

## Run locally

```bash
cd games/prismtek-arcade
npm install
npm run dev
```

## Build

```bash
cd games/prismtek-arcade
npm run test
npm run build
```

## itch.io export

```bash
cd games/prismtek-arcade
npm run export:itch
```

The export script creates `artifacts/prismtek-arcade-itch.zip` with `index.html` at the archive root.

## Platform status

| Platform | Status |
| --- | --- |
| Browser | Source workspace added; build validation required in CI/local checkout. |
| itch.io | Export script added; artifact must be generated before release claim. |
| Windows | Pending desktop wrapper. |
| macOS | Pending desktop wrapper. |
| iOS | Pending native/WebView wrapper. |
| Android | Pending native/WebView wrapper. |
| Nintendo DS | Pending separate DS homebrew ports; browser React code does not run on DS. |

## DS notes

Nintendo DS support needs separate homebrew source under `ports/nds/`. Do not vendor unknown installer binaries or proprietary Nintendo SDK files into this repo.
