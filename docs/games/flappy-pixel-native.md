# Flappy Pixel Native

Native SpriteKit version of Flappy Pixel for Prismcade.

## Controls

- Click/tap/Space: flap.
- After game over: click/tap/Space restarts.

## Built

- 50 playable bird characters:
  - 12 Garden Birds spritesheet characters from the newly added local pack.
  - all 38 birds from the original `Birds by Onocentaur/birds-2x.png` sheet.
- Garden Birds use top-row flight frames for visible wing animation.
- Onocentaur sheet columns are directional poses, not flap frames; gameplay uses the right-facing pose for each row so the bird does not spin 360 degrees.
- Layered `Background_Hills_v1` pixel art, full-width tiled ground, and decorated gate obstacles were added for a coherent stage.
- Loose foreground white-square cloud sprites were removed during the visual QA pass because they obscured birds and gates.
- Curated CraftPix Weather Effects wind/rain sprites add subtle motion without covering gates or birds.
- Timer-driven gravity/flap loop.
- Scrolling gates, scoring, collision, game over, restart, local high score.

## Sprite notes

- Garden Birds source frame size: 64x64 sheets, displayed around 60x60.
- Onocentaur source frame size: 16x16 from the full sheet, displayed around 40x40.
- Runtime textures use SpriteKit nearest-neighbor filtering.
- Contact sheets:
  - `apps/prismcade-native/verification-screenshots/flappy-bird-contact-sheet.png`
  - `apps/prismcade-native/verification-screenshots/flappy-final-bird-facing-right-contact-sheet.png`
  - `apps/prismcade-native/verification-screenshots/garden-birds-source-contact-sheet.png`
  - `apps/prismcade-native/verification-screenshots/onocentaur-all-birds-contact-sheet.png`

## Verification

Receipt: `apps/prismcade-native/verification-screenshots/flappy-runtime-verification.json`

Snapshot: `apps/prismcade-native/verification-screenshots/flappy-runtime-snapshot.png`

Verified: bird picker appears, all Garden Birds and all original Onocentaur birds are available, selected bird sprite appears, bird animates without spinning, faces right, flap moves upward, gravity applies, obstacles spawn, score changes, collision/game-over works, restart works.

## Provenance

- Source gameplay reference: `games/flappy-pixel/`
- Site gameplay reference: `/Users/prismtek/Prismtek/prismtek-site/src/arcade/games/FlappyPixelGame.tsx`
- Site gameplay reference: `/Users/prismtek/Prismtek/prismtek-site/memory-wall-react/pixel-games/flappy-pixel/flappy-runtime.js`
- Art used: `/Users/prismtek/Documents/Libresprite/Birds by Onocentaur/birds-2x.png`
- License note from `ABOUT.txt`: free for personal and professional projects; attribution appreciated.
- Art used: `/Users/prismtek/Documents/Libresprite/Garden Birds_Download/Spritesheets/*.png`
- Garden Birds license note: user-approved local asset library; no local license file was found in that pack during this pass, so only curated 64x64 gameplay sheets were committed.
- Background used: `/Users/prismtek/Documents/Libresprite/Background_Hills_v1/_PNG/background1.png` through `background4.png`
- Background Hills license note from `_license.txt`: commercial use is allowed; credit is not required but appreciated.
- Weather used: `/Users/prismtek/Documents/Libresprite/Weather Effects Assets Pack Pixel Art/5 Wind/Wind1.png`
- Weather used: `/Users/prismtek/Documents/Libresprite/Weather Effects Assets Pack Pixel Art/5 Wind/Wind2.png`
- Weather used: `/Users/prismtek/Documents/Libresprite/Weather Effects Assets Pack Pixel Art/6 Weather/Rain/1.png`
- Weather Effects license note from `License.txt`: CraftPix file license.
- Excluded: `/Users/prismtek/Documents/Libresprite/Flappy_Bird_assets by kosresetr55.rar` to avoid copied Flappy Bird-style assets.

The final `prismtek-site` pass confirmed useful web Flappy mechanics, score metadata, and platform hooks. It did not provide better safe native bird art than the Garden Birds and Onocentaur sheets now curated into the app.
