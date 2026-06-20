# Pet Package Format Notes

These notes capture the Bitbud package contract used by `apps/prismtek-buddies-desktop`.

## Package files

```text
pet.json
spritesheet.webp
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

| Row | State | Frames |
| --- | --- | ---: |
| 0 | `idle` | 6 |
| 1 | `running-right` | 8 |
| 2 | `running-left` | 8 |
| 3 | `waving` | 4 |
| 4 | `jumping` | 5 |
| 5 | `failed` | 8 |
| 6 | `waiting` | 6 |
| 7 | `running` | 6 |
| 8 | `review` | 6 |

Prismtek Buddies should load pet packages without mutating them.
