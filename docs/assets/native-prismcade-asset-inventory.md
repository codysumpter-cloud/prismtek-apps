# Native Prismcade Asset Inventory

## Search Receipts

Deep inventory outputs were written to:

- `/tmp/prismcade-native-asset-inventory.txt` with 131754 paths.
- `/tmp/prismcade-native-bird-search.txt` with 4939 paths.
- `/tmp/prismcade-native-dino-search.txt` with 167 paths.
- `/tmp/prismcade-native-buck-search.txt` with 113 paths.
- `/tmp/prismcade-native-libresprite-deep.txt` with 85292 paths.
- `/tmp/prismtek-site-native-prismcade-search.txt` with 213 paths.

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

- Flappy Pixel: `/Users/prismtek/Documents/Libresprite/Birds by Onocentaur/birds-2x.png`, row 0 curated into `bird_flap_up.png`, `bird_glide.png`, `bird_flap_down.png`.
- Dino Dash: four `dinoCharactersVersion1/sheets/DinoSprites - *.png` sheets.
- Buck Borris: `/Users/prismtek/Documents/Libresprite/Buck Borris/sensible_frames/frames/run/*.png` and selected curated Buck strips.

## Assets Skipped

- `fishing_free`: excluded by prior non-commercial note.
- `/Users/prismtek/Documents/Libresprite/Flappy_Bird_assets by kosresetr55.rar`: skipped to avoid copied Flappy Bird assets.
- Google/Chrome Dino assets: not used.
- Raw packs and archives: not committed.
- Unclear-license downloads: not committed.

## LibreSprite

Verified:

- `/Applications/LibreSprite.app/Contents/MacOS/libresprite`
- `/Users/prismtek/Library/Application Support/LibreSprite/scripts/PixelLab.js`

LibreSprite was available for inspection/export; no PixelLab paid generation was used.
