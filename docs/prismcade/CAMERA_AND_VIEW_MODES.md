# Prismcade Camera and View Modes

Prismcade games should declare the camera/view mode they use before asking for a character runtime.

The goal is simple: one avatar identity should be reusable across many retro game types without every game hardcoding one sprite sheet.

## Camera mode versus character view

A **camera mode** describes how the game world is viewed and controlled.

A **character view variant** describes which sprite runtime the avatar needs for that camera.

Examples:

- A platform fighter declares `side` and needs a `side` character variant.
- A social hub declares `low_top_down` and needs a `low_top_down` or `top_down` variant.
- A profile card declares `profile_lobby` and can use `profile`, `lobby`, or a safe fallback like `side` idle.

## Supported camera modes

The canonical list lives in:

```txt
data/prismcade/view-modes.json
```

Initial modes:

- `side`
- `top_down`
- `low_top_down`
- `isometric`
- `arena_2_5d`
- `profile_lobby`

## Top-down animation source guide

The top-down and low-top-down animation rules are expanded in:

```txt
docs/prismcade/TOP_DOWN_CHARACTER_ANIMATION_GUIDE.md
```

That guide captures the practical Prismcade takeaways from SLYNYRD Pixelblog 55: 3/4 top-down projection, 4-facing economy mode, full 8-facing mode, rotation QA, six-frame walk/run defaults, subtle idle timing, and layer-friendly character design.

## Why this comes before game wiring

If Pixel Fruit Arena loads Prismtek Fixed Hair directly, it proves one side-view game.

If Prismcade first defines camera/view contracts, the platform can later route the same avatar identity into:

- side-view fighters;
- low-top-down hubs;
- top-down adventures;
- isometric scenes;
- profiles, catalogs, and leaderboards.

That is the platform layer.

## Character manifest requirement

A portable character manifest should declare `viewVariants`.

Example:

```json
{
  "viewVariants": {
    "side": {
      "status": "playtest",
      "runtimeSizes": [32, 48, 64, 96, 128, 192, 256],
      "defaultSize": 64,
      "runtimeRoot": "runtime",
      "requiredSlotsReady": true
    },
    "profile": {
      "status": "fallback",
      "sourceView": "side",
      "defaultSize": 64,
      "fallbackSlot": "idle"
    },
    "lobby": {
      "status": "fallback",
      "sourceView": "side",
      "defaultSize": 64,
      "fallbackSlot": "idle"
    }
  }
}
```

## Game manifest requirement

A Prismcade game should declare a camera/view mode and a character runtime preference.

Example:

```json
{
  "viewMode": "side",
  "characterRuntime": {
    "requiredView": "side",
    "preferredSize": 64,
    "requiredSlots": ["idle", "walk", "run", "jump", "fall", "hurt"]
  }
}
```

## Runtime selection flow

1. Game declares `viewMode`.
2. View contract lists required character views and fallbacks.
3. Character manifest declares available `viewVariants`.
4. Loader chooses the first compatible variant.
5. Loader chooses the requested size or variant default.
6. Loader returns the runtime manifest, atlas URL, clips, selected view, selected size, and fallback metadata.

## Fallback rule

Fallback is allowed, but it must be explicit.

For example, a top-down game should not silently use side-view walking as if it were a correct top-down avatar. It can use `profile_lobby` fallback for menus, profile cards, or locked/unavailable states, but gameplay should keep requiring the correct variant.

## Recommended proof path

1. Define the camera/view mode contract.
2. Extend the character loader to select a view variant.
3. Mark Prismtek Fixed Hair as `side` ready and `profile`/`lobby` fallback capable.
4. Wire a side-view proof in Pixel Fruit Arena.
5. Build the low-top-down Prismcade hub/avatar locker proof.
6. Generate top-down and isometric variants after the loader knows how to request them.
