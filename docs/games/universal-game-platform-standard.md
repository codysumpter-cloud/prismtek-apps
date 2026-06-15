# Universal Prismtek game platform standard

Every Prismtek game must target the same input and platform support contract unless a documented exception exists.

This is an implementation standard, not a marketing claim. A target is only **Verified** after there is a real build artifact and a dated test receipt.

## Required input support

Every game must support:

| Input | Requirement | Notes |
| --- | --- | --- |
| Keyboard | Required | Must support full gameplay and menus. |
| Mouse | Required | Must support menu/UI interaction and gameplay where the design uses aiming or pointer control. |
| Controller | Required | Must support standard gamepad navigation and gameplay. |
| Touch | Required | Must support mobile/tablet gameplay and menus. |

Core gameplay may not require touch-only actions, mouse-only actions, or keyboard-only actions unless the game has a documented accessibility-safe fallback.

## Required platform targets

Every game must track support for:

| Platform | Required artifact path | Verification rule |
| --- | --- | --- |
| Web browser | Static browser build or hosted build | Launches and completes one game loop in browser. |
| Windows | Desktop bundle or tested web ZIP fallback | Launches on Windows and controls work. |
| macOS | Desktop bundle or tested web ZIP fallback | Launches on macOS and controls work. |
| Linux | Desktop bundle, AppImage/deb/rpm, or tested web ZIP fallback | Launches on Linux and controls work. |
| iOS | PWA, web build, or native wrapper | Launches on iPhone/iPad runtime and touch works. |
| Android | APK, PWA, or web wrapper | Launches on Android and touch/controller work. |
| RGDS Android | Android artifact tested on RGDS Android mode | Must be tested on actual RGDS Android mode before verified. |
| RGDS Linux | Linux/browser/launcher artifact tested on RGDS Linux mode | Must be tested on actual RGDS Linux mode before verified. |
| Roblox | Roblox reimplementation or adapter project | Must have a Studio-place/module receipt; web code cannot be called verified Roblox support. |

## Status values

Use only these values:

- `Required`
- `Configured`
- `Partially verified`
- `Verified`
- `Blocked`
- `Missing`
- `Not applicable`

`Required` means the game is expected to support the target but no implementation receipt exists yet.

`Configured` means repo config or adapter docs exist but no artifact/device receipt exists yet.

`Partially verified` means source/build path exists and at least one relevant local or CI receipt exists, but full target testing is incomplete.

`Verified` means a real artifact was tested on the target with controls and one full game loop.

`Blocked` requires a clear blocker note.

`Not applicable` requires an explicit reason and should be rare.

## Per-game required file

Every active game under `games/*` must include:

```text
games/<game-slug>/platforms/universal-support.json
```

That file must declare:

- game id and display name
- input support targets
- platform support targets
- required receipts
- known gaps
- next actions

## Required receipts before claiming done

For each game + target combination:

```text
Game:
Platform:
Input modes tested:
Artifact:
Build command:
Device/runtime:
Full loop completed:
Result:
Known issues:
Date:
Tester:
```

## Roblox rule

Roblox is not a direct export target for the current browser games. It is a reimplementation/adapter target.

A Prismtek game can only claim Roblox support when it has at least one of:

- `.rbxl` place file
- `.rbxm` model/module package
- Rojo project
- Roblox Studio build instructions
- Roblox play-test receipt

Until then, Roblox status is `Required` or `Configured`, not `Verified`.

## Enforcement

Run:

```bash
npm run games:validate-support
```

The validator currently covers the active game folders listed in the repo platform tracker. Queued games must receive their own `platforms/universal-support.json` when they are migrated into `games/*`.
