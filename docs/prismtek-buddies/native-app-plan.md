# Prismtek Buddies — native app plan

## Architecture

- **XcodeGen** project (`apps/prismtek-buddies-native/project.yml`), matching the repo
  convention used by `apps/bemore-macos-native`. The generated `.xcodeproj` is committed
  (bemore commits its `.xcodeproj`; we match it).
- **Two targets sharing one `Shared/` sources dir:**
  - `PrismtekBuddiesMac` — platform macOS, deployment target 14.0.
  - `PrismtekBuddiesiOS` — platform iOS, deployment target 17.0.
- `bundleIdPrefix: com.prismtek`, Swift 5.9, Debug/Release configs. **No DEVELOPMENT_TEAM**
  (built with `CODE_SIGNING_ALLOWED=NO`).
- Each target has its own `@main` App (`MacApp/`, `iOSApp/`) pulling shared UI from
  `Shared/`. Per-platform `Info.plist`.

## Cross-platform strategy

- `BitbudRenderer.swift` abstracts `NSImage` vs `UIImage` via a `PlatformImage` typealias
  and an `Image(platformImage:)` initializer behind `#if os(macOS)` / `#if os(iOS)`.
- `RootView` branches: macOS uses `HSplitView` + a floating `NSWindow` mini mode; iOS uses
  a room header + `TabView`.

## Buddy state mapping

`BuddyState` enum → Bitbud atlas rows. App events drive state:

| Event                         | State    |
|-------------------------------|----------|
| default / idle                | idle     |
| app launch greeting / ambience on | waving |
| focus timer running           | running  |
| task marked done              | review   |
| timer paused (waiting on user)| waiting  |
| task deleted                  | failed   |
| focus session complete        | jumping (then idle) |

Transient states use `AppState.flash(_:for:thenReturnTo:)`.

## Assets — discovered vs used

- **Used:** Bitbud only. Sliced from Cody's own `/Users/prismtek/.codex/pets/bitbud/
  spritesheet.webp` (1536x1872, 8x9 grid, 192x208 cells) into 57 PNG frames via
  `scripts/extract_bitbud_frames.py`. The PNGs are committed; the source webp is **not**
  mutated and **not** committed. `bitbud-pet.json` is copied in for provenance.
- **Discovered but NOT used (prototype-only, uncommitted):** third-party downloaded packs
  such as Sunnyside, Clover Valley, Tiny RPG, Garden_Planters, Christmas update,
  libassetpack. These have unclear shipping licenses and are deliberately excluded from the
  app and the repo. They may inform original art direction only.

## Licensing / provenance notes

- Room, furniture, and UI = original SwiftUI shapes/gradients (no external art).
- Bitbud = Cody's own asset; safe to ship.
- No PixelLab calls, no credit spend, no network image generation.

## Known limitations (v0)

- Ambience audio is a silent placeholder (no audio files shipped). Toggles set UI state and
  make Bitbud wave.
- Gift/unlock is a banner placeholder; no reward content yet.
- iOS "mini mode" is the compact tab layout (no floating-window equivalent on iOS).

## Build / verify

See `apps/prismtek-buddies-native/README.md`. Both targets build with Xcode 27 via
`DEVELOPER_DIR=/Applications/Xcode-beta.app/Contents/Developer` and
`CODE_SIGNING_ALLOWED=NO`.

## Next steps

- Original/licensed ambient audio via `AVAudioPlayer`.
- Real unlock content (decor, buddy recolors via the BUAP sprite toolkit).
- Persisted cross-device sync for tasks/memo.
