# Spin Street Showdown

An original customizable spinning-top arcade prototype.

## Play on PC

Open `index.html` in a desktop browser, or run:

```bash
npm run dev
```

## Validate and package

```bash
npm test
npm run build
npm run package:zip
```

Expected local web artifact:

```text
artifacts/spin-street-showdown-web.zip
```

A public downloadable release still needs a GitHub Release or itch.io receipt.

## Controls

- Mouse or touch: steer toward the pointer
- Hold left click: charge
- Release into an opponent: burst hit
- WASD or arrow keys: steer
- Space: charge

## Current Features

- Twelve-round single-player street circuit
- Local PvP mode for head-to-head dome matches
- Oval dome arena with curved rim rebounds and center-pull bowl physics
- Four customizable slots: Attack Ring, Weight Core, Driver Tip, Spirit Chip
- 64 original parts per slot, 256 total parts in the catalogue
- Part-driven top visuals with teeth, cores, driver trails, chip marks, rarity halos, and rival loadouts
- Physics-ish top collisions, wall chip damage, charge timing, burst actions, strike dash, guard stance, and Bit Beast summons
- Cash rewards between rounds
- Part shop with speed, mass, damage, grip, HP, and charge modifiers
- Responsive canvas layout for PC and handheld browser devices
- Browser smoke test and local ZIP packaging path

## Competitive Controls

P1: WASD or arrows steer, Space charges, Shift uses strike dash or guard stance, E summons Bit Beast when the purple meter is full.

PvP P2: IJKL steers, U charges, O uses strike dash or guard stance, P summons Bit Beast.

Moves are designed to matter even without pickups: strike dash creates a deliberate attack vector, guard stance reduces incoming impact when already moving fast, and Bit Beasts add a high-meter pressure tool.

## Nintendo DS source

The DS source lives in [`ds-homebrew/`](ds-homebrew/).

```bash
cd ds-homebrew
make
```

Expected local DS output:

```text
spin_street_showdown.nds
```

CI validates the DS source receipt. The `.nds` output still needs a devkitPro/libnds build and device or emulator receipt.

## Platform readiness

| Platform | Status | Evidence / gap |
| --- | --- | --- |
| Web browser | Verified | Browser entrypoint and shared arcade smoke test are present. |
| Downloadable ZIP / itch.io | Partially verified | `npm run package:zip` creates a local web ZIP path; public upload receipt is still required. |
| Windows | Partially verified | Browser source and ZIP script exist; Windows runtime receipt is still required. |
| macOS | Unverified | No macOS runtime receipt yet. |
| Linux / Steam Deck | Unverified | No Linux or Steam Deck runtime/controller receipt yet. |
| RGDS Android mode | Unverified | No RGDS Android browser/WebView receipt yet. |
| RGDS Linux mode | Unverified | No RGDS Linux browser/launcher receipt yet. |
| Nintendo DS | Partially verified | DS source layout exists and is statically validated; `.nds` build/device receipt is still required. |
