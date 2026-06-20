# Prismtek Buddies — Interactive Pixel-Art Room

This document records the move from the theme-only v0 cozy room to an
**interactive pixel-art room** in `apps/prismtek-buddies-native/`.

## Why theme-only was insufficient

The v0 `CozyRoomView` drew the whole room with SwiftUI `Shape`s and
`LinearGradient`s. It looked fine but had two problems for the cozy-companion
direction:

1. **Not pixel-art.** Soft gradients + anti-aliased rounded rectangles read as
   "modern UI", not as a cozy 2D game room. Bitbud (a hard-edged sprite) sat on
   top of smooth vector furniture, which clashed.
2. **Not interactive.** Furniture was decorative. There was no way for Bitbud to
   *do* anything in the room beyond the timer/task event reactions; you couldn't
   click the desk to make Bitbud work, or the chair to make it sit.

## Pixel-art target

- Every room sprite **and** Bitbud render with
  `Image(...).interpolation(.none).resizable()` — hard edges, no blur, no
  anti-alias smoothing.
- The room scene uses **flat theme color blocks** (a flat wall band + flat floor
  band + a 2px accent skirting line at the seam). No gradients inside the room
  scene. `BuddyRoomTheme` (wall/floor/accent) still drives the palette, so the
  theme picker keeps working.
- The side panel (timer/tasks/memo/ambience/actions) stays normal SwiftUI — only
  the room *scene* is held to the pixel-art bar.

## Art slicing / LibreSprite usage

The room sprites are tiny hard-edged PNGs (13–64 px) committed under
`Shared/Resources/RoomArt/`. Provenance is recorded in
`docs/prismtek-buddies/asset-inventory.md`. Six are connected-component slices
from the owner-attested ship-safe `interior free` pack; four are original
Prismtek pixel props authored this pass. The non-commercial `fishing_free` pack
is excluded. No raw `.aseprite` / LibreSprite project files are committed — only
the flat PNGs that ship.

## Clickable object model

A room is a list of `RoomObject` (see `Shared/Models/RoomObject.swift`), loaded
at launch from `Shared/Resources/default-room-objects.json`
(`RoomObject.loadDefaultRoom()`), held on `AppState.roomObjects`.

```swift
struct RoomObject: Identifiable, Codable {
    let id: String
    let name: String
    let kind: RoomObjectKind        // chair, desk, bed, shelf, plant, window, rug, musicPlayer, computer
    let interaction: BuddyInteraction // sit, work, rest, wave, inspect, waterPlant, listen, celebrate, wait
    let assetName: String?          // PNG base name in Resources/RoomArt
    let position: CGPoint           // normalized 0...1 center
    let size: CGSize                // normalized fraction of room w/h
    let buddyAnchor: CGPoint        // normalized feet position when interacting
    let zIndex: Double              // draw order
}
```

Coordinates are **normalized to the room canvas (0…1, origin top-left)** so the
layout scales with the view on both macOS and iOS.

`CozyRoomView` sorts objects by `zIndex`, renders each as a `RoomObjectSprite`,
and attaches an `onTapGesture` that calls `AppState.interact(with:)`. That:

1. sets `selectedObjectID` (drives the accent outline + slight scale),
2. moves `buddyAnchor` to the object's anchor (Bitbud animates over via
   `.animation(.easeInOut, value:)`),
3. sets the Bitbud `BuddyState` via `AppState.state(for: interaction)`,
4. sets `actionLabel` (e.g. "Bitbud is sitting"), shown as a flat chip.

## How to add a furniture object

1. Add a hard-edged PNG to `Shared/Resources/RoomArt/` (keep it small; it bundles
   automatically — the `Shared` dir is an XcodeGen source path and unknown file
   types become flat resources in both targets).
2. Add an entry to `Shared/Resources/default-room-objects.json` with a unique
   `id`, a `kind`, an `interaction`, the `assetName` (PNG base name), and
   normalized `position` / `size` / `buddyAnchor` / `zIndex`.
3. Run `xcodegen generate` and rebuild. No Swift changes are required for a new
   object that reuses an existing `kind` / `interaction`.

If the PNG is missing at runtime, `RoomObjectSprite` falls back to a flat accent
block so the layout stays intact.

## How to add a Buddy animation state later

Today some interactions reuse the closest existing atlas row (see the `TODO`s in
`AppState.state(for:)`): `sit`/`rest`/`wait` → `waiting`, `listen` → `waving`,
`waterPlant`/`inspect` → `review`. To add a dedicated animation:

1. Add the new row to the Bitbud atlas and re-slice via
   `scripts/extract_bitbud_frames.py` into `Shared/Resources/BitbudFrames/`.
2. Add a case to `BuddyState` (`Shared/Models/AppState.swift`) and an entry to
   `BitbudFrames.layout` (`Shared/Buddy/BitbudRenderer.swift`) with the row name +
   frame count.
3. Point the relevant `BuddyInteraction` at the new `BuddyState` in
   `AppState.state(for:)` and remove the corresponding `TODO`.
