# Expected reference files

The package contract expects these canonical binary files when the image assets are available:

| File | Purpose | Required now |
| --- | --- | --- |
| `Buddy_Full_Sprite_Sheet.png` | Largest full Buddy sheet / canonical silhouette and palette source. | No — reserved. |
| `Buddy_Grok_Idle_Sprite_Sheet.png` | Idle, breathe, blink, and small loop references. | No — reserved. |
| `Buddy_Grok_Emote_Sprite_Sheet.png` | Expression and social emote references. | No — reserved. |
| `Buddy_Grok_Attack_Sprite_Sheet.png` | Melee slash, jab, spin, hit, and impact timing references. | No — reserved. |
| `Buddy_Grok_RPG_Effects_Sprite_Sheet.png` | Za-style RPG attack effects, projectiles, buffs, debuffs, and status effects. | No — reserved. |

## Why they are reserved instead of committed in this import

The active environment could write text files to GitHub, but it did not have access to the original ZIP archive or PNG bytes. This means the repository now owns the format and path, while the binary asset drop can happen later without changing the package contract.

## Integrity fields to fill after binary import

After the PNG files are added, update `metadata.json` with:

```json
{
  "binaryAssets": {
    "status": "committed",
    "sha256": {
      "reference/Buddy_Full_Sprite_Sheet.png": "..."
    }
  }
}
```
