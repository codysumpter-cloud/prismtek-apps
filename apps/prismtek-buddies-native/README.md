# Prismtek Buddies (native pixel-art room)

A small native SwiftUI app for macOS and iOS: a cozy productivity room with
selectable Buddy companions, clickable furniture, a focus timer, tasks, memo,
ambience toggles, Mini Mode, and a first Buddy Studio import/generation workflow.

The room is now a full pixel-art scene: tiled wall, tiled floor, baseboard,
crisp furniture sprites, selectable Buddy rendering, blocky selection feedback,
and object anchors that move Buddy to believable places in the room.

## Layout

```text
apps/prismtek-buddies-native/
  project.yml
  scripts/extract_bitbud_frames.py
  Shared/
    Buddy/                          # Bitbud + static Buddy renderers
    Models/                         # AppState, RoomObject, BuddyCharacter
    Views/                          # Room, picker, Buddy Studio, panels
    Resources/BitbudFrames/*.png
    Resources/Buddies/*.png
    Resources/RoomArt/*.png
    Resources/RoomArt/RoomTiles/*.png
    Resources/default-room-objects.json
  MacApp/
  iOSApp/
```

## Toolchain note

Xcode 27 is not the default toolchain on this machine. Use:

```text
DEVELOPER_DIR=/Applications/Xcode-beta.app/Contents/Developer
```

SDKs used by this app: `macosx27.0`, `iphonesimulator27.0`.

## Generate the project

```text
cd apps/prismtek-buddies-native
xcodegen generate
```

## Build

macOS:

```text
DEVELOPER_DIR=/Applications/Xcode-beta.app/Contents/Developer xcodebuild \
  -project PrismtekBuddies.xcodeproj -scheme PrismtekBuddiesMac \
  -sdk macosx27.0 CODE_SIGNING_ALLOWED=NO build
```

iOS simulator:

```text
DEVELOPER_DIR=/Applications/Xcode-beta.app/Contents/Developer xcodebuild \
  -project PrismtekBuddies.xcodeproj -scheme PrismtekBuddiesiOS \
  -sdk iphonesimulator27.0 CODE_SIGNING_ALLOWED=NO build
```

## Current features

- Pixel-art room wall/floor tiles, baseboard, and crisp furniture sprites.
- Clickable furniture: chair, couch, desk, computer, shelf, picture, plant,
  window, rug, music player.
- Buddy moves to object anchors and changes action labels/states.
- Blocky selected-object highlight.
- Selectable buddies: animated Bitbud plus static 64x64 Buddy variants.
- Buddy Studio panel with LibreSprite workflow and disabled PixelLab generation
  placeholder.
- What can Buddy do panel with current actions and future integrations.
- Focus timer, tasks, memo, ambience toggles, progression placeholder, Mini Mode.

## LibreSprite / PixelLab workflow

LibreSprite is required for Buddy creation/import work:

```text
/Applications/LibreSprite.app
/Applications/LibreSprite.app/Contents/MacOS/libresprite
~/Library/Application Support/LibreSprite/scripts/PixelLab.js
```

Use LibreSprite to inspect dimensions, crop/slice, verify hard pixel edges, and
export curated PNGs. Do not trigger PixelLab generation or spend credits without
explicit approval.

Future imported buddies should live at:

```text
~/Library/Application Support/Prismtek Buddies/Buddies/
```

## Add a furniture object

1. Add a curated hard-edged PNG to `Shared/Resources/RoomArt/`.
2. Add a JSON entry to `Shared/Resources/default-room-objects.json`.
3. Use `zIndex < 50` for back objects and `zIndex >= 50` for foreground objects.
4. Run `xcodegen generate` and rebuild.

## Add a Buddy

1. Prepare a transparent 64x64 PNG in LibreSprite.
2. Add it to `Shared/Resources/Buddies/`.
3. Register it in `Shared/Models/BuddyCharacter.swift`.
4. Build and verify the picker plus Mini Mode.

Animated buddies need frame rows and a renderer mapping; static buddies use one
PNG plus label/bob feedback.

## Known limitations

- PixelLab generation is intentionally disabled until an explicit approved credit
  flow exists.
- Static Buddy variants are not full animation atlases.
- Ambience audio is still a silent placeholder.
- Gifts/unlocks show a placeholder banner only.
- iOS Mini Mode remains the compact tab layout rather than a floating window.
