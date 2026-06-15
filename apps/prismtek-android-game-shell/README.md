# Prismtek Android Game Shell

Shared Android wrapper plan for Prismtek browser games that need repeatable APK packaging and two-pane handheld layouts.

This folder is intentionally a shell contract first. It does not declare a workspace package yet, so repo dependency install stays stable until the Android shell becomes a real buildable app. The game-specific source of truth lives in each game's `platforms/android-dual-screen.json` file, while `packages/prismtek-dual-screen-runtime/src/index.js` provides the source helpers.

## Games covered now

| Game | Config | Package |
| --- | --- | --- |
| Pixel Fruit Arena | `games/pixel-fruit-arena/platforms/android-dual-screen.json` | `dev.prismtek.pixelfruitarena` |
| TamerNet Battle Sandbox | `games/tamernet-battle-sandbox/platforms/android-dual-screen.json` | `dev.prismtek.tamernetbattle` |
| Spin Street Showdown | `games/spin-street-showdown/platforms/android-dual-screen.json` | `dev.prismtek.spinstreetshowdown` |

## Wrapper responsibilities

The Android wrapper should:

1. choose a game config
2. copy the game web artifact into Android assets
3. provide `window.PrismtekDisplay` before loading the game
4. preserve keyboard/controller input
5. expose touch controls only as a convenience layer
6. capture a receipt before any platform is marked verified

The game should:

1. render gameplay into the top pane when dual-screen mode is active
2. render HUD/menu/controls into the bottom pane when dual-screen mode is active
3. keep single-screen fallback playable
4. avoid device-specific layout checks

## Expected local flow

```bash
npm run dual-screen:validate
npm run dual-screen:smoke
npm run porting-kits:verify

cd games/pixel-fruit-arena
npm test
npm run build
npm run package:zip
```

Then stage the built web artifact into this wrapper and build the APK locally with Capacitor, Tauri Android, or a native Kotlin shell.

## Display payload

```js
window.PrismtekDisplay = {
  mode: 'stacked-ds',
  source: 'android-shell',
  top: { x: 0, y: 0, width: 640, height: 480 },
  bottom: { x: 0, y: 480, width: 640, height: 480 },
  hinge: { x: 0, y: 480, width: 640, height: 0 }
};
```

## Next implementation steps

1. Add a minimal Capacitor wrapper package here.
2. Add a staging script that copies each game artifact into Android app assets.
3. Add a native bridge that computes `PrismtekDisplay` from Android window/display data.
4. Build debug APKs for the three active games.
5. Test single-screen Android, tall stacked mode, and RGDS Android mode.
6. Only then add APK download links or mark targets verified.

No downloaded SDKs, generated APKs, or device-specific build outputs should be committed here.
