# Prismcade Website ↔ Native Catalog Sync

Status: **manual sync, documented** (2026-06-21)

## Where Prismcade lives on each surface

| Surface | Location | Catalog source | Games |
| --- | --- | --- | --- |
| Web / Windows-HTML | `prismtek-site` (`src/arcade/`, `/play/<slug>/`, `functions/api/prismcade`) | `prismtek-site/src/data/game-catalog.js` | 26 |
| prismtek-apps registry | `data/prismcade/game-manifests.json` (folder-validated) | itself | 9 |
| Native macOS/iOS | `apps/prismcade-native` | `data/prismcade/prismcade-catalog.json` (bundled) | 32 catalog / 3 playable |
| Canonical union | `data/prismcade/prismcade-catalog.json` | generated from the three above | 32 |

## Website audit (2026-06-21)
- Prismcade is a real platform on the website: arcade shell (`src/arcade/`), `/play/<slug>/`
  routes, leaderboards/results components, score validation, and a UGC creator + API
  (`functions/api/prismcade`). The homepage references "browser arcade games" generally.
- The website **does** carry the 26-game catalog (`game-catalog.js`). It does **not** yet list the
  two native-first games (Dino Dash, Buck) or the 4 apps-only games.
- It is **not** feature-complete per the canonical "Roblox for pixel art" creator vision.

## Sync model (current = manual)
The canonical catalog `data/prismcade/prismcade-catalog.json` is **regenerated manually** by merging
the three sources. There is no automatic build step yet. To refresh after a web or native change:

1. Re-read `prismtek-site/src/data/game-catalog.js` and `data/prismcade/game-manifests.json`.
2. Regenerate `data/prismcade/prismcade-catalog.json` (union + native status + replacements).
3. `npm run prismcade:validate-catalog`.
4. Copy it into `apps/prismcade-native/Shared/Resources/Catalog/prismcade-catalog.json`.

## Follow-up PRs needed
- **Native** consumes the canonical catalog (done this PR).
- **Website**: add Dino Dash + Beat Em Up Buck (native-first) to `game-catalog.js`, and mark
  native-canonical games. A dedicated `prismtek-site` PR — not done here.
- **Automation**: a small generator (`tools/prismcade/build-canonical-catalog.mjs`) that reads both
  sources and emits `prismcade-catalog.json`, so sync is one command. Currently manual/documented.
- **LeaderboardService backend**: add `POST /api/prismcade/scores` to `functions/api/prismcade` so
  native runs can sync (see `LeaderboardService.swift`).
