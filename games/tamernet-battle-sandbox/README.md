# TamerNet Battle Sandbox

A playable browser prototype for the Prismtek creature-MMO battle direction:

> PokeMMO-style long-term persistence and economy later, but with real-time overworld command combat, PvP outplay potential, and large-scale alpha PvE.

This sandbox intentionally uses original placeholder creatures and no external assets.

## Run it

From this folder:

```bash
python3 -m http.server 8080
```

Then open:

```text
http://localhost:8080
```

You can also open `index.html` directly in a browser.

## Controls

| Action | Input |
| --- | --- |
| Move trainer | WASD / Arrow keys |
| Dodge | Space |
| Command active creature moves | 1 / 2 / 3 / 4 |
| Swap creature | Tab |
| Capture weakened wild | C |
| Toggle alpha mode | R |
| Reset | Enter |
| Pause | P |

## Implemented

- Trainer movement.
- Active creature companion.
- Three original party creatures: Sproutbit, Embermite, Tidepup.
- Wild Bramblehorn encounter.
- Alpha Bramblehorn encounter.
- Cooldown-command moves.
- Projectiles, telegraphed AoE, guard, support pulse, and dodge.
- Capture chance based on enemy HP and proximity.
- Alpha contribution scoring placeholder.
- Combat log and HUD.

## Not implemented yet

- Server authority.
- Multiplayer.
- PvP duel mode.
- Marketplace, breeding, economy, or legendary custody.
- BYO-file importer.
- Any Pokémon/PokeMMO/Necesse assets.

## Next build targets

1. Extract battle simulation into a deterministic shared package.
2. Add server-authoritative local duel mode.
3. Add PvP snapshot interpolation and reconciliation.
4. Add alpha raid contribution rewards.
5. Add persistence for accounts, parties, creatures, and inventory.
6. Add economy systems after combat feels good.
