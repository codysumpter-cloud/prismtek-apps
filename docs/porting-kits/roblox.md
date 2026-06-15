# Roblox porting kit

Roblox is a required Prismtek game target, but it is not a direct export format for the current browser games.

Treat Roblox support as a parallel implementation/adapter target with explicit receipts.

## Supported Roblox paths

| Path | Use when | Output |
| --- | --- | --- |
| Rojo project | We want source-controlled Roblox code and assets. | `default.project.json`, `src/`, synced into Roblox Studio. |
| Studio place file | We need a quick playable prototype. | `.rbxl` place file with manual receipts. |
| Model/module package | We need reusable gameplay parts. | `.rbxm` package. |
| Adapter spec first | The web game is not ready to port yet. | Design docs and mappings only. |

## Required per-game Roblox files

When a game starts Roblox implementation, add:

```text
games/<game-slug>/roblox/
├── README.md
├── controls.md
├── parity-map.md
└── receipts/
```

If using Rojo:

```text
games/<game-slug>/roblox/
├── default.project.json
└── src/
```

## Required controls

Every Roblox version must support:

- keyboard and mouse
- controller/gamepad
- touch/mobile controls

Mouse-only or keyboard-only gameplay does not count as complete Prismtek Roblox support.

## Required platform receipts

Roblox support is **Verified** only after:

- Roblox Studio opens the project/place.
- Desktop Roblox client is playable with keyboard/mouse.
- Controller is tested where the game design supports live control.
- Mobile/touch Roblox client is tested.
- One full gameplay loop reaches win/loss/reset/rematch.
- A receipt is committed or linked from the game docs.

## Parity map template

```text
Game:
Roblox target type: Rojo / Place / Module
Core loop:
Web source feature:
Roblox implementation feature:
Input mapping:
Asset mapping:
Known differences:
Receipts:
```

## Status rule

Do not mark Roblox as verified from web builds, Android APKs, or DS source. Roblox requires a Roblox-specific artifact or project receipt.
