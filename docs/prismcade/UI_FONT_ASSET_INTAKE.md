# Prismcade UI / Font Asset Intake

Status: **mapped, not yet physically relocated**

Source commit:

```txt
47cb687b619beb6fe35e1a0ed42fb5b15c1ce9d9
```

That commit uploaded UI, font, icon, gamepad prompt, and menu assets directly to the repository root. This document classifies them and gives each file an intended Prismcade library destination.

The machine-readable map lives at:

```txt
data/prismcade/ui-font-asset-intake.json
```

## Fonts

| Current root file | Intended path | Prismcade use |
| --- | --- | --- |
| `BoldPixels.ttf` | `game-assets/fonts/BoldPixels.ttf` | Prismcade brand / HUD / arcade UI font |
| `webfontkit-BoldPixels.zip` | `game-assets/fonts/webfontkit-BoldPixels.zip` | Web font kit for Prismcade Home and browser UI |

## UI source packs

| Current root file | Intended path | Prismcade use |
| --- | --- | --- |
| `Complete_UI_Essential_Pack_Free.7z` | `game-assets/ui/source-packs/Complete_UI_Essential_Pack_Free.7z` | Buttons, panels, menus, HUD, dialog boxes |
| `Cryo's Mini GUI.zip` | `game-assets/ui/source-packs/Cryo's Mini GUI.zip` | Compact menus and panels |
| `Cryo's Mini GUI Controller.zip` | `game-assets/ui/source-packs/Cryo's Mini GUI Controller.zip` | Controller prompts and input-help UI |
| `Cryo's Mini GUI Social Buttons.zip` | `game-assets/ui/source-packs/Cryo's Mini GUI Social Buttons.zip` | Social/profile/share buttons |
| `Custom Border and Panels Menu All Part.rar` | `game-assets/ui/source-packs/Custom Border and Panels Menu All Part.rar` | Panel borders, dialog frames, creator UI |
| `Free - Raven Fantasy Icons.zip` | `game-assets/ui/icons/Free - Raven Fantasy Icons.zip` | Inventory, ability, and menu icons |
| `Freebuttons.zip` | `game-assets/ui/buttons/Freebuttons.zip` | Primary/menu/mobile buttons |
| `Humble Gift - Paper UI System.zip` | `game-assets/ui/source-packs/Humble Gift - Paper UI System.zip` | Paper panels, dialog UI, inventory UI |
| `Humble Gift - v1.3.zip` | `game-assets/ui/source-packs/Humble Gift - v1.3.zip` | Panels, menus, HUD |
| `UIBundleFree.zip` | `game-assets/ui/source-packs/UIBundleFree.zip` | General UI bundle |

## Controller prompt assets

| Current root file | Intended path | Prismcade use |
| --- | --- | --- |
| `gdb-gamepad-2(all).zip` | `game-assets/ui/controller-prompts/gdb-gamepad-2(all).zip` | Controller prompt archive |
| `gdb-gamepad-2.aseprite` | `game-assets/ui/controller-prompts/gdb-gamepad-2.aseprite` | Source file for prompt remixes |
| `gdb-playstation-3.png` | `game-assets/ui/controller-prompts/gdb-playstation-3.png` | Controller prompt sheet |
| `gdb-switch-2.png` | `game-assets/ui/controller-prompts/gdb-switch-2.png` | Controller prompt sheet |
| `gdb-xbox-2.png` | `game-assets/ui/controller-prompts/gdb-xbox-2.png` | Controller prompt sheet |

## Needs follow-up

| Current root file | Problem | Action |
| --- | --- | --- |
| `Helton Yan's Pixel Combat.zip.download` | Partial browser download file, not a real finalized archive | Re-upload the finished `.zip`, or delete this stub |

## Physical relocation plan

The current connector path can safely add metadata and docs, but moving binary archives requires either a binary-aware git move or GitHub tree/blob move.

Recommended cleanup commands from a local clone:

```bash
mkdir -p game-assets/fonts game-assets/ui/source-packs game-assets/ui/icons game-assets/ui/buttons game-assets/ui/controller-prompts game-assets/_incoming/retry-or-remove

git mv BoldPixels.ttf game-assets/fonts/BoldPixels.ttf
git mv webfontkit-BoldPixels.zip game-assets/fonts/webfontkit-BoldPixels.zip
git mv Complete_UI_Essential_Pack_Free.7z game-assets/ui/source-packs/Complete_UI_Essential_Pack_Free.7z
git mv "Cryo's Mini GUI.zip" "game-assets/ui/source-packs/Cryo's Mini GUI.zip"
git mv "Cryo's Mini GUI Controller.zip" "game-assets/ui/source-packs/Cryo's Mini GUI Controller.zip"
git mv "Cryo's Mini GUI Social Buttons.zip" "game-assets/ui/source-packs/Cryo's Mini GUI Social Buttons.zip"
git mv "Custom Border and Panels Menu All Part.rar" "game-assets/ui/source-packs/Custom Border and Panels Menu All Part.rar"
git mv "Free - Raven Fantasy Icons.zip" "game-assets/ui/icons/Free - Raven Fantasy Icons.zip"
git mv Freebuttons.zip game-assets/ui/buttons/Freebuttons.zip
git mv "Humble Gift - Paper UI System.zip" "game-assets/ui/source-packs/Humble Gift - Paper UI System.zip"
git mv "Humble Gift - v1.3.zip" "game-assets/ui/source-packs/Humble Gift - v1.3.zip"
git mv UIBundleFree.zip game-assets/ui/source-packs/UIBundleFree.zip
git mv "gdb-gamepad-2(all).zip" "game-assets/ui/controller-prompts/gdb-gamepad-2(all).zip"
git mv gdb-gamepad-2.aseprite game-assets/ui/controller-prompts/gdb-gamepad-2.aseprite
git mv gdb-playstation-3.png game-assets/ui/controller-prompts/gdb-playstation-3.png
git mv gdb-switch-2.png game-assets/ui/controller-prompts/gdb-switch-2.png
git mv gdb-xbox-2.png game-assets/ui/controller-prompts/gdb-xbox-2.png
git mv "Helton Yan's Pixel Combat.zip.download" "game-assets/_incoming/retry-or-remove/Helton Yan's Pixel Combat.zip.download"
```

## Runtime promotion rule

These are source/intake assets. They should not be consumed directly by `apps/prismcade/` until:

1. license/provenance is captured;
2. archive contents are inspected;
3. useful sheets are extracted into runtime folders;
4. Prismcade UI skin metadata is created;
5. the Home and Locker surfaces consume the promoted runtime files, not raw archives.
