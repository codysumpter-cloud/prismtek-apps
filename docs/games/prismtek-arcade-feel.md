# Prismtek Arcade Feel Guide

This guide keeps every game in `games/` pointed at the same product feel without forcing every game to use the same mechanics, art, or theme.

## One-line target

Prismtek Arcade games should feel like low-resource, highly available, replayable match games with fast readability, instant rematches, visible progression, and old-arcade clout.

## Current games

| Game | Path | Arcade role | Shared feel target |
| --- | --- | --- | --- |
| Pixel Fruit Arena | `games/pixel-fruit-arena/` | Platform fighter | Fast readable local fights, expressive powers, ring-outs, awakening, match receipts, rank rewards. |
| TamerNet Battle Sandbox | `games/tamernet-battle-sandbox/` | Creature battle sandbox | Quick command battles, readable creature roles, alpha encounters, PvP-ready duel rules, reward receipts. |
| Spin Street Showdown | `games/spin-street-showdown/` | Spinning-top battle arcade | Short dome clashes, launch skill, rim pressure, burst timing, Spirit Surge, visible ranked clout. |

## Shared pillars

1. **Fast to start**
   - Browser-first where practical.
   - No required login for local play.
   - No required network for local modes.
   - A player should get into a match quickly.

2. **Readable immediately**
   - Clear silhouettes.
   - Clear hit effects.
   - Clear health/score/objective states.
   - Inputs should be learnable from one short controls panel.

3. **Skill over bloat**
   - Matches should be short.
   - Rematch should be instant.
   - Outcomes should reward timing, positioning, and reads.
   - Progression should support mastery rather than hide weak mechanics.

4. **Low-resource by design**
   - Canvas, static HTML, small assets, and compact audio are preferred until a heavier renderer earns its cost.
   - Static ZIP packaging should stay available.
   - Every game should be playable on modest PCs and handheld browsers before chasing high-end effects.

5. **Clout loop**
   - Every match should eventually produce a result receipt.
   - Wins should be shareable.
   - Ranks, badges, titles, trails, skins, plaques, or trophies should be visible in-game.
   - Weekly boards and event boards should matter more than endless grind.

6. **Original Prismtek identity**
   - No shipped reference/test assets.
   - No copied franchise assets or copied lore.
   - Use original names, mechanics, rewards, and visual language.

## Shared systems every arcade game should grow toward

| System | Purpose |
| --- | --- |
| Local profile | Arcade name, preferred controls, local unlocks, and local stats. |
| Match receipt | JSON summary of mode, players, build/version, result, duration, score, and rewards. |
| Local history | Keeps wins, losses, streaks, best rounds, and event results without needing a server. |
| Rank ladder | Gives players visible status and replay motivation. |
| Rewards | Unlocks that show up inside matches without becoming pay-to-win. |
| Share card | Screenshot or generated summary card for a win, rank-up, or tournament result. |
| Leaderboard export | A safe JSON shape that a later backend can validate and publish. |

## Suggested rank language

Use game-specific labels, but keep the same feeling:

| Tier band | Tone |
| --- | --- |
| Starter | Street-level, approachable, beginner flex. |
| Skilled | Shows real match knowledge. |
| Dangerous | Opponents recognize the name. |
| Elite | Seasonal leaderboard identity. |
| Legend | Event winner or top-board finisher. |

## Platform feel contract

Each game should aim for this minimum release feel:

- Web browser starts cleanly.
- Static ZIP can be built locally.
- README lists controls, run commands, package commands, and honest platform status.
- Local match can be completed without a backend.
- Visual effects communicate hits and rewards without tanking performance.
- DS/RGDS/Steam Deck/mobile claims stay **Unverified** until there is a real build and device receipt.

## What not to do

- Do not turn every game into the same game.
- Do not add heavy engines just because they look nicer.
- Do not hide unfinished platforms behind optimistic language.
- Do not ship dev/reference assets.
- Do not make rewards pay-to-win.
- Do not add online ranked until local match feel and match receipts are stable.

## Near-term roadmap for all games

1. Add local arcade profile/name.
2. Add local match history.
3. Add rank ladder and local rewards.
4. Add end-of-match receipt JSON.
5. Add win card or share card UI.
6. Add leaderboard-ready export.
7. Add lightweight hosted leaderboard only after the receipt format is stable.
