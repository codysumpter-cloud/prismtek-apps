# Reference files

The package now includes the available binary reference files from `Prismtek_Buddy_Grok_Template_Pack.zip` and keeps the missing attack/effects sheets reserved by exact filename.

| File | Purpose | Status |
| --- | --- | --- |
| `Buddy_Full_Sprite_Sheet.png` | Largest full Buddy sheet / canonical silhouette and palette source. | Committed. |
| `Buddy_Grok_Idle_Sprite_Sheet.png` | Idle, breathe, blink, and small loop references. | Committed. |
| `Buddy_Grok_Emote_Sprite_Sheet.png` | Expression and social emote references. | Committed. |
| `Buddy_Grok_Idle_Animation_Strip.png` | Horizontal idle strip reference exported from the ZIP. | Committed. |
| `Buddy_Grok_Emote_Animation_Strip.png` | Horizontal emote strip reference exported from the ZIP. | Committed. |
| `Buddy_Grok_Attack_Sprite_Sheet.png` | Melee slash, jab, spin, hit, and impact timing references. | Reserved; not present in the ZIP. |
| `Buddy_Grok_RPG_Effects_Sprite_Sheet.png` | Za-style RPG attack effects, projectiles, buffs, debuffs, and status effects. | Reserved; not present in the ZIP. |

## Import note

The first source-only PR reserved all canonical filenames because the active environment did not have the ZIP bytes. The follow-up import added the five PNGs that were present in `Prismtek_Buddy_Grok_Template_Pack.zip`; it did not rename the idle/emote strips into attack or effects sheets.

## Integrity fields

`metadata.json` records SHA-256 hashes for committed PNGs:

```json
{
  "binaryAssets": {
    "status": "partial-committed",
    "sha256": {
      "reference/Buddy_Full_Sprite_Sheet.png": "..."
    }
  }
}
```
