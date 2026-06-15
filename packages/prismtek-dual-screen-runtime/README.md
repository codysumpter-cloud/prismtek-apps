# `@prismtek/dual-screen-runtime`

Shared runtime helpers for Prismtek games that need a two-pane handheld layout.

This package does not build an APK by itself. It gives browser games one display contract so Capacitor, Tauri, or native shells can mount the game consistently.

## Supported modes

| Mode | Meaning |
| --- | --- |
| `single` | Normal phone/desktop fallback. |
| `stacked-ds` | One tall window split into top gameplay plus bottom HUD/touch area. |
| `foldable-ds` | A foldable/window-segment layout where the host exposes two stacked panes. |
| `external-display` | Gameplay and controls may live on different displays. |
| `rgds-dual` | Handheld dual-pane adapter mode after real device receipts confirm behavior. |

## Basic usage

```js
import { createDualScreenRuntime } from '@prismtek/dual-screen-runtime';

const runtime = createDualScreenRuntime({
  root: document.documentElement,
  preferredMode: 'stacked-ds'
});

const layout = runtime.update();
console.log(layout.mode, layout.top, layout.bottom);
```

The runtime writes CSS variables to the root element:

```css
.game-top-screen {
  width: var(--prismtek-top-width);
  height: var(--prismtek-top-height);
}

.game-bottom-screen {
  width: var(--prismtek-bottom-width);
  height: var(--prismtek-bottom-height);
}
```

## Native shell bridge

A native shell can inject a display payload before the game starts:

```js
window.PrismtekDisplay = {
  mode: 'rgds-dual',
  source: 'android-native-shell',
  top: { x: 0, y: 0, width: 640, height: 480 },
  bottom: { x: 0, y: 480, width: 640, height: 480 },
  hinge: { x: 0, y: 480, width: 640, height: 0 }
};
```

## Game configs

Each supported game keeps a config at:

```text
games/<game-slug>/platforms/android-dual-screen.json
```

Validate them with:

```bash
npm run dual-screen:validate
```

## Integration rule

Do not hardcode a specific handheld into individual games. Games consume the common layout payload; the shell/runtime decides which display mode is active.
