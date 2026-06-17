# Prismcade Windows Package

Status: **packaging path**

This package exists so players do not need to run a Python server or know repo paths just to play Prismcade games.

## Build locally on Windows

From the repo root:

```powershell
npm run prismcade:validate:all
npm run prismcade:package:windows
```

Expected output:

```txt
dist/prismcade-windows/Prismcade-Windows.zip
```

Extract the ZIP, then double-click:

```txt
Prismcade.exe
```

The launcher starts a local-only web server on `127.0.0.1`, opens the Prismcade catalog, and serves all bundled games from the extracted `www/` folder.

If the executable was not compiled, use the fallback:

```txt
Prismcade.cmd
```

## What gets bundled

The package builder reads:

```txt
data/prismcade/game-manifests.json
```

It includes:

- `apps/prismcade/` catalog launcher;
- `apps/prismcade-creator/` creator prototype;
- `data/prismcade/` manifest data;
- `docs/prismcade/` docs;
- `games/_shared/` shared arcade runtime;
- every manifest-listed game folder;
- Prismcade asset manifest planning files.

Development-only folders such as `node_modules`, `dist`, `artifacts`, and Pixel Fruit Arena reference assets are excluded.

## Player instructions

1. Build or download `Prismcade-Windows.zip`.
2. Extract the ZIP.
3. Double-click `Prismcade.exe`.
4. Pick a game from the Prismcade catalog.
5. Close the Prismcade console window when done.

## Future release automation

A follow-up PR should add a GitHub Actions workflow or release job that runs `npm run prismcade:package:windows` on `windows-latest` and uploads `dist/prismcade-windows/Prismcade-Windows.zip` as a release artifact.

## Honest limitation

This is a Windows-friendly launcher ZIP, not a signed installer yet. Windows may show a SmartScreen warning until releases are signed with a trusted certificate.
