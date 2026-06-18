# Prismcade Character Animation Retargeting

Status: foundation workflow.

This workflow exists because finished sprite warping is not acceptable Prismcade animation quality. The platform should use source animation packs as pose and timing references, then redraw or generate the target character into those poses using Prismcade templates.

## Goal

Turn a target character, such as Prismtek Fixed Hair, into a complete reusable animation pack without squashing or rotating the finished sprite.

## Correct workflow

1. Choose a target character source.
2. Choose a Prismcade rig template.
3. Intake source animation packs.
4. Map source files to canonical animation slots.
5. Generate a retarget job plan.
6. Redraw or generate target-character frames per slot.
7. Validate frame size, transparency, pivots, loops, slots, and provenance.
8. Promote only reviewed animation strips to game-ready assets.

## What not to do

Do not create production animations by simply rotating, skewing, stretching, or squashing the final character sprite. That produces placeholder motion only and should never be promoted as final Prismcade art.

## Retargeting inputs

A retarget job should define:

- target character id;
- target character reference image or package;
- rig template id;
- allowed output sizes;
- source animation packs;
- slot mapping rules;
- output directory;
- review requirements.

## Retargeting outputs

A retarget job should emit:

- retarget plan JSON;
- slot map CSV;
- Pixel Forge or PixelLab prompt plan;
- QA checklist;
- rejected or missing slot report;
- final normalized sheets only after review.

## Source pack role

Source packs are used for pose language, timing, frame count, and slot naming. The output character should still look like the target character. Hair, face, hoodie, shoes, silhouette, palette, and body scale must remain consistent.

## Promotion rule

Generated or placeholder frames start as draft. They become platform animation only after visual review and validation.

## First target job

The first practical target is:

```txt
Prismtek Fixed Hair + compact-chibi-64-side
```

Primary source candidates:

- template_free movement strips;
- metroidvania traversal and combat strips;
- thicc n juicy jump, idle, walk, and climb sheet;
- Prismtek existing showcase and rotation exports;
- Pixel Fruit and Buddy first-party animation sources.
