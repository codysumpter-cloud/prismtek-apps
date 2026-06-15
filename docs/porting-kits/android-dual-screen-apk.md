# Android dual-screen APK process

This is the repeatable Prismtek process for building Android APKs that use a two-pane handheld layout.

The goal is one shared runtime contract, not one-off Android forks for every game.

## Supported games

| Game | Config | Top pane | Bottom pane |
| --- | --- | --- | --- |
| Pixel Fruit Arena | `games/pixel-fruit-arena/platforms/android-dual-screen.json` | Arena/fight canvas | HUD, powers, awakening, pause, rematch |
| TamerNet Battle Sandbox | `games/tamernet-battle-sandbox/platforms/android-dual-screen.json` | Battlefield/creature combat | Commands, party state, capture prompt, log |
| Spin Street Showdown | `games/spin-street-showdown/platforms/android-dual-screen.json` | Dome arena | Parts bench, shop, HUD, mode controls |

## Runtime contract

Every supported game should read the same display payload:

```js
window.PrismtekDisplay = {
  mode: 'stacked-ds',
  source: 'android-shell',
  top: { x: 0, y: 0, width: 640, height: 480 },
  bottom: { x: 0, y: 480, width: 640, height: 480 },
  hinge: { x: 0, y: 480, width: 640, height: 0 }
};
```

Game code should use the source helpers in `packages/prismtek-dual-screen-runtime/src/index.js` to compute/apply layout variables rather than hardcoding a device. The runtime is intentionally source-only in this PR so dependency installation does not require a lockfile update before the Android shell becomes a buildable app.

## Repeatable build flow

### 1. Validate configs

From the repo root:

```bash
npm run dual-screen:validate
npm run dual-screen:smoke
```

This ensures each active game has a valid config and the shared layout helper still computes single, stacked, native, and CSS-variable outputs.

### 2. Build the web game

```bash
cd games/pixel-fruit-arena
npm install
npm test
npm run build
npm run package:zip
```

For the other static games:

```bash
cd games/tamernet-battle-sandbox
npm test
npm run package:zip

cd ../spin-street-showdown
npm test
npm run package:zip
```

### 3. Stage the game into the Android app wrapper

The wrapper should read the selected game config and copy that game's built web artifact into Android app assets.

Target wrapper shape:

```text
apps/prismtek-android-game-shell/
├── README.md
├── config/games.json
└── android/
    └── app/src/main/assets/games/<game-id>/
```

The wrapper owns native display detection. The game owns gameplay.

### 4. Provide the display bridge

Before the game entrypoint loads, the wrapper provides `window.PrismtekDisplay`.

The payload should be generated from the best available source, in this order:

1. explicit device adapter receipt
2. Android display/window info from the app wrapper
3. foldable/window-segment posture info
4. tall single-window stacked fallback
5. single-screen fallback

### 5. Build APK

Use Capacitor first for a fast wrapper, then graduate to a native Kotlin/Tauri wrapper if needed.

Capacitor starter shape after the wrapper package exists:

```bash
cd apps/prismtek-android-game-shell
npm install
npx cap sync android
npx cap open android
```

Native/Tauri wrapper work should keep the same config files and display payload contract.

## Verification matrix

A game may be marked **Partially verified** for Android dual-screen mode when:

- config validates
- web artifact builds
- wrapper loads the game locally
- stacked layout can be simulated in a tall browser/WebView

A game may be marked **Verified** only when:

- APK artifact exists
- APK launches on Android
- single-screen fallback is playable
- stacked dual-pane layout is playable
- foldable/segment behavior is tested or explicitly marked not applicable
- RGDS Android mode is tested on the actual device before claiming RGDS support
- one complete game loop reaches win/loss/rematch/reset state

## Receipt template

```text
Game:
Package:
Build command:
Artifact path:
Host OS:
Android device/runtime:
Display mode tested:
Top pane result:
Bottom pane result:
Controls tested:
Full loop completed:
Known issues:
Date:
Tester:
```

## Do not do this

- Do not make one custom Android fork per game.
- Do not mark RGDS support verified from a desktop browser test.
- Do not require touch-only actions for core gameplay.
- Do not bury gameplay under HUD controls in dual-screen mode.
- Do not claim an APK download exists until an actual signed or debug APK is attached somewhere verifiable.
