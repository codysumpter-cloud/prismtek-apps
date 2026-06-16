# GameMaker HTML5 Adapter

Status: **contract-only**

This adapter records GameMaker HTML5 as a Prismcade research target. It does **not** vendor the GameMaker HTML5 runtime, GameMaker IDE/runtime binaries, downloaded toolchains, marketplace assets, or generated exports into shipped Prismtek paths.

## Why it matters

Prismcade needs a path for creators who already know GameMaker or want a more advanced editor than the first manifest-based browser creator. GameMaker HTML5 exports are a useful future bridge because Prismcade can potentially wrap a browser export with the same public game page, profile, leaderboard, challenge, and moderation shell already used by Prismtek Arcade.

## Intended future flow

```txt
GameMaker project
  -> local gm-cli validation/build receipt
  -> HTML5 export artifact
  -> Prismcade adapter manifest
  -> Prismtek Arcade /play wrapper
  -> version-aware leaderboard and challenge shell
```

## Allowed work

- Study GameMaker HTML5 export shape.
- Define manifest metadata required to wrap exports in Prismcade.
- Build local-only adapter experiments under `experiments/gamemaker-html5-prismcade-adapter/`.
- Keep export receipts that record tool version, project id, build mode, and generated artifact paths.
- Wrap creator-owned outputs only after license and redistribution review.

## Blocked work

- Do not copy YoYoGames runtime source into shipped Prismtek game paths.
- Do not commit GameMaker IDE/runtime binaries.
- Do not commit marketplace/sample assets without exact provenance.
- Do not accept arbitrary generated JavaScript as trusted Prismcade UGC.
- Do not claim Prismcade supports GameMaker import until one export is validated end-to-end.

## MVP relationship

This is **not** first MVP. Prismcade should first ship manifest-only templates because they are safer, easier to validate, and easier to moderate. GameMaker import/export research becomes useful after Prismcade has:

1. creator game records,
2. published game versions,
3. public UGC play pages,
4. version-aware scoreboards,
5. asset provenance rules.

## Validation checklist before promotion

- A sample original GameMaker project can be built locally without committing toolchain files.
- The resulting HTML5 export can run inside a Prismtek page wrapper.
- The wrapper can emit a Prismcade-compatible run receipt.
- The score path does not trust client-only claims for ranked modes.
- The export artifact includes provenance metadata and rollback notes.
