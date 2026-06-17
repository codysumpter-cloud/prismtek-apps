# Prismcade Game Manifest Contract

Status: **v0 manifest contract**

The Prismcade game manifest is the handoff between game folders, the catalog, the creator/editor, asset tooling, release packaging, and future platform services.

Machine-readable source:

```txt
data/prismcade/game-manifests.json
```

Validator:

```bash
npm run prismcade:validate
# or
node tools/prismcade/validate-game-manifests.mjs
```

## Required game fields

Each game entry must include:

| Field | Purpose |
| --- | --- |
| `id` | Stable lower-case ID used by tooling. |
| `title` | Human-facing title. |
| `slug` | URL/file-system safe slug. |
| `path` | Repo-local game folder. |
| `status` | Honest readiness label. |
| `arcadeRole` | Product role, such as `platform-fighter` or `quick-play-arcade`. |
| `priority` | `high`, `medium`, or `later`. |
| `description` | Short catalog description. |
| `tags` | Catalog/search tags. |
| `thumbnail` | Planned or actual thumbnail path. |
| `entrypoint` | Browser entrypoint or launch target. |
| `commands` | `dev`, `test`, `build`, and `package` commands where available. |
| `controls` | Readable controls summary. |
| `players` | Minimum and maximum player count. |
| `inputSupport` | Keyboard, pointer/touch, and gamepad support flags. |
| `platformStatus` | Honest platform readiness. |
| `platformHooks` | Local profile, receipt, share-card, and leaderboard readiness. |
| `assets` | Asset manifest and provenance notes. |
| `receipts` | Runtime/package/device evidence or missing receipts. |
| `nextActions` | Concrete next work. |

## Status values

Use honest labels only:

- `playable-mvp`
- `playable-prototype`
- `quick-play-import`
- `large-showcase-prototype`
- `contract-only`
- `blocked`

## Platform hooks

Do not mark these true until there is code or a local receipt:

```json
{
  "localProfileReady": false,
  "localHistoryReady": false,
  "matchReceiptReady": false,
  "shareCardReady": false,
  "leaderboardExportReady": false,
  "hostedLeaderboardReady": false
}
```

## Release claim rule

A game can say it has a local ZIP path if `npm run package:zip` exists.

A game cannot say it has a public downloadable release until there is a GitHub Release, itch.io upload, or other durable public artifact receipt.

A game cannot claim a device/platform is verified until a specific test receipt exists.
