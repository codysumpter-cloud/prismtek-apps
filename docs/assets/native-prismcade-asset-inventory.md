# Native Prismcade Asset Inventory

## Search Receipts

Deep inventory outputs were written to:

- `/tmp/prismcade-native-asset-inventory.txt` with 131754 paths.
- `/tmp/prismcade-native-bird-search.txt` with 4939 paths.
- `/tmp/prismcade-native-dino-search.txt` with 167 paths.
- `/tmp/prismcade-native-buck-search.txt` with 113 paths.
- `/tmp/prismcade-native-libresprite-deep.txt` with 85292 paths.
- `/tmp/prismtek-site-native-prismcade-search.txt` with 213 paths.
- `/tmp/prismcade-launch-polish-asset-inventory.txt` with 131902 paths.
- `/tmp/prismcade-launch-polish-bird-search.txt` with 226 paths.
- `/tmp/prismcade-launch-polish-dino-search.txt` with 232 paths.
- `/tmp/prismcade-launch-polish-buck-engine-search.txt` with 129 paths.

`/Users/prismtek/Prismtek/prismtek-site` was missing during the initial implementation receipt, then cloned locally before the final merge pass and searched. Relevant findings:

- `src/arcade/games/FlappyPixelGame.tsx`
- `memory-wall-react/pixel-games/flappy-pixel/flappy-runtime.js`
- `memory-wall-react/pixel-games/flappy-pixel/flappy-core.js`
- `src/data/game-catalog.js`
- `docs/prismcade/*`
- `functions/lib/prismcade.js` and Prismcade API/player shell files

These files provide useful Flappy Pixel mechanics, scoring metadata, and Prismcade platform direction. They did not contain safer or better native bird, dinosaur, or Buck Borris sprites than the curated local LibreSprite assets already imported.

## Folders Searched

- `~/Downloads`
- `~/Documents`
- `~/Desktop`
- `~/Documents/Mac`
- `~/Documents/LibreSprite`
- `~/Documents/libresprite`
- `/Users/prismtek/Documents/LibreSprite`
- `/Users/prismtek/Documents/libresprite`
- `/Users/prismtek/Prismtek/prismtek-apps`
- `/Users/prismtek/Prismtek/prismtek-site`

## Assets Used

- Flappy Pixel birds: `/Users/prismtek/Documents/Libresprite/Garden Birds_Download/Spritesheets/*.png`, 12 curated 64x64 bird sheets imported as playable characters.
- Flappy Pixel birds: `/Users/prismtek/Documents/Libresprite/Birds by Onocentaur/birds-2x.png`, all 38 original bird rows imported through the full sheet. Its columns are directional poses, so the native runtime uses the right-facing pose for each row instead of cycling directions as animation frames.
- Flappy Pixel environment: `/Users/prismtek/Documents/Libresprite/Background_Hills_v1/_PNG/background1.png` through `background4.png`.
- Dino Dash: four `dinoCharactersVersion1/sheets/DinoSprites - *.png` sheets: `doux`, `mort`, `tard`, and `vita`.
- Dino Dash environment: `/Users/prismtek/Documents/Libresprite/Background_Hills_v1/_PNG/background1.png` through `background4.png`.
- Beat Em Up Buck: `/Users/prismtek/Documents/Libresprite/Buck Borris/sensible_frames/frames/idle/*.png`, `run/*.png`, `damaged/*.png`, plus `sensible_frames/strips/attacks_80x32.png`.
- Beat Em Up Buck environment: `/Users/prismtek/Documents/Libresprite/RTB_v1/background.png`.
- Beat Em Up Buck enemy: original procedural pixel Training Bruiser assembled in SpriteKit.

## License / Provenance Notes

- Onocentaur birds: `ABOUT.txt` allows free personal and professional use; attribution appreciated.
- Garden Birds: user-approved local asset library; no local license file was found in the pack during this pass, so only curated gameplay sheets were imported.
- Background Hills: `_license.txt` allows personal and commercial use; credit is not required but appreciated.
- RTB backdrop: `_license.txt` allows personal and commercial use; credit is not required but appreciated.

## QA / Contact Sheets

- `apps/prismcade-native/verification-screenshots/flappy-bird-contact-sheet.png`
- `apps/prismcade-native/verification-screenshots/flappy-final-bird-facing-right-contact-sheet.png`
- `apps/prismcade-native/verification-screenshots/garden-birds-source-contact-sheet.png`
- `apps/prismcade-native/verification-screenshots/onocentaur-all-birds-contact-sheet.png`
- `apps/prismcade-native/verification-screenshots/dino-source-contact-sheet.png`
- `apps/prismcade-native/verification-screenshots/buck-source-contact-sheet.png`

## Engine References

The Buck polish pass searched local OpenBOR/MUGEN/Ikemen/fighter references and found Prismtek evaluation folders:

- `experiments/ikemen-prismtek-fighter/`
- `experiments/openbor-prismtek-brawler/`
- `games/prismcade-fighter/`
- `tools/prismcade-fighter/`

No external fighter engine was integrated. Beat Em Up Buck uses native SpriteKit so the app remains buildable for macOS and iOS.

## Assets Skipped

- `fishing_free`: excluded by prior non-commercial note.
- `/Users/prismtek/Documents/Libresprite/Flappy_Bird_assets by kosresetr55.rar`: skipped to avoid copied Flappy Bird assets.
- Weather Effects Assets Pack Pixel Art: skipped for this pass because the local license file points to external CraftPix license pages rather than embedding a clear reusable license.
- BG_DesertMountains and other newly added packs without local clear provenance: skipped or deferred.
- Google/Chrome Dino assets: not used.
- Streets of Rage, MUGEN, OpenBOR, Ikemen, Sega, Nintendo, franchise, ripped, or unclear fighter assets: not used.
- Raw packs and archives: not committed.
- Unclear-license downloads: not committed.

## LibreSprite

Verified:

- `/Applications/LibreSprite.app/Contents/MacOS/libresprite`
- `/Users/prismtek/Library/Application Support/LibreSprite/scripts/PixelLab.js`

LibreSprite was available for inspection/export; no PixelLab paid generation was used.
