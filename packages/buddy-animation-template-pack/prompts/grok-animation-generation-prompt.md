# Grok prompt: Buddy animation generation

Use this prompt when asking Grok to generate a new Buddy sprite sheet, animated GIF, or animation expansion from the Prismtek Buddy reference format.

```text
You are generating a Prismtek Buddy-compatible pixel-art animation sheet.

Goal:
Create a new Buddy variant and animation set that matches the Prismtek Buddy animation contract.

Style rules:
- Hard-edged pixel art.
- No blur.
- No antialiasing.
- Transparent background unless a preview GIF needs a simple flat backdrop.
- Keep the same Buddy silhouette, outline weight, and readable face proportions.
- Make every pose readable at 64x64.
- Use consistent lighting and palette across all frames.
- Do not copy any franchise character or commercial sprite style.

Frame target:
- Runtime target: 64x64 per frame.
- Optional master target: 128x128 per frame if extra detail is needed, but the final game sheet must be compatible with 64x64.

Required animations:
1. idle — 6 frames, looping, subtle breathing.
2. blink — 3 frames, non-looping or held.
3. walk — 8 frames, looping.
4. run — 8 frames, looping, stronger squash/stretch.
5. jump — 5 frames, non-looping.
6. land — 4 frames, non-looping.
7. happy — 6 frames, looping or short emote.
8. shocked — 6 frames, short emote.
9. thinking — 6 frames, looping.
10. hurt — 4 frames, non-looping.
11. faint — 6 frames, non-looping.
12. melee_slash — 7 frames: anticipation, slash, hit spark, recovery.
13. melee_jab — 6 frames: windup, jab, hit spark, recovery.
14. melee_spin — 8 frames: spin attack with readable circular motion.
15. charge — 8 frames: aura buildup.
16. magic_cast — 8 frames: Buddy channels energy and releases.
17. projectile_launch — 8 frames: projectile appears, launches, trail frame.
18. status_effect — 8 frames: buff/debuff aura, stars, sparkles, or smoke.
19. victory — 8 frames.
20. defeat — 6 frames.

Sheet layout:
Use row-per-state. Every cell must be the same size.

Rows:
0 idle
1 blink
2 walk
3 run
4 jump
5 land
6 happy
7 shocked
8 thinking
9 hurt
10 faint
11 melee_slash
12 melee_jab
13 melee_spin
14 charge
15 magic_cast
16 projectile_launch
17 status_effect
18 victory
19 defeat

Output:
1. A single PNG sprite sheet.
2. A preview GIF showing idle, melee_slash, magic_cast, projectile_launch, and victory.
3. A JSON manifest matching buddy-animation-manifest-v1.

Manifest requirements:
- variantId
- displayName
- frame width/height
- sheet path
- animation frame rows/columns
- fps
- loop flags
- hitFrames for melee attacks
- provenance

Quality bar:
The result should look like a small reusable RPG buddy companion that can be dropped into a DS/3DS-style pixel game, a web canvas game, or a Buddy chat UI.
```

## Optional remix instruction

```text
Make the variant feel like a tiny magical RPG companion with expressive eyes, goofy charm, and readable attack silhouettes. Keep it original to Prismtek/Buddy and do not reference copyrighted characters.
```
