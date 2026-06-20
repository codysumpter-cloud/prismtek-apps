# Beat Em Up Buck

Beat Em Up Buck is the canonical Prismcade name for the Buck Borris game direction.

## Current status

The merged native Prismcade foundation currently contains a Buck Borris jump/dodge/pickup prototype using real Buck Borris frames. That prototype is useful as proof that the Buck art loads and animates, but it is not the intended final game loop.

## Target

The next polish pass should replace the prototype with a tiny native SpriteKit brawler/fighter:

- Buck Borris as the playable character.
- Side-view or 2.5D lane stage.
- Left/right movement.
- Up/down lane movement if feasible.
- Punch/attack button.
- At least one enemy.
- Hitboxes and hurtboxes.
- Enemy damage and Buck damage.
- Hit stun and knockback.
- Health bars.
- KO counter or score.
- Game-over and restart.
- Return to Prismcade hub.

## Engine direction

Use a native SpriteKit implementation unless a local OpenBOR, MUGEN, or Ikemen-style engine is found, license-compatible, and realistically buildable for both macOS and iOS.

The design should borrow concepts from MUGEN/OpenBOR-style data, not third-party assets:

- fighter states
- frame data
- animation states
- hitboxes
- hurtboxes
- attacks
- knockback
- stage/lane boundaries

Do not copy Streets of Rage, MUGEN, OpenBOR, Sega, Nintendo, or ripped/franchise assets.

## Current known Buck assets

The native foundation documented Buck Borris art from:

```text
/Users/prismtek/Documents/Libresprite/Buck Borris/sensible_frames/
```

The next pass should use LibreSprite and/or Python/Pillow to inspect all Buck frames and identify the best idle, walk/run, jump, hurt, and attack candidates. If dedicated attack frames do not exist, use the best available pose and document that a dedicated attack animation is still needed.

## Runtime gate

Do not call Beat Em Up Buck done until runtime verification proves:

- Buck appears as a real sprite.
- Movement works.
- Attack works.
- Enemy takes damage.
- Buck can take damage.
- Health/KO/score changes.
- Knockback or hit reaction is visible.
- Game-over/restart works.
- App-side snapshot or live screenshot exists.
