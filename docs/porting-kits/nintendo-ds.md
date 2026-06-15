# Nintendo DS homebrew porting kit

This kit is for building Prismtek **homebrew Nintendo DS demakes** from the active game `ds-homebrew/` folders.

It is not a Nintendo SDK, emulator bundle, BIOS bundle, or ROM distribution flow.

## Current repo inputs

Active games currently track compact DS source folders:

- `games/pixel-fruit-arena/ds-homebrew/`
- `games/tamernet-battle-sandbox/ds-homebrew/`
- `games/spin-street-showdown/ds-homebrew/`

Each DS target should stay tiny: simple sprites, small palettes, short loops, direct controls, and no copyrighted reference assets.

## Required local tools

### Recommended build path: devkitPro + libnds

Use devkitPro/libnds for real `.nds` builds. Install through the official devkitPro instructions for your OS, then verify:

```bash
printf '%s\n' "$DEVKITPRO"
printf '%s\n' "$DEVKITARM"
make --version
arm-none-eabi-gcc --version
```

Expected environment shape:

```bash
DEVKITPRO=/opt/devkitpro        # Linux/macOS example
DEVKITARM=$DEVKITPRO/devkitARM
```

Windows setups often use:

```powershell
$env:DEVKITPRO='C:\devkitPro'
$env:DEVKITARM='C:\devkitPro\devkitARM'
```

The DS Game Maker community setup uses the Windows MSYS-style values `/c/devkitPro` and `/c/devkitPro/devkitARM` for DSGM compatibility.

### Optional beginner path: DS Game Maker

DS Game Maker is useful for drag-and-drop experiments and tiny proof-of-life games. It is optional for Prismtek source builds.

The community Windows setup expects:

- `devkitPro` copied to the root of the same drive, usually `C:\devkitPro`
- `DS Game Maker` placed on that same drive
- `DS Game Maker.exe` set to run as Administrator
- system variables:
  - `DEVKITPRO=/c/devkitPro`
  - `DEVKITARM=/c/devkitPro/devkitARM`
  - `Path += c:\devkitPro\msys\bin`
- `.NET Framework 3.5` enabled

Use `tools/porting-kits/download-porting-kits.ps1` or `.sh` to download the reviewed DS Game Maker setup archive into `.porting-kits/nintendo-ds/` for manual local inspection.

## Build a game

From a game DS folder:

```bash
cd games/pixel-fruit-arena/ds-homebrew
make clean
make
```

Expected artifact:

```text
*.nds
```

Generated `.nds`, `.elf`, `.map`, and object files are intentionally gitignored.

## DS design budget

| Area | Safe starting budget |
| --- | --- |
| Screens | top: action, bottom: HUD/menu |
| Resolution | 256x192 per screen |
| Sprite size | 16x16, 24x24, 32x32, or tightly trimmed 48x48 |
| Animation | idle/run/jump/hit/attack/special/KO only |
| Stages | tilemaps or tiny static backgrounds |
| Audio | short effects; music only after memory budget is proven |
| Multiplayer | local/pass-and-play first; no network claim without proof |

## Verification checklist

A DS target is **Partially verified** when source exists and `make` has a documented path.

A DS target is **Verified** only after:

- `.nds` builds locally with devkitPro/libnds
- emulator boot is captured
- controls are tested
- game loop reaches win/loss or restart state
- artifact is attached to a release or stored as a local receipt
- README/platform docs are updated with exact date and host

## Do not commit

- Nintendo proprietary SDKs
- BIOS files
- commercial ROMs
- copied franchise assets
- downloaded emulator bundles
- generated `.nds` artifacts unless a release policy explicitly allows them

Tiny is the superpower here. DS ports should feel like arcade demakes, not compressed web games wearing a trench coat.
