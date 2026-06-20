# Prismtek Buddies — Buddy Studio

Buddy Studio is the first in-app workflow for creating or importing new Buddy
companions. It is intentionally a v0 workflow: it exposes the path and controls,
but does not call external services or spend PixelLab credits automatically.

## Current in-app workflow

The native app now includes a **Buddy Studio** panel. It shows the selected Buddy,
explains the LibreSprite workflow, and exposes these controls:

- **Open in LibreSprite** — launches `/Applications/LibreSprite.app` on macOS.
- **Import Buddy Image** — creates/reveals the future local Buddy folder.
- **Import Codex Pet Package** — placeholder for future package import.
- **Generate with LibreSprite / PixelLab plugin** — disabled in v0 by design.

Future imported/generated buddies should be stored at:

```text
~/Library/Application Support/Prismtek Buddies/Buddies/
```

## LibreSprite and PixelLab paths

LibreSprite is required for the workflow, not optional:

```text
/Applications/LibreSprite.app
/Applications/LibreSprite.app/Contents/MacOS/libresprite
```

The local PixelLab adapter is installed here:

```text
~/Library/Application Support/LibreSprite/scripts/PixelLab.js
```

The original Aseprite extension reference is kept here for compatibility work:

```text
~/Library/Application Support/LibreSprite/PixelLab-Aseprite-extension
```

## Credit safety

Buddy Studio does **not** trigger PixelLab generation yet. PixelLab generation may
use credits, so the app keeps the generate button disabled until a later approved
workflow adds explicit user confirmation and a real import/save path.

Allowed now:

- inspect sprite dimensions in LibreSprite,
- crop/slice static Buddy PNGs,
- verify hard pixel edges and transparency,
- export cleaned PNGs locally,
- import already-approved 64x64 Buddy art.

Not allowed automatically:

- external generation calls,
- paid PixelLab credit usage,
- committing raw third-party packs,
- mutating the original Bitbud source atlas.

## Static Buddy vs animated atlas Buddy

`BuddyCharacter` supports two render kinds:

- `animatedAtlas` — Bitbud, backed by sliced animation frames in
  `Shared/Resources/BitbudFrames/` and rendered by `BitbudRenderer`.
- `staticImage` — a single 64x64 PNG in `Shared/Resources/Buddies/`, rendered by
  `StaticBuddyRenderer` with label-driven reactions and a small bob for emotes.

Static buddies are useful for early variants. A future animated Buddy should add
frame rows, register a new `BuddyState` mapping, and switch its `BuddyCharacter`
entry to an atlas-backed renderer.

## Add a new Buddy

1. Prepare a transparent 64x64 PNG in LibreSprite.
2. Verify nearest-neighbor / hard-edge pixels. Avoid soft shadows and anti-aliased
   halos.
3. Add the curated PNG to `apps/prismtek-buddies-native/Shared/Resources/Buddies/`.
4. Add a `BuddyCharacter` entry in
   `apps/prismtek-buddies-native/Shared/Models/BuddyCharacter.swift`.
5. Run `xcodegen generate`, build macOS and iOS, and verify the picker plus Mini
   Mode both show the new Buddy.

## Future generation/import work

- Add a real file importer for 64x64 PNGs.
- Copy imported files into the local app-support Buddy folder.
- Add a manifest for imported buddies and persist selections by id.
- Add Codex pet package import for packages with manifests and sprite sheets.
- Add explicit PixelLab confirmation before any generation request.
- Add animated atlas support for generated pets once frame rows are available.
