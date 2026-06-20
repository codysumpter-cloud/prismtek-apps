# Prismtek Buddies — Asset Policy

Practical rules for what art/assets may ship in the Prismtek Buddies app. See
`asset-inventory.md` for the per-pack provenance table.

## Always safe to ship

- **Bitbud pet.** Cody's own pet IP. Integrated as extracted PNG frames in
  `Shared/Resources/BitbudFrames/`. The source `.webp` atlas is never committed.
- **Original Prismtek pixel room tiles.** The wall tile, floor tile, and baseboard
  under `Shared/Resources/RoomArt/RoomTiles/` are small original PNGs for this
  app.
- **Original Prismtek pixel props.** Computer, desk, music player, and rug are
  original Prismtek props.
- **Cody's own Buddy art.** Desktop Buddy PNG variants and related Buddy showcase
  art are own IP and can be curated into `Shared/Resources/Buddies/`.

## Cleared for future use, but curate first

The itch.io free packs listed in `asset-inventory.md` are cleared ship-safe per
owner attestation where noted. Do not commit whole raw packs. Commit only curated
sprites/tiles needed by the app and record source URL/license/provenance.

## Excluded — do not ship

- **`fishing_free`.** Its bundled `license.txt` is explicitly non-commercial.
  It must not be included in any shipping build or committed to the repo.
- Copyrighted/franchise/ripped assets.
- Unclear-license assets.
- Full third-party raw packs.
- WebP source atlases unless intentionally documented and approved.

## Operating rules

1. Prefer original Prismtek assets and owner-created Buddy art.
2. Use LibreSprite to check dimensions, transparency, and hard pixel edges before
   committing curated sprites.
3. Record source URL, license, and files used in `asset-inventory.md`.
4. Keep `fishing_free` excluded.
5. Do not mutate the original Bitbud source atlas.
6. Do not spend PixelLab credits unless the user explicitly approves generation.
