# Prismtek Arcade Cross-Platform Migration

This document tracks the verified migration path for moving Prismtek arcade games from `prismtek-site` and mega-app sources into `prismtek-apps` as first-class game projects.

## Verified target

- Target repo: `codysumpter-cloud/prismtek-apps`
- Target game root: `games/`
- Related tracker: <https://github.com/codysumpter-cloud/prismtek-apps/issues/154>

## Verified source repos

- `codysumpter-cloud/prismtek-site`
- `Automind-Lab/prismtek.dev_mega-app`
- `Automind-Lab/prismtek.dev_mega-appALL`

## Verified source game inventory

`prismtek-site/src/arcade/game-catalog.tsx` and `prismtek-site/src/arcade/shared.ts` currently define five active arcade games:

| Game ID | Name | Source component | Target path |
| --- | --- | --- | --- |
| `flappy-pixel` | Flappy Pixel | `src/arcade/games/FlappyPixelGame.tsx` | `games/flappy-pixel/` |
| `crossy-pixel` | Crossy Pixel | `src/arcade/games/CrossyPixelGame.tsx` | `games/crossy-pixel/` |
| `pixel-snake` | Pixel Snake | `src/arcade/games/PixelSnakeGame.tsx` | `games/pixel-snake/` |
| `neon-brick-breaker` | Neon Brick Breaker | `src/arcade/games/NeonBrickBreakerGame.tsx` | `games/neon-brick-breaker/` |
| `pixel-stacker` | Pixel Stacker | `src/arcade/games/PixelStackerGame.tsx` | `games/pixel-stacker/` |

The target repo currently documents only these games:

- `games/pixel-fruit-arena/`
- `games/tamernet-battle-sandbox/`

## Mega-app inspection result

Both inspected mega-app repos currently present as platform monorepos from their root README/package manifests:

- `apps/web`
- `apps/api`
- `packages/core`
- `packages/app-factory`
- `packages/sandbox`

Connector code search did not find additional game sources using `game`, `arcade`, `Snake`, or `Pixel Snake`. Treat that as a best-effort search result, not proof that no game files exist if the index is stale.

## Correct migration order

1. Import the five verified arcade games from `prismtek-site` into `games/`.
2. Copy only the shared arcade files needed to build them.
3. Add one README per game with honest run/build/test instructions.
4. Add browser/PWA smoke checks.
5. Add itch.io HTML export scripts.
6. Add desktop/mobile wrapper packaging after the web builds are green.
7. Add Nintendo DS homebrew ports as separate source trees.

## Shared files expected from `prismtek-site`

The React/browser imports depend on these shared modules or equivalents:

- `src/arcade/shared.ts`
- `src/arcade/types.ts`
- `src/arcade/random.ts`
- `src/arcade/useAnimationFrame.ts`
- `src/arcade/components/PlayfieldFrame.tsx`
- `src/arcade/games/pixel-snake/*` where required by `PixelSnakeGame.tsx`

## Platform matrix

| Platform | Target output | Expected strategy | Current truth rule |
| --- | --- | --- | --- |
| Browser | Static web build | Vite/React build per game or shared arcade package | Claim support only after the game boots and a smoke test passes. |
| itch.io | HTML5 zip | Zip each static web build with `index.html` at archive root | Claim support only after artifact generation is scripted. |
| Windows | `.exe` or zipped app | Tauri, Electron, or WebView shell | Claim support only after artifact exists in Releases. |
| macOS | `.app`/`.dmg` or zipped app | Tauri, Electron, WebView shell, or native wrapper | Claim support only after build/signing path is documented and validated. |
| iOS | TestFlight/App Store build | Native Swift wrapper, WKWebView wrapper, or rewritten SpriteKit implementation | Claim support only after Xcode project and simulator/device build passes. |
| Android | `.apk`/`.aab` | Capacitor/TWA/WebView wrapper or native implementation | Claim support only after Gradle build artifact exists. |
| Nintendo DS | `.nds` homebrew ROM | Dedicated DS homebrew implementation | Never claim React/browser code runs on DS. Port gameplay to DS constraints. |

## Nintendo DS porting notes

The user supplied these DS Game Maker references:

- YouTube guide: <https://youtu.be/LYeYQ9lYP_M?is=CPxiPLgGppiE4wIJ>
- Archive entry: <https://archive.org/details/Install520>
- Setup repo: <https://github.com/DigitalDesignDude/DS-Game-Maker-5-Setup>

The setup repo describes DS Game Maker as Windows software for Nintendo DS homebrew development using drag-and-drop actions, C, and DBAS. It documents a devkitPro folder, `DEVKITPRO` / `DEVKITARM` environment variables, `.NET Framework 3.5`, and test-compiling a blank `.NDS` file.

Do not vendor unknown installer binaries or proprietary Nintendo SDK material into `prismtek-apps`. Use reproducible source/toolchain docs and keep any local-only tools out of git unless licensing is confirmed.

### Recommended DS port order

1. `pixel-stacker` — simplest timing/input loop.
2. `flappy-pixel` — simple one-button loop.
3. `neon-brick-breaker` — paddle/ball collision loop.
4. `crossy-pixel` — more level/hazard state.
5. `pixel-snake` — start local-only; live PvP is a separate networking project.

## Acceptance criteria before marking complete

- Root README lists all games.
- Each migrated game has a real `games/<slug>/` folder.
- Each game has a working browser build or is clearly marked pending.
- Itch export artifacts are generated by script.
- Windows/macOS/iOS/Android artifacts are generated or honestly marked pending.
- DS ports exist under `games/<slug>/ports/nds/` with `.nds` build instructions only after a verified toolchain path exists.
- No proprietary or unlicensed external assets/tools are shipped.
