# Using Portable Character Packs in Prismcade Games

Portable character packs are the bridge between character creation and reusable gameplay.

## Core idea

A Prismcade game should not hardcode animation strips for one character. Instead, it should ask for a **portable character pack** with canonical slots and sizes.

That means a game can load:

- the player's Prismtek avatar;
- a Buddy avatar;
- a Female avatar;
- or a future custom avatar;

without changing the game logic.

## Required contract

A side-view portable character pack should provide:

- `manifest.prismcade-character.json`
- `runtime/<size>/manifest.json`
- `runtime/<size>/atlas/atlas.png`
- per-slot frame folders
- per-slot strip sheets
- GIF previews for QA

## Runtime selection

Games should choose a runtime size based on their sprite tier:

- `32` / `48` for tiny arcade games
- `64` for standard portable avatar use
- `96+` for fighter/showcase use

## Canonical side-view slots

Games should prefer canonical slot names such as:

- `idle`
- `walk`
- `run`
- `jump`
- `fall`
- `land`
- `hurt`
- `death`
- `victory`
- combat or tool variants such as `basic`, `punch`, `sword_idle`, `sword_run`, `sword_stab`

## Game integration pattern

1. Load the character pack manifest with `loadPrismcadeCharacter`.
2. Choose the desired runtime size.
3. Load `runtime/<size>/manifest.json`.
4. Load the atlas image.
5. Bind game states to slot names.
6. If a slot is unavailable, fall back to a simpler slot such as `idle`, `walk`, or `basic`.

## Example loader use

```ts
import { getPrismcadeClip, loadPrismcadeCharacter } from "../../src/prismcade/characterLoader";

const character = await loadPrismcadeCharacter(
  "/game-assets/characters/prismtek-fixed-hair",
  { size: 64 },
);

const idleClip = getPrismcadeClip(character, "idle");
const atlasUrl = character.atlasUrl;
```

## Reuse rule

A character pack is reusable when:

- the slot names are canonical;
- the frame cells are normalized;
- the size tiers are standard;
- the pack includes manifests instead of one-off loose images.

## Example usages

### Platformer

Use `idle`, `walk`, `run`, `jump`, `fall`, `land`, `climb`, `hurt`, `death`, `victory`.

### Fighter / brawler

Use `idle`, `walk`, `run`, `jump`, `hurt`, `basic`, `punch`, `sword_*`, `victory`.

### Social lobby / catalog

Use `idle`, `walk`, and `victory`, or just a static `idle` frame / preview portrait.

## View limitations

A side-view pack is directly reusable for side-view games. Top-down, low-top-down, and isometric games should either:

- use a dedicated variant pack;
- use separate rotation exports;
- or fall back to profile/catalog usage until those variants exist.
