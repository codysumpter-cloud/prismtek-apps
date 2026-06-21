# Buck Borris Mini-Game

This page is retained as a historical receipt for the first native Buck Borris prototype.

The canonical direction is now:

```text
Beat Em Up Buck
```

See:

```text
docs/games/beat-em-up-buck.md
```

## Historical prototype

The merged native Prismcade foundation originally contained a Buck Borris jump/dodge/pickup prototype using real Buck Borris frames.

That prototype verified:

- Buck Borris visible as the player using real `run_00` through `run_03` frames.
- Small side-scrolling jump/dodge/collect loop.
- Hazards, pickups, score, game over, restart, local high score.

## Replacement

This prototype has been replaced in `apps/prismcade-native/Shared/Scenes/BuckBorrisScene.swift` by Beat Em Up Buck: a tiny SpriteKit brawler/fighter with attacks, an enemy, hitboxes, health, knockback, KO scoring, and a lane stage.

## Current verification

Receipt:

```text
apps/prismcade-native/verification-screenshots/buck-runtime-verification.json
```

Snapshots:

```text
apps/prismcade-native/verification-screenshots/buck-combat-snapshot.png
apps/prismcade-native/verification-screenshots/buck-runtime-snapshot.png
```

## Provenance

The prototype used local Buck Borris LibreSprite assets, including:

```text
/Users/prismtek/Documents/Libresprite/Buck Borris/sensible_frames/frames/run/run_00.png
/Users/prismtek/Documents/Libresprite/Buck Borris/sensible_frames/frames/run/run_01.png
/Users/prismtek/Documents/Libresprite/Buck Borris/sensible_frames/frames/run/run_02.png
/Users/prismtek/Documents/Libresprite/Buck Borris/sensible_frames/frames/run/run_03.png
```

The final `prismtek-site` pass did not find Buck, Borris, or Boris game assets. The native app used the local Buck Borris LibreSprite folder assets instead of placeholder player art.
