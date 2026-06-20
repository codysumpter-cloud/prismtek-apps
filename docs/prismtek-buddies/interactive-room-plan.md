# Prismtek Buddies — Interactive Pixel-Art Room

This document records the move from the theme-only v0 cozy room to a polished
**interactive pixel-art room** in `apps/prismtek-buddies-native/`.

## Why theme-only was insufficient

The first native room drew the wall, floor, furniture, and lighting with SwiftUI
shapes and gradients. It proved the product idea but did not fit Bitbud:

1. **Bitbud is pixel art, the room was not.** Smooth gradients and rounded vector
   furniture made Bitbud look pasted onto a modern UI surface.
2. **The room did not have a floor plane.** Objects sat like stickers rather than
   furniture in a small space.
3. **The wall/floor were not assets.** Theme colors alone could not satisfy the
   pixel-art visual target.

## Why PR #202 needed this polish pass

PR #202 proved the interaction pipeline: furniture could be clicked, Buddy moved
to anchors, action labels changed, and emotes worked. The props were better, but
the wall and floor still used flat SwiftUI color areas. This pass keeps the PR
pipeline and replaces the unfinished room surface with tiled pixel art.

## Pixel-art visual target

- Wall and floor are sprite-backed/tiled from 16x16 PNGs.
- A repeated 16x4 baseboard separates the wall and floor.
- No gradients are used inside the room scene.
- Furniture and buddies render with `.interpolation(.none)`.
- Selection feedback is a blocky pixel outline, not a soft glow.
- Buddy feet anchor to the floor plane and object anchors.
- Furniture z-order separates back-wall props, Buddy, and foreground seating.

The side panel remains normal SwiftUI; the room scene itself is held to the
pixel-art bar.

## LibreSprite / plugin usage

LibreSprite is part of the app workflow and verification path:

```text
/Applications/LibreSprite.app
/Applications/LibreSprite.app/Contents/MacOS/libresprite
~/Library/Application Support/LibreSprite/scripts/PixelLab.js
~/Library/Application Support/LibreSprite/PixelLab-Aseprite-extension
```

Use LibreSprite for local inspection/export/cleanup: sprite dimensions, hard-edge
pixel checks, slicing/cropping, and 64x64 Buddy PNG preparation. Do not use the
PixelLab plugin to spend credits unless the user explicitly approves it.

## Clickable object model

A room is a list of `RoomObject` values loaded from
`Shared/Resources/default-room-objects.json` and held on `AppState.roomObjects`.

```swift
struct RoomObject: Identifiable, Codable {
    let id: String
    let name: String
    let kind: RoomObjectKind
    let interaction: BuddyInteraction
    let assetName: String?
    let position: CGPoint
    let size: CGSize
    let buddyAnchor: CGPoint
    let zIndex: Double
}
```

Coordinates are normalized to the room canvas (`0...1`, origin top-left), so the
same JSON scales across macOS, iOS, and Mini Mode-adjacent layouts.

`CozyRoomView` now draws:

1. tiled wall,
2. tiled floor,
3. pixel baseboard,
4. back objects (`zIndex < 50`),
5. selected Buddy at its feet anchor,
6. foreground objects (`zIndex >= 50`),
7. action label.

## How to add a furniture object

1. Add a hard-edged PNG to `Shared/Resources/RoomArt/`.
2. Add a JSON entry to `Shared/Resources/default-room-objects.json` with a unique
   id, kind, interaction, asset name, position, size, Buddy anchor, and z-index.
3. Use `zIndex < 50` for wall/back-plane props, `zIndex >= 50` for objects that
   should appear in front of Buddy.
4. Run `xcodegen generate` and rebuild.

## How to add a new Buddy

See `docs/prismtek-buddies/buddy-studio.md`. Short version: prepare a transparent
64x64 PNG in LibreSprite, commit only the curated PNG, add it to
`BuddyCharacter.registry`, and verify the picker plus Mini Mode.

## How to add a Buddy animation state later

Some interactions still reuse the closest existing atlas row:

- sit/rest/wait -> `waiting`
- listen -> `waving`
- water/check plant and inspect -> `review`

To add a dedicated animation:

1. Add frames to a future Buddy atlas and slice them to PNG.
2. Add a `BuddyState` case in `AppState.swift`.
3. Add a frame row entry in `BitbudFrames.layout`.
4. Point the relevant `BuddyInteraction` at the new state.
5. Document the mapping in `buddy-actions.md`.

Future hooks are reserved for sit, sleep, dance, read, code, eat, garden, listen,
and related room-specific actions.
