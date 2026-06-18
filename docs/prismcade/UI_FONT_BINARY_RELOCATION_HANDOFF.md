# UI / Font Binary Relocation Handoff

The June 18 upload commit placed UI/font assets at the repository root. The metadata/docs are now mapped, but the binaries still need a real `git mv` cleanup so the root stays clean.

## Source commit

```txt
47cb687b619beb6fe35e1a0ed42fb5b15c1ce9d9
```

## Target folders

```bash
mkdir -p \
  game-assets/fonts \
  game-assets/ui/source-packs \
  game-assets/ui/icons \
  game-assets/ui/buttons \
  game-assets/ui/controller-prompts \
  game-assets/_incoming/retry-or-remove
```

## Moves

```bash
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

## After moving

Update `data/prismcade/ui-font-asset-intake.json` so each `currentPath` equals the final `targetPath`, then change statuses from `needs-relocation-and-license-receipt` to whichever review status applies.

Do not wire these into `apps/prismcade/` runtime UI until license/provenance receipts are committed.
