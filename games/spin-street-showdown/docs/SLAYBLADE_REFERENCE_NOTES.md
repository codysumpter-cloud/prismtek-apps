# Spin Street Showdown Reference Notes

These notes capture the design lessons from the provided Slayblade gameplay clip. They are a quality reference, not a source to copy.

## What the clip showed

- Isometric hub with clear buttons for battle, shop, and customization.
- Simple progression readout with level, EXP, money, and day/time cycle.
- Round dirt arena / stadium bowl.
- Short match timer around 40 seconds.
- Cursor-steered top-down movement.
- Bottom-center RPM meter that drains during combat.
- Large white slash trails, sparks, dust, and impact arcs.
- Clear WIN overlay after a decisive result.

## Design takeaway

The winning formula is **juice plus clarity**.

Spin Street Showdown should be physics-first:

- spin speed
- angle
- collision timing
- arena control
- RPM control
- short chaotic rounds

The fun should come from momentum and contact before any deep inventory system.

## Implemented direction in PR #160

- 40-second match clock.
- RPM HUD and bottom-center RPM meter.
- RPM drains over time, while charging, from dash commitments, rail pressure, and collisions.
- Low RPM creates wobble pressure and eventual outspin loss.
- Timeout decisions compare RPM, HP, and stability.
- Perfect-angle contact creates bigger slash arcs, shake, and callouts.
- Stronger arena presentation: neon shell, glass HUD, scanline overlay, cabinet-style frame, and premium bench/shop cards.

## Future upgrades

- Hub screen with Battle, Shop, Customize, and Tournament buttons.
- Day/time shop refresh loop.
- Local profile with rank, EXP, street reputation, and money.
- Directional techniques: drift, burst dash, guard spin, counter spark, clash, and ring brake.
- More stages: rooftop court, schoolyard chalk ring, subway platform, arcade carpet mat, parking lot oil-slick arena, storm drain lid, neon tournament ring.
