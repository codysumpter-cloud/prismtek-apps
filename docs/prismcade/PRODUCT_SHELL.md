# Prismcade Product Shell

Status: **local-first product slice**

This document describes the first player-facing Prismcade shell added on top of the manifest/catalog and portable avatar contracts.

## Product promise

Prismcade should feel like a retro/pixel indie-game platform where a player can say:

> This is my Prismcade character, these are my games, these are my friends, these are my scores, and I can bring my look into the next game.

That means the home screen must not feel like a repository index. It must foreground identity, play, friends, chat, leaderboards, and creation.

## Added surfaces

```txt
apps/prismcade/
  index.html              # Player-facing Home shell

apps/prismcade-avatar/
  index.html              # Local-first Avatar Locker / export-plan shell
```

## Home shell responsibilities

`apps/prismcade/index.html` keeps loading:

```txt
data/prismcade/game-manifests.json
```

It adds a product shell around that registry:

- local account/avatar card;
- featured game shelf;
- quick-play shelf;
- competitive/showcase shelf;
- avatar-compatible shelf;
- compatibility badges inferred from current manifest roles;
- Buddy chat panel;
- friends/party placeholders;
- leaderboard preview;
- local match receipt preview;
- links to the Avatar Locker and Creator MVP.

This is intentionally honest. It does **not** claim hosted accounts, real purchases, hosted leaderboards, or online multiplayer are done.

## Avatar Locker responsibilities

`apps/prismcade-avatar/index.html` reads, when served from repo root:

```txt
data/prismcade/character-template-registry.json
data/prismcade/game-manifests.json
```

It exposes the Prismcade formula:

- one source template;
- layered hair / clothing / accessory choices;
- sprite sizes from 32x32 through 256x256;
- camera/view modes: `side`, `top_down`, `low_top_down`, `isometric`, `arena_2_5d`, and `profile_lobby`;
- required animation checklist;
- game compatibility preview;
- PixelLab / Pixel Forge export-plan JSON;
- local avatar save to the same `localStorage` account key used by the home shell.

## Local account model

The first shell uses browser `localStorage` under:

```txt
prismcade.localAccount.v0
```

This is a stub for local play, account previews, avatar inventory, and match receipts. A hosted profile service should come later, after local receipts and compatibility declarations are stable.

## Product rule

Every Prismcade game should become more valuable because it can plug into shared identity:

1. profile identity first;
2. portrait / mini fallback second;
3. full view-specific avatar runtime when ready;
4. local receipt after play;
5. leaderboard export before hosted leaderboard;
6. hosted social only after the local loop is reliable.

## Next implementation slices

1. Add explicit `avatarSupport` declarations to `data/prismcade/game-manifests.json` instead of relying on UI inference.
2. Wire Pixel Fruit Arena to `loadPrismcadeCharacterForView(..., { viewMode: "side", size: 64 })`.
3. Add a shared match receipt emitter package and use it from quick-play games first.
4. Generate the low-top-down Prismtek runtime for the hub / locker proof.
5. Add local inventory item definitions and unlock receipts.
6. Add hosted account / friends / leaderboard adapters only after local receipts are stable.
