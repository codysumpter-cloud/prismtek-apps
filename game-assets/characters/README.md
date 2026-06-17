# Character Sprite Packs

This folder is the reusable character-sprite intake shelf for Prismtek games. Keep the original ZIPs here, then unpack only the needed sprites into a game-local asset folder such as `games/<game>/assets/characters/`.

## Prismtek character sprite packs

These are the current Buddy/Prismtek character packs from the sprite-generation workflow. Prefer these over generic template packs when building Prismtek player avatars, NPCs, Buddy UI appearances, or Pixel Forge examples.

| Pack | Canonical path | Role | Use notes |
| --- | --- | --- | --- |
| Normal Hair Guy | `game-assets/characters/Normal_Hair_Guy.zip` | Preferred young male base character | Current best male player/NPC base. Short dark-brown low-taper hair, less blushy face, 8-direction 124x124 transparent PNG rotation pack. Use this instead of ponytail/crazy-hair variants when the target is a normal masculine haircut. |
| Female Character Blue Hoodie | `game-assets/characters/Female_Character_Blue_Hoodie.zip` | Female hoodie base character | Use as the matching readable female/chibi base for player/NPC tests, avatar choices, and style matching against the normal-hair male pack. |
| Buddy detail pack | `game-assets/characters/Buddy (2).zip` | Buddy character reference | Use as the main Buddy sprite reference when the heart/detail version is wanted. Keep this as a protected source pack, not a scratch/export folder. |
| Buddy no-heart variant | `game-assets/characters/Buddy_no_heart.zip` | Buddy alternate reference | Use where the Buddy silhouette is wanted without the heart/chest-emblem detail. |
| Ponytail Guy | `game-assets/characters/Ponytail_Guy.zip` | Ponytail male variant | Use only when a tied-back/ponytail hairstyle is intentional. Do not use this as the normal low-taper male base. |
| Crazy Hair Guy | `game-assets/characters/Crazy_Hair_Guy.zip` | Messy-hair male source/variant | Keep as a variant or history/reference pack. This was the pack that tended to read too wild/ponytail-adjacent, so avoid it for the normal-hair base. |
| Crazy Hair Guy Fixed | `game-assets/characters/Crazy_Hair_Guy_Fixed.zip` | Cleaned no-ponytail correction | Use if the fixed no-ponytail correction is present in the repo and you specifically need the corrected version of the crazy-hair pack. |

## Naming rules

- Canonical filenames use underscores: `Normal_Hair_Guy.zip`, not `Normal Hair Guy.zip`.
- Remove browser/download suffixes like `(1)` before committing. For example, rename `Normal_Hair_Guy(1).zip` to `Normal_Hair_Guy.zip`.
- Preserve each ZIP's internal `metadata.json` and `rotations/*.png` structure.
- Do not flatten or rewrite these ZIPs unless there is a dedicated asset-normalization script and a receipt.
- Keep source packs here; game-specific copies belong under the game that consumes them.

## Runtime expectations

| Expectation | Target |
| --- | --- |
| Sprite style | Cute compact chibi pixel character, readable at small size |
| Transparency | Transparent PNG frames inside the ZIP |
| Rotation set | 8-direction rotation pack when available |
| Frame size | 124x124 for the current PixelLab character rotation packs |
| Metadata | `metadata.json` inside each pack |

## Current default recommendation

Use `Normal_Hair_Guy.zip` as the active male base, `Female_Character_Blue_Hoodie.zip` as the active female base, and `Buddy (2).zip` as the Buddy reference pack.
