# TamerNet Battle Sandbox

A playable browser prototype for the Prismtek creature-MMO direction. It uses original placeholder creatures and no external franchise assets.

## Run it

From this folder:

```bash
npm run dev
# or
python3 -m http.server 8080
```

Then open:

```text
http://localhost:8080
```

You can also open `index.html` directly in a browser.

## Validate and package

```bash
npm test
npm run build
npm run package:zip
```

Expected local web artifact:

```text
artifacts/tamernet-battle-sandbox-web.zip
```

A public downloadable release still needs a GitHub Release or itch.io receipt.

## Nintendo DS source

A compact DS source layout lives in [`ds-homebrew/`](ds-homebrew/).

```bash
cd ds-homebrew
make
```

Expected local DS output:

```text
tamernet_battle_sandbox_ds.nds
```

CI validates the DS source receipt. The `.nds` output still needs a devkitPro/libnds build and device or emulator receipt.

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
- Capture chance based on HP and proximity.
- Alpha contribution scoring placeholder.
- Log and HUD.
- Browser smoke test and local ZIP packaging path.
- Compact Nintendo DS source layout.

## Remaining release work

- Server authority.
- Multiplayer and PvP duel mode.
- Marketplace, breeding, economy, legendary custody, and BYO-file importer.
- Published web ZIP or itch.io page.
- Verified `.nds` build receipt.

## Platform readiness

| Platform | Status | Evidence / gap |
| --- | --- | --- |
| Web browser | Verified | Browser entrypoint, canvas runtime, and smoke test are present. |
| Downloadable ZIP / itch.io | Partially verified | `npm run package:zip` creates a local web ZIP path; public upload receipt is still required. |
| Windows | Partially verified | Browser source and ZIP script exist; Windows runtime receipt is still required. |
| macOS | Unverified | No macOS runtime receipt yet. |
| Linux / Steam Deck | Unverified | No Linux or Steam Deck runtime/controller receipt yet. |
| RGDS Android mode | Unverified | No RGDS Android browser/WebView receipt yet. |
| RGDS Linux mode | Unverified | No RGDS Linux browser/launcher receipt yet. |
| Nintendo DS | Partially verified | DS source layout exists and is statically validated; `.nds` build/device receipt is still required. |
