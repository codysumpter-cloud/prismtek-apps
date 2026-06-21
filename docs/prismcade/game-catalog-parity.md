# Prismcade Game Catalog Parity

This document defines the catalog-parity target for Prismcade across web, Windows/HTML
packaging, and native macOS/iOS, and records the **actual** state found in-repo on
2026-06-21 (audited by Claude/Buddy during the PR #205 polish review).

## Goal

Prismcade should behave like one platform with multiple runtime adapters:

- website / web Prismcade
- Windows/HTML package
- native macOS/iOS Prismcade

Games should not fork into unrelated versions with the same title. If an older web/HTML
entry shares a canonical identity with a newer native/canonical game, the newer canonical
entry should replace the old duplicate while preserving aliases in docs and manifests.

## Canonical replacement rule

Preferred canonical version order:

1. Polished native/canonical Prismcade version.
2. Maintained HTML/web Prismcade version.
3. Older legacy game entry.
4. Placeholder only when no implementation exists.

Do not show duplicate game cards for the same canonical game.

## CORRECTION (2026-06-21, pass 3): the real Windows/HTML catalog lives in `prismtek-site`

The `prismtek-apps/data/prismcade/game-manifests.json` (9 entries) is NOT the shipping
Windows/HTML catalog. The real web/Windows Prismcade is the **website** (`prismtek-site`),
whose canonical catalog `src/data/game-catalog.js` lists **26 games**, served through a full
arcade platform. Native currently ships **3**.

### Web catalog — 26 games (`prismtek-site/src/data/game-catalog.js`), native status
flappy-pixel ✅native · crossy-pixel · boss-lab · byteblade-survivor · crystal-cavern-miner ·
dungeon-byte · gravity-golf-mini · laser-labyrinth · meteor-salvage-ops · neon-stack-master ·
neon-tunnel-drift · orb-defender-lite · pixel-blast · pixel-heist-escape · pixel-invaders-mini ·
pixel-pong · pixel-position · pixel-snake · neon-brick-breaker · pixel-stacker ·
prism-companion-lab · prism-puck-arena · **prism-sky-hunt** (exists — correcting earlier note) ·
reactor-overload · signal-scramble · turbo-rail-rider.

Native-only (not in web catalog): **Prismtek Dino Dash**, **Beat Em Up Buck**.

So: **1 of 26** web games is in native; **25 missing**; native adds 2 of its own.

### Web platform features (also part of parity), all in `prismtek-site/src/arcade/`
- LeaderboardPanel, RecentActivityFeed, ResultsDialog, GameShell, PlayfieldFrame
- async challenges, score validation (`scoreValidation` per game), school-safe flags,
  compatibility matrix, categories/tags, UGC creator + Prismcade API (`functions/api/prismcade`).

Native has **none** of these platform features yet (hub + 3 standalone scenes only).

### Staged native parity plan (realistic — this is a multi-week effort, not one pass)
1. **Tier A — simple self-contained arcade games** (each ≈ one SpriteKit scene, like the
   current 3): pixel-snake, pixel-pong, neon-brick-breaker, pixel-stacker, pixel-invaders-mini,
   crossy-pixel, neon-stack-master. Port these first; each gets SFX + hub entry + autoverify.
2. **Tier B — medium games**: dungeon-byte, laser-labyrinth, gravity-golf-mini, orb-defender-lite,
   meteor-salvage-ops, signal-scramble, turbo-rail-rider, neon-tunnel-drift, pixel-blast,
   reactor-overload, pixel-position, pixel-heist-escape, crystal-cavern-miner.
3. **Tier C — large/complex**: boss-lab, byteblade-survivor, prism-puck-arena, prism-sky-hunt,
   prism-companion-lab (+ the `prismtek-apps` heavies pixel-fruit-arena, spin-street-showdown,
   tamernet-battle-sandbox if they are to be native too).
4. **Platform layer**: a shared native `GameCatalog` (mirrors `game-catalog.js`), a generic
   `GameScene` protocol + `GameShell` (score HUD, results, restart), score validation, and a
   `LeaderboardService` that consumes the existing `functions/api/prismcade` backend (do NOT
   re-implement the backend natively — native should call the shared API).
5. **Replacement rule**: for shared identities (flappy-pixel today; any web game later ported),
   the native build is canonical; retire/alias the older web entry per this doc.

Each Tier-A port is comparable in size to the existing Flappy/Dino/Buck scenes (~300–600 LOC).
Doing all 25 + the platform layer is realistically dozens of focused commits across multiple
sessions; it should be sequenced one game (or small batch) at a time, each built + runtime-verified.

## Sources of truth (verified paths)

- Canonical web catalog manifest: `data/prismcade/game-manifests.json` (9 game entries).
- Web/HTML game runtimes: `games/<slug>/` (e.g. `games/flappy-pixel/`, `games/pixel-fruit-arena/`).
- Native catalog: `apps/prismcade-native/Shared/Models/PrismcadeState.swift` →
  `enum PrismcadeGame` (3 cases: `flappyPixel`, `dinoDash`, `buckBorris`).
- Web Prismcade shell / creator: `apps/prismcade/`, `apps/prismcade-creator/`.
- Website surface: `prismtek-site` Prismcade platform (`functions/api/prismcade/`,
  `/play/<slug>/` routes, `GAME_PLATFORM.md`).

## Parity table (verified 2026-06-21)

`game-manifests.json` status values are quoted verbatim. "Native" = present in the native
SwiftUI/SpriteKit hub. Playable means an actual runtime exists.

| Canonical game | Web/HTML (`games/` + manifest status) | Windows package | Native macOS/iOS | Website card | Canonical action |
| --- | --- | --- | --- | --- | --- |
| Flappy Pixel | `games/flappy-pixel/` — `quick-play-import` | Pending (no per-game Win package found) | Yes — `flappyPixel` (SpriteKit, runtime-verified) | `/play/flappy-pixel/` exists; flagship in `GAME_PLATFORM.md` | Native is now the most-polished build. Keep one canonical "Flappy Pixel"; web/native are the same identity — do not show twice. |
| Pixel Fruit Arena | `games/pixel-fruit-arena/` — `playable-mvp` | Pending | No | Should show (web MVP) | **Next native polish target.** Stage for native port. |
| Crossy Pixel | `games/crossy-pixel/` — `quick-play-import` | Pending | No | Should show (web) | Web-only for now; add to native backlog. |
| Pixel Snake | `games/pixel-snake/` — `quick-play-import` | Pending | No | Should show (web) | Web-only for now; add to native backlog. |
| Neon Brick Breaker | `games/neon-brick-breaker/` — `quick-play-import` | Pending | No | Should show (web) | Web-only for now; add to native backlog. |
| Pixel Stacker | `games/pixel-stacker/` — `quick-play-import` | Pending | No | Should show (web) | Web-only for now; add to native backlog. |
| Spin Street Showdown | `games/spin-street-showdown/` — `playable-prototype` | Pending | No | Show as prototype | Web prototype; backlog. |
| TamerNet Battle Sandbox | `games/tamernet-battle-sandbox/` — `playable-prototype` | Pending | No | Show as prototype | Web prototype; backlog. |
| Prismwilds: Echo Dominion | `games/prismwilds-echo-dominion/` — `large-showcase-prototype` | Pending | No | Show as showcase | Web showcase; backlog. |
| Prismtek Dino Dash | **not in web manifest** | Pending | Yes — `dinoDash` (SpriteKit, runtime-verified) | Not yet on website | **Native-first / native-only.** Add a canonical manifest entry so web/site know it exists; decide if a web port is wanted. Do not use Google/Chrome Dino assets or naming. |
| Beat Em Up Buck | Identity overlap: `games/prismcade-fighter/`, `tools/prismcade-fighter/`, `experiments/ikemen-prismtek-fighter/`, `experiments/openbor-prismtek-brawler/` exist but are **not** in `game-manifests.json` | Pending | Yes — `buckBorris` (SpriteKit micro-brawler, runtime-verified) | Not yet on website | **Native-first.** Confirm whether `prismcade-fighter` is the same canonical identity as Beat Em Up Buck. If yes, mark native canonical and the old fighter experiments as superseded aliases. Add a manifest entry. |

### Summary of the gap

- Web canonical catalog: **9 games** (`game-manifests.json`).
- Native catalog: **3 games** (Flappy Pixel + 2 native-first games).
- Native shares only **Flappy Pixel** with the web manifest.
- Native added **Dino Dash** and **Beat Em Up Buck**, which are **absent from the web
  manifest** → they are native-first and need canonical manifest entries to reach parity.
- Web has **8 games not yet native**: Pixel Fruit Arena, Crossy Pixel, Pixel Snake,
  Neon Brick Breaker, Pixel Stacker, Spin Street Showdown, TamerNet Battle Sandbox,
  Prismwilds: Echo Dominion.

There is **not** full parity today. Native is a curated 3-game launch subset, not a
mirror of the canonical catalog.

## Native hub requirement

`apps/prismcade-native` hard-codes a 3-case enum. Until it reads a generated native subset
of `data/prismcade/game-manifests.json`, keep the enum aligned with this table and the
replacement rules. Dino Dash and Beat Em Up Buck must be added to the canonical manifest
(with a `native-first` status) so the catalog is the single source of truth.

## Website requirement

`prismtek-site` already runs a Prismcade platform (UGC creator API + `/play/<slug>/`
routes, Flappy Pixel flagship per `GAME_PLATFORM.md`). It does not yet surface Dino Dash
or Beat Em Up Buck. See `docs/prismcade/native-prismcade.md` and the website audit in the
PR review for the sync path.

## Next implementation steps

1. Add `prismtek-dino-dash` and `beat-em-up-buck` entries to `data/prismcade/game-manifests.json`
   with a `native-first` status and platform metadata.
2. Add alias/replacement metadata resolving `prismcade-fighter` to Beat Em Up Buck (verify identity first).
3. Generate or manually sync a native-compatible catalog subset the native hub can read.
4. Update `apps/prismcade-native` hub to consume real catalog metadata instead of the enum.
5. Update `prismtek-site` so all canonical Prismcade games appear with cards, including native-first titles.
6. Stage **Pixel Fruit Arena** (web `playable-mvp`) and **Prism Sky Hunt** as the next polish targets.
   NOTE: "Prism Sky Hunt" was **not found** in `game-manifests.json` or `games/` on 2026-06-21 —
   it must be created or its real slug identified before it can be tracked here.
