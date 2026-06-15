# Spin Street Showdown Arcade PvP Loop

Spin Street Showdown should be a low-resource, highly available retro PvP match game: fast to load, easy to understand, hard to master, replayable forever, and built around public clout like old arcade scoreboards.

## Product fantasy

Walk up, launch, clash, pop off, rank up, earn parts, and get your name on the wall.

The target is not a heavy live-service game. The target is an arcade cabinet people can carry in a browser tab, handheld, cheap PC, RGDS, Steam Deck, or local event setup.

## Design pillars

1. **Thirty-second understanding, thousand-match mastery**
   - Move toward the target.
   - Charge at the right time.
   - Read rim angle, mass, grip, and stability.
   - Win through better launch lines, burst timing, guard reads, and Spirit Surge timing.

2. **Low-resource by default**
   - Canvas-first web runtime.
   - No mandatory 3D engine.
   - No huge asset dependency.
   - Works offline/local first.
   - Can later sync match receipts to a tiny service.

3. **PvP-first replayability**
   - Short matches.
   - Immediate rematch.
   - Local PvP first, online PvP later.
   - Deterministic match seeds where possible.
   - Clear match receipts for wins, rank, rewards, and bracket events.

4. **Clout over grind**
   - Ranks should be visible and flex-worthy.
   - Rewards should show in the match: rings, trails, title cards, plaques, rival intro banners, win stamps.
   - Players should want screenshots of victories.
   - Weekly arcade boards should matter more than infinite XP grind.

5. **Original identity**
   - Inspired by arcade battle-top energy, not copied assets or copied lore.
   - Spirit Surge is the Prismtek special meter language.
   - Parts, arenas, and ranking names should feel Prismtek-native.

## Core match loop

1. Choose loadout.
2. Launch into dome.
3. Build charge through movement and contact.
4. Use strike dash, guard, burst, and Spirit Surge.
5. Win by KO, outspin, ring crash, or score lead.
6. Earn cash, rank points, cosmetics, parts, and brag receipts.
7. Rematch instantly.

## Competitive mechanics to build toward

| Mechanic | Why it matters |
| --- | --- |
| Launch angle | Creates skill before the first contact. |
| Rim pressure | Makes arena control matter. |
| Stability | Gives heavy and defense builds an identity beyond HP. |
| Tangential bite | Makes glancing hits different from direct hits. |
| Burst timing | Adds high-risk/high-reward contact windows. |
| Counter guard | Lets skilled players punish reckless rushes. |
| Spirit Surge | Creates late-match reversal pressure without becoming an instant win. |
| Outspin timer | Prevents runaway stall matches. |
| Match receipt | Enables rankings, rewards, and event summaries later. |

## Ranking and reward ladder

Recommended low-friction ladder:

| Tier | Flavor |
| --- | --- |
| Alley Spark | Starter tier. |
| Dome Runner | Learns movement and rim control. |
| Rail Shark | Wins through wall pressure. |
| Burst Artist | Lands high-value burst windows. |
| Circuit King | Strong ranked player. |
| Neon Myth | Seasonal elite. |
| Prism Legend | Event winner or top board finisher. |

Reward types:

- Nameplate titles
- Top rim skins
- Trail colors
- Spirit Surge silhouettes
- Victory stamps
- Cabinet-style leaderboard plaques
- Seasonal badges
- Tournament trophies
- Event-only cosmetic part variants or sidegrades

## Highly available architecture

### Phase 1: local-first arcade

- Browser canvas game.
- Local PvP.
- Local CPU circuit.
- Local rewards and unlocks in localStorage.
- Exportable match receipt JSON.

### Phase 2: cheap public clout layer

- Static hosting for the game.
- Tiny API for match receipts and leaderboard writes.
- Server validates receipt shape, score ranges, duration, and client build version.
- Weekly leaderboard pages are static or cached.

### Phase 3: ranked PvP

- Account identity.
- ELO/MMR or season points.
- Replayable match seed.
- Basic receipt validation.
- Ghost/replay summaries before full real-time networking.

### Phase 4: arcade events

- Daily dome rule modifiers.
- Weekend brackets.
- Community cabinets.
- Share cards for wins.
- Reward drops for top boards.

## Performance budget

- Loads from a static ZIP.
- No required network request to play local modes.
- 60 FPS on modest laptops and handheld browsers.
- Canvas-only draw path unless a later renderer earns its complexity.
- Minimal audio sprites and small images only.
- Deterministic-enough simulation for replay receipts.

## Next implementation slice

1. Add local profile and arcade name.
2. Add local match history.
3. Add local rank progression.
4. Add end-of-match receipt object.
5. Add win card screenshot/share UI.
6. Add leaderboard-ready JSON export.
7. Add lightweight hosted leaderboard API only after receipts are stable.
