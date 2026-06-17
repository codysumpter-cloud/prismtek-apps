# Prismcade Catalog

Static catalog/launcher prototype for the Prismcade platform loop.

## Player-friendly Windows ZIP

From the repo root on Windows:

```powershell
npm.cmd run prismcade:validate:all
npm.cmd run prismcade:package:windows
```

Then extract:

```txt
dist/prismcade-windows/Prismcade-Windows.zip
```

Double-click:

```txt
Prismcade.exe
```

The executable starts a local-only launcher and opens the Prismcade catalog with all manifest-listed games bundled under `www/`.

To open Pixel Fruit Arena directly, double-click:

```txt
Pixel Fruit Arena.cmd
```

Full notes: [`docs/prismcade/WINDOWS_PACKAGE.md`](../../docs/prismcade/WINDOWS_PACKAGE.md).

## Run from repo root

From the repo root:

```bash
python -m http.server 4173
```

Open:

```txt
http://localhost:4173/apps/prismcade/
```

The catalog reads:

```txt
data/prismcade/game-manifests.json
```

## Validate

```bash
npm run prismcade:validate
```
