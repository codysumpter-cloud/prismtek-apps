# Gatete Mario Engine 9 Reference Policy

Status: **reference-only / quarantined mechanics reference**

Gatete Mario Engine 9 can be useful for studying GameMaker platformer architecture, but it must not be treated as a shippable Prismcade source template.

## Why it is quarantined

The project is framed around Mario-style engine behavior and features from multiple Nintendo platformers. Even when a repo has an open code license, that does not make all names, character identity, level concepts, sprites, sounds, or franchise-specific expression safe for Prismtek to ship.

## Allowed use

- Study platformer controller feel.
- Study jump, acceleration, friction, camera, slopes, and tile collision patterns.
- Study GameMaker project organization.
- Study how platformer objects are structured.
- Write Prismtek-owned notes that describe generalized mechanics.

## Blocked use

- Do not copy Mario sprites, sounds, level layouts, names, UI, branding, or franchise identity.
- Do not copy a full template into Prismcade.
- Do not ship Nintendo-like content.
- Do not use it as creator-facing starter content.
- Do not import it into game-local shipped paths.

## Safe Prismcade translation path

```txt
reference study
  -> generalized movement notes
  -> original Prismtek controller spec
  -> original score-platformer template
  -> manifest-only creator template
  -> safety/moderation review
```

## Good Prismcade takeaway

The useful part is not "Mario clone support." The useful part is a future **score-platformer template** with original Prismtek art, names, enemy types, pickups, and level rules.

## Promotion rule

This reference can never be promoted by copy. It can only inform a clean Prismtek-owned implementation after an originality pass.
