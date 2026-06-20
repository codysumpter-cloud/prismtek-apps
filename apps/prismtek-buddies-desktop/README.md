# Prismtek Buddies Desktop

Cozy productivity room prototype for BUAP pet packages such as Bitbud.

This app loads a Codex pet package, animates it in a room, and connects pet states to focus and productivity events.

## Current scope

- Loads a local `pet.json` file through the browser file picker.
- Loads a local `spritesheet.webp` file through the browser file picker.
- Uses the observed Codex/Bitbud atlas profile: `1536x1872`, `192x208` cells, `8 columns x 9 rows`.
- Plays `idle`, `running-right`, `running-left`, `waving`, `jumping`, `failed`, `waiting`, `running`, and `review`.
- Adds a room shell with wall, shelf, window, desk, floor, pet zone, and focus XP card.
- Adds localStorage-backed to-do list and memo pad.
- Adds focus timer with 25 minute focus, 5 minute break, and count-up modes.
- Adds focus XP, level display, and gift placeholder after focus completion.
- Adds ambience placeholders for rain, keyboard, fireplace, cafe, custom audio, and bookmark input.
- Adds Mini Mode for compact use.
- Maps productivity events to pet states.
- Does not mutate the source pet package.
- Does not call PixelLab, image generation, Codex, or external music services.

## Run locally

```bash
cd apps/prismtek-buddies-desktop
npm install
npm run dev
```

Then open the Vite URL and choose:

```text
~/.codex/pets/bitbud/pet.json
~/.codex/pets/bitbud/spritesheet.webp
```

## Productivity state mapping

| Event | Pet state |
| --- | --- |
| Default room presence | `idle` |
| Add task / waiting on user | `waiting` |
| Timer running in count-up mode | `running` |
| Timer running in focus countdown | `review` |
| Task toggled / checking work | `review` |
| Task deleted / mock failure | `failed` |
| Focus session completed | `jumping` |
| Mock music play / greeting | `waving` |

## Product direction

The intended long-term product is a tiny always-on-screen Buddy companion app that can load BUAP/Codex pets, provide a cozy work room, support focus timers, notes, tasks, ambience, mini mode, Buddy/Lil Buddy state semantics, and eventually integrate with Obsidian, Apple Notes/Reminders, GitHub checks, PR status, and Prismcade.

This is intentionally a lightweight web prototype first. A macOS-native floating window, Tauri desktop wrapper, or SwiftUI shell can wrap the same pet package contract after the loader/player proves out.

The app should stay original Prismtek/BUAP and should not copy art, UI, audio, branding, or text from third-party products.
