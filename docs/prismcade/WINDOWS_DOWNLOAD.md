# Prismcade Windows Download

Goal: provide one player-facing ZIP named Prismcade-Windows.zip.

Required build command:

npm run prismcade:package:windows

Expected local output:

dist/prismcade-windows/Prismcade-Windows.zip

Player flow:

1. Download Prismcade-Windows.zip.
2. Extract it.
3. Double-click Prismcade.exe.
4. Pick a game from the Prismcade catalog.

The current PR adds the package builder. A public one-click button still requires attaching the ZIP to a release or workflow artifact.
