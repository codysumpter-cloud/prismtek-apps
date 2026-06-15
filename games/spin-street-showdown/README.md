# Spin Street Showdown

An original customizable spinning-top arcade prototype. The current web build now targets a higher-quality battle-top feel: richer graphics, stronger dome physics, clearer impacts, deeper build-driven mechanics, RPM-first combat, short rounds, driver-tip attack patterns, stadium pitch physics, drastic part archetypes, interchangeable Bit Beasts, and a more polished arena presentation.

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

- Mouse or touch: steer toward the pointer, with movement biased by the equipped driver tip
- Hold left click or Space: charge burst
- Shift: strike dash at lower speed, counter guard at high speed/charge
- E: trigger the equipped Bit Beast ability when the purple meter is full
- WASD or arrow keys: steer

## Competitive Controls

P1: WASD or arrows steer, Space charges, Shift strike dash/counter guard, E Bit Beast.

PvP P2: IJKL steers, U charge, O strike dash/counter guard, P Bit Beast.

## Current Features

- Twelve-round single-player street circuit
- Local PvP mode for head-to-head dome matches
- Three primary build styles: **Attack**, **Defense**, and **Stamina**
- Drastic archetype multipliers so parts alter damage, speed, mass, HP, stability, charge, grip, RPM max, and RPM drain
- Attack builds hit harder, charge faster, and take sharper lines, but burn RPM and stability faster
- Defense builds are heavier, harder to knock away, and better at guard/rim survival, but have slower steering commitment
- Stamina builds have larger RPM pools, lower RPM drain, stronger orbit play, and better late-round timeout pressure
- Interchangeable Bit Beast slot replacing the old generic Spirit Chip role
- Each Bit Beast has a passive and a usable ability
- Bit Beast examples: Astral Lynx, Chrome Wyvern, Vault Turtle, Pulse Raven, Comet Wolf, Neon Kirin, Grav Bull, and Volt Jackal
- PvP diversity loadouts so P1 and P2 start with meaningfully different archetypes instead of mirrored builds
- 40-second match clock with timeout decisions based on RPM, HP, and stability control
- RPM meter that drains over time, during charging, during dash commitments, and from bad collisions
- Low RPM wobble pressure that makes movement less stable before a top is fully outspun
- Oval dome arena with center-pull bowl physics, rim pressure, rail grind, rail crash damage, and skid marks
- Stadium pitch physics: climbing the dome wall slows movement and drains RPM, dropping back down accelerates, and circular/tangential movement preserves speed
- Driver tip attack patterns that change mouse/touch steering instead of making every top follow the cursor identically
- Driver personalities: Drift orbits, Needle anchors, Skate rides the rail, Switch cuts direction, Sprint commits outward, Spiral hunts in a corkscrew, Chrome holds heavy lines, and Dash favors sharp angles
- Improved collision mechanics using relative velocity, mass, grip, tangential bite, burst timing, guard mitigation, stagger, stability loss, RPM drain, and perfect-angle hits
- Large slash arcs, sparks, shockwaves, floating hit text, and screen shake on major clashes
- Build-driven top feel across Attack Ring, Weight Core, Driver Tip, and Bit Beast
- 64 original parts per slot, 256 total parts in the catalogue
- Premium canvas graphics: layered dome lighting, animated rings, radial highlights, rendered teeth, cores, driver fins, chip gems, rarity glow, trails, sparks, shockwaves, floating impact text, and screen shake
- Upgraded arena presentation shell: neon background, glass HUD, scanline overlay, rounded cabinet frame, cinematic panel lighting, and premium bench/shop cards
- CPU rivals that orbit, bait, rush, and recover from the rim instead of just drifting forward
- Cash, repair, and overdrive pickups between clashes
- Part shop with speed, mass, damage, grip, HP, charge, stability, style, Bit Beast passive, and Bit Beast active modifiers
- Responsive canvas layout for PC and handheld browser devices
- Browser smoke test, quality smoke test, RPM combat smoke test, and local ZIP packaging path

## Build system

