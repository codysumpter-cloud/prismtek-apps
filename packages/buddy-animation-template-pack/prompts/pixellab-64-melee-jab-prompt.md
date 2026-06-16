# PixelLab 64x64 Buddy Melee Jab Prompt

Use this prompt when PixelLab.ai should generate the canonical **64x64** Buddy melee-jab animation strip for DS/3DS/retro gameplay targets.

## Main prompt

```text
Create a production-ready pixel-art animation strip for the character Buddy using the uploaded Buddy reference image as the source of truth.

Animation name: melee_jab

Canvas and format:
- 8-frame horizontal animation strip
- 64x64 pixels per frame
- final strip size: 512x64
- transparent background
- no checkerboard background
- no labels
- no text
- no extra UI
- crisp pixel art only
- no blur
- no anti-aliasing
- no painterly shading

Character rules:
Buddy must stay exactly recognizable as the same cute round creature from the reference:
- round aqua/cyan body
- pale face panel
- dark navy outline
- tiny feet
- tiny side nub arms only
- antler-like top nubs
- small center head spike
- yellow heart charm on the chest
- cute retro RPG creature proportions

Do not change Buddy's anatomy.
Do not add humanoid arms.
Do not add fists.
Do not add muscles.
Do not add long legs.
Do not make Buddy into a biped fighter.
Do not zoom in or crop the sprite.
Do not make a single hero pose.
Do not change the character design between frames.

Animation direction:
Make a cute creature-RPG style melee jab using Buddy's existing body only. The attack should read through body motion, squash/stretch, a tiny nub-arm movement, a short forward lean, and a small impact effect.

Frame plan:
1. Neutral idle pose, centered, feet on baseline
2. Anticipation squash, Buddy leans slightly backward
3. Buddy begins leaning forward, tiny side nub arm lifts slightly
4. Quick forward jab using body lean and tiny nub swipe
5. Impact frame with a small star/burst effect in front of Buddy
6. Recoil bounce backward
7. Settle back toward neutral
8. Neutral idle loop frame

Motion rules:
- Keep Buddy centered in every 64x64 frame
- Keep feet aligned to the same bottom-center baseline
- Use only small motion smear effects
- Motion smear must be separate from Buddy's body
- Motion smear must not look like a giant arm or fist
- Impact effect should be small, readable, and separate from the character
- Keep the heart charm readable on front-facing frames
- Keep the outline thickness and palette consistent across all frames

Style target:
Cute polished retro pixel-art monster battle sprite. Clean enough to use as the canonical animation template for future Buddy variants.

Required output:
- one 8-frame horizontal strip at 512x64
- if possible also export:
  - melee_jab_sheet.png as a 4x2 sprite sheet using the same 8 frames
  - melee_jab.gif as a preview loop
```

## Negative prompt

```text
bad anatomy, humanoid arms, giant fist, muscular limbs, long legs, biped fighter, boxing pose, superhero pose, cropped character, zoomed-in portrait, single illustration, inconsistent character, changed design, blurry, anti-aliased, painterly, smooth digital art, checkerboard background, opaque background, text, labels, UI, messy sprite sheet, different character each frame, extra accessories, weapon, glove, realistic lighting, 3D render
```

## Notes

- This is the game-ready target prompt. Do not silently swap it back to 128x128.
- If a 128x128 master is needed later, store that as a separate prompt and explicitly mark it as master/reference only.
- The expected 4x2 sheet size for this 8-frame animation is `256x128`.
