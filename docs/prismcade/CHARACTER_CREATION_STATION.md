# Prismcade Character Creation Station

The Character Creation Station is the first user-facing Prismcade avatar builder surface. It is a browser-based creator at:

```text
apps/prismcade-creator/character-station.html
```

It builds outfit-safe 64x64 avatar recipes and Prismcade character manifests from the local character creation source-pack contract.

## Current Scope

```text
apps/prismcade-creator/character-station.html
  Browser-only avatar builder
  Source-pack registry loading with URL fallbacks
  Crisp procedural 64x64 preview
  Recipe JSON copy/download
  Prismcade manifest JSON copy/download
  64x64 PNG preview export
  Local source-sheet preview upload

data/prismcade/character-creator-packs.json
  Female and male source-pack status
  Slot schema for body, skin, face, hair, outfit, accessory, emote, animation
  Atlas and export contracts
  Safe export policy

data/prismcade/character-recipes/starter-avatar.recipe.json
data/prismcade/character-manifests/starter-avatar.manifest.json
  Sample export artifacts

games/pixel-fruit-arena/src/characters/prismcadeCreatorAdapter.js
  Adapter from creator recipe/manifest into the existing Pixel Fruit Arena character shape
```

## Source Pack Status

| Pack | Status | Notes |
| --- | --- | --- |
| `female-64-v1-2-body-update` | `creator_ready_beta` | Strongest current base. Has broad face, hair, emote, body, clothing, walking, and breathing coverage. |
| `male-64-v1-0-alpha` | `creator_ready_alpha` | Good base/head/hair foundation, but the uploaded copy is missing male clothing parity and needs normalized animation rows. |

The local user-provided source files are referenced for slicing and QA, but the raw `.kra` and sheet files are not committed in this PR:

```text
/Users/prismtek/Documents/Character Creation/64 Pixel Female Characters 1.2 Body Update.kra
/Users/prismtek/Documents/Character Creation/64 Pixel Female Characters 1.2 Body Update.png
/Users/prismtek/Documents/Character Creation/64 Pixel Female Characters.png
/Users/prismtek/Documents/Character Creation/64 Pixel Male Character 1.0.kra
```

## Safety Rule

The creator must not ship public body-only avatars. Base bodies are construction layers.

```text
internal base body: allowed
draft body-only export: allowed for internal construction only
public body-only export: blocked
runtime body-only export: blocked
starter outfit required: yes
```

The registry includes a `construction-body-only` outfit option only to prove that the public/runtime guard works.

## Run Locally

Serve the repo root so the creator can fetch `data/prismcade/character-creator-packs.json`:

```bash
cd /Users/prismtek/Prismtek/prismtek-apps
python3 -m http.server 4173
open http://localhost:4173/apps/prismcade-creator/character-station.html
```

The station tries these registry URLs in order:

```text
../../data/prismcade/character-creator-packs.json
/data/prismcade/character-creator-packs.json
data/prismcade/character-creator-packs.json
```

## Native Prismcade / Xcode Path

The native SwiftUI Prismcade hub includes a **Creator Tools** card for the Character Creation Station. From Xcode:

```bash
cd /Users/prismtek/Prismtek/prismtek-apps/apps/prismcade-native
xcodegen generate
open Prismcade.xcodeproj
```

Run the `PrismcadeMac` or `PrismcadeiOS` scheme, then use the **Open Creator** button after starting the repo-root HTTP server above.

The Xcode bundle includes:

```text
apps/prismcade-native/Shared/Resources/Creator/character-station-link.json
```

That file records the local dev-server command, station URL, and data-contract paths.

## Runtime Handoff

The sample manifest points at:

```text
games/pixel-fruit-arena/src/characters/prismcadeCreatorAdapter.js
```

The adapter maps creator slots into the existing Pixel Fruit Arena `createCharacter` shape and preserves creator provenance in `prismcade_creator`. It does not claim final combat sprite sheets exist yet; generated runtime animation sheets still need to be sliced from the source atlas.

## Validation

```bash
npm run prismcade:validate-character-creator-packs
```

The validator checks:

- female and male source packs exist
- female is `creator_ready_beta`
- male is `creator_ready_alpha`
- 64x64 atlas contract exists
- public body-only export remains blocked
- every slot option declares a procedural fallback
- sample recipe/manifest are valid
- Pixel Fruit Arena adapter can consume the sample recipe/manifest

## Known Limitations

- The live preview is procedural until source sheets are sliced into transparent atlas parts.
- Raw source art is not committed in this PR; licensing/provenance must be recorded before any binary source-pack import.
- Male pack remains alpha because clothing parity and normalized animation rows are missing.
- The native app opens the web station via local dev-server URL; it does not embed a WebKit runtime.

## Next Implementation Pass

1. Slice the female pack into transparent 64x64 atlas parts using the slot contract.
2. Add a seller license receipt or owner-approved provenance note before committing source binaries.
3. Add the missing male clothing/animation files or Prismcade-made starter male wardrobe.
4. Replace procedural preview drawing with atlas-backed canvas composition when sliced parts exist.
5. Generate runtime animation strips from exported recipes.
6. Promote saved recipes into Prismcade profile/customization storage.
