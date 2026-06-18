# Character View Retargeting

Prismcade retargeting maps one character identity onto multiple camera/view templates.

The point is not to rotate a finished sprite. The point is to preserve identity while changing the pose system, projection, anchors, timing, directions, and runtime layout.

## Identity source

Every multi-view character should have an identity contract.

For Prismtek Fixed Hair:

```txt
packages/game-assets/characters/prismtek-fixed-hair/identity/identity.json
```

The identity contract owns:

- hair;
- face;
- eyes;
- skin tone;
- outfit;
- shoes;
- palette;
- pixel style;
- negative constraints like no ponytail and no bald fade gap.

## Template maps

Template maps describe how a view should be produced.

For Prismtek Fixed Hair:

```txt
packages/game-assets/characters/prismtek-fixed-hair/templates/side-template-map.json
packages/game-assets/characters/prismtek-fixed-hair/templates/low-top-down-template-map.json
packages/game-assets/characters/prismtek-fixed-hair/templates/top-down-template-map.json
packages/game-assets/characters/prismtek-fixed-hair/templates/isometric-template-map.json
packages/game-assets/characters/prismtek-fixed-hair/templates/profile-lobby-template-map.json
```

Each template map defines:

- the view;
- the source identity;
- the runtime output root;
- template/reference sources;
- required slots;
- timing/frame expectations;
- QA checklist;
- promotion notes.

## Retarget job

The full Prismtek all-view plan lives at:

```txt
data/prismcade/view-retarget-jobs/prismtek-fixed-hair-all-views.json
```

It stages the work in this order:

1. Side playtest runtime.
2. Profile/lobby fallback runtime.
3. Low-top-down economy runtime.
4. Full top-down runtime.
5. Isometric runtime.

## Source policy

External/user-provided packs can guide pose, timing, direction labels, anchors, and layer design.

Do not directly copy unapproved external art into a shipped runtime. Treat those packs as reference/template sources until rights are confirmed.

## Why low-top-down comes first

Low-top-down economy mode gives Prismcade the social platform proof fastest.

It supports:

- Prismcade hub;
- avatar locker;
- shops;
- cozy/social games;
- RPG-style maps;
- profile/lobby fallback upgrades.

It needs fewer frames than full top-down but proves the same-avatar platform idea better than a side-only game.

## Promotion path

A view variant becomes playable when:

- the identity is preserved;
- required slots exist;
- runtime assets are exported;
- the manifest declares the variant as `playtest` or `available`;
- the view-mode validator passes;
- the animation passes human visual QA.

## Loader behavior

Games should use `loadPrismcadeCharacterForView`.

Example:

```ts
const character = await loadPrismcadeCharacterForView(
  "/game-assets/characters/prismtek-fixed-hair",
  { viewMode: "low_top_down", size: 64 },
);
```

If a real `low_top_down` variant is missing, the loader may return a profile/lobby fallback for menus. Gameplay should still require the correct playable variant before launching.
