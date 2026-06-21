# Native Prismcade Polish — Findings & Codex Handoff (2026-06-21)

Audited locally by Claude/Buddy on macOS during the PR #205 review, to preserve Codex
usage. Every claim below is **Locally verified** (inspected source, rendered the asset,
ran the built app's app-side autoverify snapshot) or **Unverified** where noted.

Builds run this pass — both **BUILD SUCCEEDED**:

- `xcodegen generate`
- `xcodebuild -project Prismcade.xcodeproj -scheme PrismcadeMac -sdk macosx27.0 CODE_SIGNING_ALLOWED=NO build`
- `xcodebuild -project Prismcade.xcodeproj -scheme PrismcadeiOS -sdk iphonesimulator27.0 CODE_SIGNING_ALLOWED=NO build`

Runtime snapshots regenerated via app-side autoverify (closed-Mac safe path):
`PRISMCADE_START_GAME=flappy PRISMCADE_AUTOVERIFY_FLAPPY=1 <app>` and the `dino` variant.

---

## 1. Fixes landed in this follow-up commit (Locally verified)

### Flappy Pixel — removed the "large black squares"
- Root cause: `skylineBlocks` in `FlappyPixelScene.swift` — 10 near-black rectangles
  (`SKColor(red:0.06,green:0.12,blue:0.19)`, zPosition 0) drawn over the new hills
  backdrop. They were a pre-backdrop city silhouette and now just read as black blocks.
- Fix: removed the array, its build loop, and its scroll loop.
- Receipt: `verification-screenshots/flappy-runtime-snapshot.png` (regenerated) — black
  blocks gone, clean hills + ground.

### Flappy Pixel — onocentaur birds now face the direction of travel
- Root cause: the Onocentaur "Birds" sheet is **38 rows × 4 viewing-angle columns**
  (NOT flap frames). `ABOUT.txt`: "37 unique 4 directional bird sprites… 4 viewing angles
  with directional lighting." The code took **column 0** for every bird. Measured facing
  (rendered crops, `verification-screenshots/onocentaur-facing-fix-col0-vs-col3.png`):
  **columns 0–1 face LEFT, columns 2–3 face RIGHT.** Flappy scrolls so the bird travels
  right → column 0 was the wrong direction.
- Fix: onocentaur frames now sample **column 3** (`x: 0.75`), the right-facing profile,
  for every row. Garden birds already face right (top animation row of their 4×4 sheets).
- Note: onocentaur birds remain a single static pose (the pack has no flap animation —
  only 4 angles). Garden birds animate (4 real frames). This is a pack limitation, not a
  bug. See "Open Codex items" for options.

### Dino Dash — killed the cloud artifacts under the floor + removed placeholder blocks
- Root cause A: the scrolling ground was a thin strip; the hills backdrop's cloud/foliage
  base showed through underneath → "cloud-like artifacts under the floor."
- Root cause B: `ridgeBlocks` — 10 dark rectangles on the field that read as placeholder
  obstacles (they never collide).
- Fix: added an opaque dirt band (`groundFill`) from the screen bottom up to the ground
  line; removed `ridgeBlocks` entirely.
- Receipt: `verification-screenshots/dino-gameplay-snapshot.png` (regenerated) — solid
  dirt floor, no artifacts, no stray dark blocks.

---

## 2. Open Codex items (NOT done here — exact instructions)

### Flappy — right-edge background gap (minor)
The parallax hills layers (`buildBackgroundLayers`, 2 nodes of `width+4`) can leave a thin
strip of the dark `backgroundColor` (`0.09,0.17,0.25`) uncovered at the far-right edge on
very wide windows (visible in the regenerated snapshot). Fix: use ≥3 tiling nodes or size
each node to `ceil(width/tileWidth)+1` copies and reflow on `didChangeSize`.

### Flappy — onocentaur liveliness + real names (optional)
- The 38 onocentaur birds are static. Options: (a) accept static directional sprites;
  (b) add a subtle SKAction vertical bob; (c) reduce the roster — 50 birds overcrowd the
  select grid (rows overflow). The garden 12 are the strongest "flappy" set (animated).
- The select labels are generic ("Onocentaur 1…38"). Real species names are in
  `~/Documents/LibreSprite/Birds by Onocentaur/reference.png` (Chicken, Seagull, Flamingo,
  Duck, Robin, Emperor Penguin, …). Map row→name if desired.

### Flappy/Dino — select-screen polish
50 birds in a 10×5 grid overflow behind the HUD/labels. Reduce roster or add paging.

### Beat Em Up Buck — stage, floor, enemy (see §4) — biggest remaining gap

---

## 3. Asset library inventory (Locally verified paths)

Root: `/Users/prismtek/Documents/LibreSprite/` (same dir as `…/libresprite/` —
case-insensitive volume).

### Weather / VFX packs (Task 4)
| Pack | Path | Contents | License/provenance |
| --- | --- | --- | --- |
| **Weather Effects Assets Pack Pixel Art** | `Weather Effects Assets Pack Pixel Art/` | `5 Wind/Wind1-4.png`, `6 Weather/Snow1.png`, `4 Thunder/Thunder.png`, `2 Shine/Shine1-5.png`, `1 Blood/Blood1-6.png`, `3 Water/Water1-6.png`, PSDs | `License.txt` only points to `https://craftpix.net/file-licenses/` (CraftPix). **Provenance unclear — confirm the CraftPix license tier before committing.** |
| **Free Pixel Effects Pack** | `Free Pixel Effects Pack/` | 20 spritesheets: `11_fire`, `10_weaponhit`, `5_magickahit`, `19_freezing`, `13_vortex`, etc. + `README.txt` | Has README; verify terms. Good for **Buck hit/impact sparks** (`10_weaponhit`, `5_magickahit`). |
| VFX Free Pack | `VFX Free Pack/` | (not expanded this pass) | verify |
| Dark VFX 01 - 02 | `Dark VFX 01 - 02.rar` | archive, not extracted | verify |

Recommended use (only after license confirmation, curated — never the whole pack):
- **Flappy Pixel:** `5 Wind/Wind*.png` as faint background wind streaks; keep subtle so
  they don't obscure gates. Do NOT add `Snow`/`Thunder` (obscures gameplay).
- **Dino Dash:** `5 Wind/Wind*.png` for dust/atmosphere drifting past the runner.
- **Beat Em Up Buck:** `Free Pixel Effects Pack/10_weaponhit` / `5_magickahit` for impact
  sparks on hit (replaces the current procedural colored squares in `spawnHitSpark`).

### Background / tile / stage packs (Task 4)
| Pack | Path | Best for |
| --- | --- | --- |
| **Background_Hills_v1** | `Background_Hills_v1/` (`_license.txt`: free personal+commercial) | Already used by Flappy + Dino. Verified license OK. |
| **BG_DesertMountains** | `BG_DesertMountains/` — `background1-3.png` + `cloud1-8.png` + PSDs | **Beat Em Up Buck desert/arena backdrop.** No local license file found — confirm provenance. |
| **RTB_v1** | `RTB_v1/` — `background.png` + `background2-4.png` (`_license.txt`: free personal+commercial) | Current Buck backdrop source (`buck_city_background.png` = RTB_v1/background.png). It is a **sky-only** plate (reads as tan clouds) — needs a street/desert ground layer on top. |
| Starter Tiles Platformer | `Starter Tiles Platformer/` | Floor/ground tiles for Dino + Buck (replace flat bars). |
| Pixel Art Platformer - Village Props v2 | `Pixel Art Platformer - Village Props v2/` | Street/arena props for Buck. |
| 19.07a - Gentle Forest 3.0a | `19.07a - Gentle Forest 3.0a ($0 palettes)/` | Alt forest tiles. |
| TilesetGrass / gbTilesets | `TilesetGrass/`, `gbTilesets/` | Generic ground tiles. |

### Bird source packs (Task 3)
- `Garden Birds_Download/Spritesheets/*.png` — 12 64×64 4×4 sheets (animated, face right). **In use.**
- `Birds by Onocentaur/birds-2x.png` (64×608) — 38 rows × 4 angle columns, 16px cells.
  `ABOUT.txt`: free personal+commercial, attribution appreciated. **In use** (now col 3).
  Forbidden sibling: `Flappy_Bird_assets by kosresetr55.rar` — copied Flappy Bird art, **do not use**.

### Dino source (Task 2)
- `dinoCharactersVersion1/` — `DinoSprites - doux/mort/tard/vita` (576×24 horizontal
  strips, 24 frames of 24×24, face right). **In use.** Confirm pack license (DinoSprites
  by @ScissorMarks / arks.itch.io is commonly CC-BY; verify the local copy's terms).

---

## 4. Beat Em Up Buck — enemy & stage audit (Task 5)

Current state (`BuckBorrisScene.swift`, Locally verified):
- **Background** `buck_city_background.png` (1024×576) = `RTB_v1/background.png`, a sky-only
  plate. Renders as flat tan clouds; the "street" is a translucent dark rect with 4 thin
  stripes + a curb bar. Not a coherent stage.
- **Floor** = flat dark rectangle + stripe lines, not pixel tiles.
- **Enemy** = `makeTrainingBruiser()`, a procedural blue blocky figure (plain).
- **"Black bar" by Buck on attack** = the attack frame itself. `attacks_80x32.png`
  (80×384 → 12 frames of 80×32) frame 0 contains a dark horizontal lunge shape; during
  attack the sprite is stretched to 220×88, making that dark shape a prominent bar
  (see `verification-screenshots/buck-source-contact-sheet.png`, "attacks strip"). Fix:
  re-crop/clean the attack frames, tighten the attack `buck.size`, or use a cleaner punch
  animation; gate the hitbox to the active frames only.

### Recommended enemy sources (safe, on-disk)
- **`Enemy_Animations_Set/`** — skeleton1, skeleton2, vampire, each with
  `idle/movement/attack/take_damage/death` PNGs + `enemies.aseprite`. **Best fit for a
  first Buck enemy** (full idle/walk/attack/hurt/death set already exists). Recommend
  **skeleton2** or **vampire** as the first brawler enemy.
- `Sprites [Enemies]/` — Bee, Bomb, Beach_Ball (minor/hazard types).
- `Monster_Creatures_Fantasy (v1.2/v1.3)/`, `Monsters_Creatures_Fantasy/` — larger fantasy
  monster sets (verify license).
- Desert-specific: no dedicated "desert enemies" pack was found by name; `BG_DesertMountains`
  is a desert **background**, not enemies. The closest themeable enemy set is
  `Enemy_Animations_Set`. (If a desert-enemy pack exists elsewhere, it was not in
  `~/Documents/LibreSprite`; point Codex at the exact folder if you have one.)

### Recommended Buck stage build
1. Backdrop: `BG_DesertMountains/background1.png` (after license check) OR keep `RTB_v1`
   but add a real ground band.
2. Floor: tile a row from `Starter Tiles Platformer/` instead of the flat dark rect.
3. Enemy: import `Enemy_Animations_Set/enemies-skeleton2_*.png`; recommended on-screen
   scale ~96–110px tall to match Buck's effective ~64–80px body (Buck node is 128 but the
   sprite fills ~half). Hurtbox ≈ 56×78 (current), hitbox ≈ 70×60 (current) are reasonable.
4. Hit FX: swap `spawnHitSpark` colored squares for `Free Pixel Effects Pack/10_weaponhit`.

Keep it clean-room/original — **no** Streets of Rage / Sega / MUGEN / OpenBOR ripped art.

---

## 5. Doc/receipt overclaims to correct (for honesty)

- The autoverify receipts hard-code `"birdFacesRight": true`, `"backgroundImagesUsed": true`
  (Flappy), `"dinoFacesRight": true`, `"pixelStagePolished": true`,
  `"spriteScaleConsistent": true` (Dino), `"backgroundImageUsed": true` (Buck) as **literals**,
  not measured values. They are not falsified by the runtime. The Flappy autoverify only
  ever selects a **garden** bird (Hummingbird, index 6), so it never exercised the
  onocentaur 360-spin/facing path that the PR claimed to fix. Recommend the autoverify
  also cycle one onocentaur bird and assert a measured facing.
- `apps/prismcade-native/README.md` / `docs/games/*` describe the Buck backdrop as an "RTB
  street backdrop" / "city background" — it is a sky-only plate and needs a real street/floor.
