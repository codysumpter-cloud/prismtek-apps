# Pet Package Format Notes

These notes capture the working Bitbud package contract used by `apps/prismtek-buddies-desktop`.

See `product-direction.md` for the cozy room and productivity layer.

## Package location

A pet package lives under `~/.codex/pets/<pet-id>/`.

Bitbud example:

```text
~/.codex/pets/bitbud/pet.json
~/.codex/pets/bitbud/spritesheet.webp
```

## Minimal manifest

```json
{
  "id": "bitbud",
  "displayName": "Bitbud",
  "description": "A tiny original BUAP companion for Cody: playful, practical, brave, warm, and game-like.",
  "spritesheetPath": "spritesheet.webp"
}
```

## Atlas profile observed from Bitbud

| Field | Value |
| --- | --- |
| Atlas size | `1536x1872` |
| Cell size | `192x208` |
| Columns | `8` |
| Rows | `9` |
| Format | RGBA WebP |

## State rows

| Row | State | Frames | Intended use |
| --- | --- | ---: | --- |
| 0 | `idle` | 6 | calm companion presence |
| 1 | `running-right` | 8 | rightward movement |
| 2 | `running-left` | 8 | leftward movement |
| 3 | `waving` | 4 | greeting / friendly attention |
| 4 | `jumping` | 5 | excitement / celebration |
| 5 | `failed` | 8 | error/failure sadness |
| 6 | `waiting` | 6 | waiting on user/tooling |
| 7 | `running` | 6 | working / active task state |
| 8 | `review` | 6 | review/thinking/checking |

## Product rule

Prismtek Buddies should load pet packages without mutating them. The app may preview, animate, and map states to workflow events, but package generation and validation remain separate tooling concerns.

## Future states

Future pets may add richer metadata, alternate atlases, multiple sprite scales, or named animation definitions. Until that contract exists, Prismtek Buddies treats the Bitbud profile above as the default pet atlas profile.
