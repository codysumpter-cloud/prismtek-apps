# Asset intake plugin contract

Asset intake plugins make free/open asset sources usable while protecting Prismtek games from license drift, style soup, and unknown-origin files.

## Core rule

An asset intake plugin may collect, inspect, document, convert, and promote assets. It must not make raw intake material a runtime dependency for a shipped game.

The plugin should make it harder to accidentally ship a messy asset soup.

## Required commands

| Command | Purpose | Safe first implementation |
| --- | --- | --- |
| `intake` | Place raw source material in a quarantined intake path with provenance. | Create or update receipt metadata only. |
| `validate` | Check required metadata, license fields, and forbidden output paths. | Scan manifests and report missing fields. |
| `promote` | Copy reviewed originals/derivatives into a game-local asset folder with a receipt. | Refuse until review metadata is complete. |

## Required metadata

Every asset or pack must record:

- source adapter id;
- source URL or upload source;
- author/creator when known;
- license and attribution requirements;
- commercial-use status when relevant;
- original file names and hashes when practical;
- target game and intended use;
- style notes;
- derivative/edit notes;
- promotion destination;
- reviewer/date or automation receipt.

## Intake receipt schema

```json
{
  "schemaVersion": 1,
  "assetIntakeId": "opengameart-flame-vfx-pack",
  "sourceAdapterId": "opengameart-assets",
  "sourceUrl": "exact source page",
  "sourceAuthor": "author name or unknown",
  "license": "exact license or unknown",
  "attributionRequired": true,
  "attributionText": "required credit text or pending",
  "commercialUse": "allowed | blocked | unknown",
  "rawPaths": [],
  "rawHashes": [],
  "targetGame": "pixel-fruit-arena",
  "targetUse": "flame awakened VFX reference",
  "styleReview": "pending | approved | blocked",
  "licenseReview": "pending | approved | blocked",
  "promotionStatus": "raw-intake | metadata-recorded | style-reviewed | converted | promoted | shippable",
  "warnings": [],
  "errors": []
}
```

## Promotion rules

A promoted asset must be:

1. legal to use for the target distribution path;
2. style-compatible with the target game;
3. converted into the game’s expected size, format, and naming scheme;
4. referenced by a game-local manifest;
5. validated by a repeatable command.

Promotion should produce a second receipt describing the final destination and transformations.

## Conversion policy

Conversion is allowed when it makes an asset fit the target game. Examples:

- resize to target tile size;
- crop to sprite frame bounds;
- palette reduce;
- rename to game naming convention;
- split sprite sheet into frames;
- combine frames into a game-local atlas;
- create placeholder icons from reviewed source art;
- convert source audio to game-supported format.

Conversion does not erase attribution or license requirements.

## Forbidden behavior

Asset intake plugins must not:

- promote zip/rar/7z archives directly into shipped game folders;
- treat `free` as equivalent to `safe to ship`;
- drop attribution requirements;
- overwrite hand-authored game assets without a diffable receipt;
- mix radically different art styles just because files are available;
- promote fonts without explicit font-license review;
- promote unknown-origin files into public release paths;
- create game runtime references to `game-assets/intake/**`.

## Style review dimensions

A style review should check more than whether a file is pixel art.

| Dimension | What to check |
| --- | --- |
| Scale | Does it match the game’s sprite/tile size? |
| Silhouette | Is it readable during motion/combat? |
| Palette | Does it match saturation, contrast, and mood? |
| Outline | Does line thickness match surrounding art? |
| Perspective | Side-view, top-down, isometric, UI, or 3D? |
| Animation | Does frame count/timing fit the game feel? |
| UX clarity | Does it improve readability instead of adding clutter? |
| Performance | Is the file size reasonable for web/handheld targets? |

## Target game notes

### Pixel Fruit Arena

- Prefer clear 64x64-ish character silhouettes.
- Ability icons should be readable at HUD size.
- VFX should show direction and hit timing.
- Awakened effects should look stronger without hiding the player.
- Avoid top-down RPG sprites for side-view fighters unless converted deliberately.

### TamerNet

- Creature assets must be readable in overworld and battle context.
- Tile assets should not fight the camera perspective.
- UI icons should support taming, status, and creature identity.

### Spin Street Showdown

- Top parts need strong part silhouettes.
- Stadium/tip effects must help physics readability.
- Avoid cyber UI overload if it distracts from the toy/battle-top fantasy.

### Wildlands: Critter Clash

- Keep the existing itch/web structure stable.
- Match the established world/tile presentation.
- Add assets through manifests, not ad hoc direct loads.

## Validation behavior

The validator should fail when:

- a shipped game references an intake path;
- a promoted asset has unknown license;
- required attribution is missing;
- a font has no license review;
- a raw archive is placed in a runtime folder;
- destination path is outside the repo;
- a manifest has duplicate ids.

The validator can warn when:

- style review is pending;
- file hashes are missing;
- commercial-use status is unknown for non-release experiments;
- an asset is in intake but unused.

## CI expectations

CI should be able to run without downloading large asset packs. Prefer metadata checks and fixture manifests. Full asset scans can be optional or local-only until the repo has a dedicated artifact/cache plan.

## Minimal first plugin shape

A safe first implementation:

```bash
node tools/integrations/assets/validate-intake.mjs --dry-run
```

It should:

1. Load `data/integrations/asset-source-adapters.json`.
2. Validate adapter fields.
3. Search for intake manifests.
4. Report missing provenance.
5. Refuse to promote anything.

That gives immediate safety value without pretending all uploaded packs are already sorted.

## Graduation checklist

Before a source adapter can promote assets:

- exact source metadata exists;
- license is reviewed;
- attribution is captured;
- target game is declared;
- style review is complete;
- conversion notes exist;
- destination path is allowed;
- game-local manifest is updated;
- validation passes.
