# Prismcade Character Factory

Status: **required readiness layer**

Prismcade is not truly creator-ready until the repo can turn reviewed Buddy, Prismtek, and Female source assets into reusable game characters with clothing, hairstyles, derivative Buddys, and built-in animation manifests.

The game manifest/catalog work is the track. The character factory is the engine that lets creators actually make playable avatars and NPCs from the assets Prismtek is already producing.

## Source assets already tracked

The repo already has a PixelLab character export registry at:

```txt
data/integrations/pixellab-character-export-registry.json
```

That registry includes these important source templates:

| Source | Registry variant | Current state | Factory role |
| --- | --- | --- | --- |
| Buddy | `buddy` | 103 observed animations; export-ready, needs curation/polish | New Buddys, mascot/NPC/player, personality emotes |
| Prismtek | `prismtek` | 56 observed animations; one failed NE job; needs polish | Main player/avatar/fighter base |
| Female Blue Hoodie | `female-character-blue-hoodie` | export-ready rotations; needs animation jobs | Female avatar base, hoodie/clothing/hair source |
| Ponytail Guy | `ponytail-guy` | export-ready rotations; needs animation jobs | Ponytail hairstyle reference and alternate base |
| BMO 4-dir group | `bmo-4dir-source-group` | 4-direction source group | Compact 4-dir characters or rebuild source |

Machine-readable Prismcade registry:

```txt
data/prismcade/character-template-registry.json
```

Validator:

```bash
npm run prismcade:validate-characters
```

## First playable runtime slice

Pixel Fruit Arena now has a game-local Prismcade roster bridge:

```txt
games/pixel-fruit-arena/data/characters/prismcade_playable_roster.json
games/pixel-fruit-arena/src/characters/prismcadeRoster.js
games/pixel-fruit-arena/assets/characters/prismcade-pixellab/
```

Current playable entries:

- Buddy;
- Prismtek;
- Prismtek Jones;
- Female Blue Hoodie;
- Ponytail Guy;
- Prismtek Pixel God;
- PrismBot Pixel God.

Buddy and Prismtek use normalized PixelLab animation exports. Prismtek Jones, Female Blue Hoodie, Ponytail Guy, Prismtek Pixel God, and PrismBot Pixel God are playable now with rotation-derived strips and still need PixelLab animation-job polish before being called final production animation packs.

Validation:

```bash
npm --prefix games/pixel-fruit-arena run validate:prismcade-roster
npm run prismcade:validate:all
```

BMO remains a 4-direction source group. Preserve that source format unless a real 8-direction derivative is generated.

## What character-ready means

A source packet is not game-ready just because PixelLab says it can be downloaded.

A Prismcade character is game-ready only after it has:

1. a reviewed source template;
2. 64x64 game-ready frames or an explicit approved alternate size;
3. transparent-background sprite sheets;
4. canonical animation slots;
5. provenance/rights notes;
6. checked loops and readable pivots;
7. clothing and hairstyle compatibility when the character is used as a template;
8. a game-local or package-level character manifest.

## Required factory outputs

```txt
packages/game-assets/characters/{characterId}/
  character.json
  PROVENANCE.md
  sprites/
    idle.png
    walk.png
    run.png
    ...
  animations/
    idle.json
    walk.json
    run.json
    ...
```

Do not commit raw PixelLab export packets as production assets. Commit only reviewed, normalized, game-ready outputs.

## Clothing and hairstyle system

Prismcade character templates need layers that can be mixed and reused:

| Layer | Examples |
| --- | --- |
| `head` | Buddy face, Prismtek face, Female face |
| `hair` | normal hair, low taper, ponytail, messy top, hood up |
| `torso` | blue hoodie, teal jumpsuit, arcade jacket, Buddy shell |
| `legs` | pants, shorts, jumpsuit bottom |
| `feet` | dark shoes, sneakers, Buddy feet |
| `accessory` | glasses, headset, backpack, badge |

Layer outputs should preserve frame alignment across all animation slots.

## New Buddy rule

A new Buddy must not be just a static sprite.

Minimum built-in animations:

- idle;
- walk;
- run;
- hurt;
- one action animation, such as melee, cast, projectile, or helper action;
- victory;
- defeat;
- one personality emote.

## First implementation target

The next code slice should make `apps/prismcade-creator` read:

```txt
data/prismcade/character-template-registry.json
```

and expose:

1. source template picker;
2. body/base picker;
3. hair picker;
4. clothing picker;
5. required animation checklist;
6. export plan JSON;
7. Pixel Forge / PixelLab job plan handoff.

## Validation commands

```bash
npm run prismcade:validate
npm run prismcade:validate-characters
```

Future combined command:

```bash
npm run prismcade:validate:all
```
