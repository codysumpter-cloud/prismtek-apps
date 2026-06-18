# Prismcade Animation Source Registry

Status: foundation contract.

Prismcade can reuse animation work from approved sources instead of rebuilding every motion from scratch.

## Source classes

1. First-party Prismtek games and packages.
2. User-owned uploaded sprite and animation packs.
3. External asset packs after their terms are recorded.
4. New Pixel Forge or hand-authored animation templates.

## First-party reuse

Animations already present in Pixel Fruit Arena, Buddy packs, Prismcade Fighter, and other Prismtek games can become platform sources when they are mapped to a reusable template.

Required mapping:

- source path
- template id
- view family
- frame size
- animation slots
- anchors
- layer model
- game compatibility notes

## External pack intake

For every external pack, record:

- pack name
- creator
- store page or receipt location
- allowed project use
- allowed modification
- allowed redistribution
- attribution requirement
- files imported into the repo
- files kept outside the repo
- mapped template ids

No external pack should become a portable Prismcade source until those fields are filled.

## Promotion rule

A pack starts as candidate, then moves to approved, then becomes platform_template only after a game uses it successfully and validation passes.

## Reuse rule

A game should not reference raw animation frames directly when a template id can be used instead. The desired path is source pack to template to game character.