Spin Street Showdown now treats each part as a PvP identity choice rather than a tiny stat bump.

| Slot | Main purpose | Examples of playstyle impact |
| --- | --- | --- |
| Attack Ring | Contact threat and clash angle | Higher damage, sharper bite, bigger perfect-angle rewards. |
| Weight Core | Defense, mass, and survivability | More HP, more stability, stronger guard/rim survival. |
| Driver Tip | Movement pattern | Orbit, anchor, rail-skate, sprint, spiral, heavy-line, or dash-angle steering. |
| Bit Beast | Passive + usable ability | Pounce, cyclone, shell, siphon, rush, regen, anchor, or feint abilities. |

## Bit Beast examples

| Bit Beast | Style | Usable ability | Passive identity |
| --- | --- | --- | --- |
| Astral Lynx | Attack | Pounce Burst | Angle hits build extra Spirit and bite harder. |
| Chrome Wyvern | Defense | Iron Cyclone | Guard spin reduces knockback and RPM loss. |
| Vault Turtle | Defense | Shell Lock | Rail crashes cost less HP and stability. |
| Pulse Raven | Stamina | Tempo Siphon | Orbiting the dome preserves more RPM. |
| Comet Wolf | Attack | Meteor Rush | Dash impacts get higher launch and hit sparks. |
| Neon Kirin | Stamina | Regen Current | Low RPM wobble recovers faster. |
| Grav Bull | Defense | Anchor Drop | Mass advantage matters more in clashes. |
| Volt Jackal | Attack | Spark Feint | Direction changes and dash timing create feints. |

## Slayblade clip lessons applied

The design takeaway from the Slayblade reference is **juice plus clarity**, not copying assets or lore.

Applied in this build:

- simple readable dome combat
- 40-second arcade match pressure
- bottom-center RPM meter as the obvious stamina/momentum resource
- RPM drain from time, charge, dash, rail pressure, and collisions
- stadium pitch effects where climbing bleeds speed, dropping adds speed, and orbiting preserves speed
- driver tip attack patterns that modify player intent and movement lines
- timeout wins based on RPM control instead of only HP
- perfect-angle clash feedback with large slash arcs
- strong hit feedback through sparks, shockwaves, shake, floating callouts, and skid marks

## Visual quality target

Spin Street Showdown should feel closer to a polished downloadable battle arena than a flat browser demo. The benchmark is not copied assets or copied lore; it is presentation quality:

- bold arena framing
- readable top silhouettes
- bright rim lighting
- strong hit feedback
- layered HUD treatment
- collectible-looking parts
- immediate rematch readability

## Design target

The game should compete with polished battle-top games by making every clash readable and skillful:

- **Graphics:** tops should look layered, collectible, and distinct by build.
- **Mechanics:** Attack, Defense, Stamina, RPM, charge, guard, dash, stability, driver tip attack patterns, Bit Beast actives/passives, and Spirit Surge timing should create real decisions.
- **Physics:** mass, grip, stadium pitch, uphill/downhill speed exchange, rim angle, tangential contact, and perfect-angle impact timing should change outcomes.
- **Feel:** impacts should pop with slash arcs, sparks, shockwaves, hit text, and camera shake without becoming unreadable.

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
| Web browser | Verified | Browser entrypoint, upgraded runtime, shared arcade smoke test, quality smoke test, and RPM combat smoke test are present. |
| Downloadable ZIP / itch.io | Partially verified | `npm run package:zip` creates a local web ZIP path; public upload receipt is still required. |
| Windows | Partially verified | Browser source and ZIP script exist; Windows runtime receipt is still required. |
| macOS | Unverified | No macOS runtime receipt yet. |
| Linux / Steam Deck | Unverified | No Linux or Steam Deck runtime/controller receipt yet. |
| RGDS Android mode | Unverified | No RGDS Android browser/WebView receipt yet. |
| RGDS Linux mode | Unverified | No RGDS Linux browser/launcher receipt yet. |
| Nintendo DS | Partially verified | DS source layout exists and is statically validated; `.nds` build/device receipt is still required. |
