# Beat Em Up Buck

Beat Em Up Buck is the native Prismcade Buck Borris brawler.

## Current status

Implemented in `apps/prismcade-native/Shared/Scenes/BuckBorrisScene.swift` as a native SpriteKit micro brawler.

## Controls

- macOS: arrows or WASD move Buck through the lane stage.
- macOS: Space or J attacks.
- macOS: K jumps.
- iOS: left side touch zones move; right side touch zones attack or jump.
- After game over: click, tap, Space, or J restarts.

## Built

- Buck Borris as playable sprite using curated local Buck frames.
- Native SpriteKit fighter states: idle, walk, attack, hurt, defeated.
- MUGEN/OpenBOR-inspired frame concepts: attack timing, active hit window, hurtboxes, hit stun, knockback, and lane bounds.
- One animated desert Mummy enemy sourced from the local CraftPix desert enemies pack.
- Enemy damage and Buck damage.
- Health bars for Buck and enemy.
- KO/score counter.
- CraftPix Weather Effects wind gusts and Shine hit animation.
- Pixel desert arena backdrop and SpriteKit tiled arena floor.
- Game-over and restart.
- Return to Prismcade hub through the native game host.

## Sprite notes

- Buck idle/run/jump/damaged frames are sourced from `/Users/prismtek/Documents/Libresprite/Buck Borris/sensible_frames/`.
- Buck attack frames use the curated `attacks_80x32.png` strip.
- Runtime Buck display size is 128x128 for idle/run/hurt and 220x88 while attacking so the wider punch frames read clearly.
- The Mummy enemy uses curated idle, walk, hurt, and death strips from the local CraftPix free desert enemy sprite sheets. No external fighter, Streets of Rage, MUGEN, OpenBOR, Sega, Nintendo, or ripped/franchise art is used.
- QA contact sheet: `apps/prismcade-native/verification-screenshots/buck-source-contact-sheet.png`

## Engine decision

Local engine/reference search found Prismtek-side evaluation material:

- `experiments/ikemen-prismtek-fighter/`
- `experiments/openbor-prismtek-brawler/`
- `games/prismcade-fighter/`
- `tools/prismcade-fighter/`

Those folders are useful references for fighter data concepts, but this launch polish pass did not integrate OpenBOR, MUGEN, or Ikemen because the native app must build cleanly for both macOS and iOS. Beat Em Up Buck therefore uses native SpriteKit.

## Verification

Receipt: `apps/prismcade-native/verification-screenshots/buck-runtime-verification.json`

Snapshots:

- `apps/prismcade-native/verification-screenshots/buck-combat-snapshot.png`
- `apps/prismcade-native/verification-screenshots/buck-runtime-snapshot.png`

Verified: Buck sprite appears, movement works, attack works, enemy takes damage, Buck takes damage, health bars update, knockback works, KO registers, score changes, game-over triggers, restart works.

## Provenance

- Buck art used: `/Users/prismtek/Documents/Libresprite/Buck Borris/sensible_frames/frames/idle/`
- Buck art used: `/Users/prismtek/Documents/Libresprite/Buck Borris/sensible_frames/frames/run/`
- Buck art used: `/Users/prismtek/Documents/Libresprite/Buck Borris/sensible_frames/frames/damaged/`
- Buck art used: `/Users/prismtek/Documents/Libresprite/Buck Borris/sensible_frames/strips/attacks_80x32.png`
- Background used: curated desert arena art from the local LibreSprite asset library.
- Enemy art used: `/Users/prismtek/Documents/LibreSprite/free-desert-enemy-sprite-sheets-pixel-art/5 Mummy/Mummy_idle.png`
- Enemy art used: `/Users/prismtek/Documents/LibreSprite/free-desert-enemy-sprite-sheets-pixel-art/5 Mummy/Mummy_walk.png`
- Enemy art used: `/Users/prismtek/Documents/LibreSprite/free-desert-enemy-sprite-sheets-pixel-art/5 Mummy/Mummy_hurt.png`
- Enemy art used: `/Users/prismtek/Documents/LibreSprite/free-desert-enemy-sprite-sheets-pixel-art/5 Mummy/Mummy_death.png`
- Weather used: `/Users/prismtek/Documents/Libresprite/Weather Effects Assets Pack Pixel Art/5 Wind/Wind1.png`
- Weather used: `/Users/prismtek/Documents/Libresprite/Weather Effects Assets Pack Pixel Art/5 Wind/Wind2.png`
- Hit effect used: `/Users/prismtek/Documents/Libresprite/Weather Effects Assets Pack Pixel Art/2 Shine/Shine1.png`
- Weather Effects license note from `License.txt`: CraftPix file license.
- CraftPix freebie license note: commercial game use is allowed; the source art files are not redistributed as standalone art packs.
- Excluded: Streets of Rage, MUGEN/OpenBOR/Ikemen asset packs, Sega/Nintendo/franchise/ripped assets.

## Known limitations

- The enemy is a single animated Mummy archetype.
- Buck has one basic punch chain timing window rather than a full move list.
- No audio is wired yet.

## Future moves

Add fighter data as small structs or JSON records with startup, active, recovery, damage, hit stun, knockback, and per-frame texture names. Additional enemy sprites can be added from safe Prismtek-owned or clearly licensed sheets and documented in the curated asset inventory.
