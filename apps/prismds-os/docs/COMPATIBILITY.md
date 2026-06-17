# PrismDS compatibility

This file separates what should work now from what still needs RGDS-on-device validation.

## RGDS layer status

| Area | Status | Notes |
| --- | --- | --- |
| Linux folder layout | Functional | Installed under `~/.local/share/prismds` by default. |
| Azahar launcher | Functional | Requires user-provided executable. |
| Android Azahar helper | Functional | Requires ADB and user-provided APK. |
| EmulationStation config | Functional | Adds a 3DS system entry pointing to the PrismDS Azahar launcher. |
| Performance helper | Functional, optional | Works only where CPU governor files are writable. |
| Lab launcher | Functional wrapper | Requires user-provided compatible executable. |
| Full bootable image | Not implemented | Requires hardware recovery and driver validation first. |

## Expected RGDS behavior

The RGDS has enough raw CPU/RAM to attempt 3DS emulation experiments, but performance depends on emulator optimization, graphics drivers, Android/Linux image quality, and game workload.

Recommended test order:

1. Android Azahar APK on the RGDS Android side.
2. Linux Azahar AppImage/native build through PrismDS.
3. Lab profile only after Azahar path is proven.

## Game compatibility tracking

Add per-title notes in a future `compatibility/` folder using this shape:

```json
{
  "title": "Example Game",
  "emulator": "azahar",
  "platform": "rgds-android",
  "status": "untested",
  "settings": {
    "resolutionScale": "1x",
    "renderer": "default"
  },
  "notes": []
}
```

Status values:

- `untested`
- `boots`
- `playable`
- `slow`
- `broken`

## Non-goals

PrismDS does not include emulator binaries, games, platform-owned assets, or private user files.
