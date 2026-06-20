# Prismtek Buddies — Asset Policy

Practical rules for what art/assets may ship in the Prismtek Buddies app.
See `asset-inventory.md` for the per-pack provenance table.

## Always safe to ship

- **Bitbud pet.** Cody's own pet IP. Already integrated as extracted PNG frames
  in `Shared/Resources/BitbudFrames/`. The source `.webp` atlas is never
  committed.
- **Original SwiftUI shapes / gradients / colors.** Everything drawn in code
  (the cozy room, desk, shelf, window, room themes) is original Prismtek work.
- **Cody's own Buddy art.** `Buddy_showcase.gif`, `Buddy_rotations_8dir.gif`,
  `~/Desktop/Buddy-*.png/.webp`, repo `Buddy_Grok_64_showcase.gif`. Own IP.

## Cleared for future use (owner-attested), but NOT bundled

The itch.io free packs listed in `asset-inventory.md` are **cleared ship-safe
per the owner (Cody)**. This clearance is owner-attested: the free/commercial
terms are confirmed on each pack's itch.io page, **not** inferred from the files
bundled inside each download (several packs ship with no license file at all).

- These packs are cleared for **future** use in the app.
- **This pass bundles none of them.** No third-party pack is committed to the
  repo in this change. The room-theme layer added in this pass uses original
  SwiftUI colors only — no bitmaps.

## Excluded — do not ship

- **`fishing_free`.** Its bundled `license.txt` is explicitly **non-commercial**:
  the assets "can't be used in any commercial project, resold/redistributed,
  even if modified." Prototype/experimentation only. **Must not** be included in
  any shipping build or committed to the repo.

## Operating rules

1. **Prefer original / generated Prismtek assets** for anything that ships
   (SwiftUI shapes, Bitbud, owner art, generated sprites).
2. **No third-party pack is bundled without an explicit per-pack decision** and
   a corresponding update to `asset-inventory.md`.
3. **Never commit `fishing_free`** or any non-commercial-licensed asset.
4. **Never commit the Bitbud `.webp` source atlas** — only the extracted PNG
   frames already in `Shared/Resources/BitbudFrames/`.
5. When in doubt about a pack's terms, treat it as **not ship-safe** until the
   owner confirms the itch.io page terms.
