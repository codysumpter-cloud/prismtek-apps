# Prismtek dual-screen runtime

Shared source helpers for Prismtek games that need a two-pane handheld layout.

This folder does not build an APK by itself and intentionally does not declare a workspace package yet. Keeping it as source-only avoids `package-lock.json` churn until the Android shell becomes a real buildable app. The root validation scripts import it directly from `src/index.js`.

## Supported modes

| Mode | Meaning |
| --- | --- |
| `single` | Normal phone/desktop fallback. |
| `stacked-ds` | One tall window split into top gameplay plus bottom HUD/touch area. |
| `foldable-ds` | A foldable/window-segment layout where the host exposes two stacked panes. |
| `external-display` | Gameplay and controls may live on different displays. |
| `rgds-dual` | Handheld dual-pane adapter mode after real device receipts confirm behavior. |

## Basic usage

For repo-local scripts/tests, import the source module directly:

```js
import { createDualScreenRuntime } from '../../packages/prismtek-dual-screen-runtime/src/index.js';

const runtime = createDualScreenRuntime({
  root: document.documentElement,
  preferredMode: 'stacked-ds'
});

const layout = runtime.update();
console.log(layout.mode, layout.top, layout.bottom);
```

When a real Android shell package lands, it can either bundle this source or promote the folder back to a workspace package with a matching lockfile update.

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
