# Prismtek Buddies Desktop

Prototype desktop-style Buddy companion app for Codex pet packages such as Bitbud.

This is the first Prismtek Buddies app surface: a cozy room / desktop companion prototype that can load a Codex pet package, render its atlas, and switch between animation states.

## Current scope

- Loads a local `pet.json` file through the browser file picker.
- Loads a local `spritesheet.webp` file through the browser file picker.
- Uses the observed Codex/Bitbud atlas profile:
  - atlas size: `1536x1872`
  - cell size: `192x208`
  - grid: `8 columns x 9 rows`
- Plays the known Bitbud/Codex pet states:
  - `idle`
  - `running-right`
  - `running-left`
  - `waving`
  - `jumping`
  - `failed`
  - `waiting`
  - `running`
  - `review`
- Includes a state picker, play/pause, zoom control, and frame scrubber.
- Does not mutate the source pet package.
- Does not call PixelLab, image generation, or Codex.

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

## Product direction

The intended long-term product is a tiny always-on-screen Buddy companion app that can:

- load BUAP/Codex pets
- animate them on the desktop
- switch mood/state based on work context
- support Buddy/Lil Buddy states
- grow into a cozy room / lofi mode
- eventually integrate with Obsidian, GitHub checks, PR status, and Prismcade

## Notes

This is intentionally a lightweight web prototype first. A macOS-native floating window, Tauri desktop wrapper, or SwiftUI shell can wrap the same pet package contract after the loader/player proves out.
