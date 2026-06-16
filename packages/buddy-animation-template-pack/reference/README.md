# Reference assets

This folder is reserved for Buddy reference sheets used by Grok, ChatGPT, Codex, and manual pixel-art cleanup workflows.

The original `Prismtek_Buddy_Grok_Template_Pack.zip` archive was not available in this execution environment, so the binary PNG files are not committed in this import. The expected filenames are still locked down in `EXPECTED_FILES.md` so future sessions can drop the real images into the correct place without inventing new names.

## Add binary sheets later

When GitHub Desktop, VS Code, Codex with file upload, or a local terminal can access the images, add the PNG files here and commit them on this same package path.

```bash
git checkout chore/add-buddy-animation-template-pack
mkdir -p packages/buddy-animation-template-pack/reference
cp /path/to/Buddy_Full_Sprite_Sheet.png packages/buddy-animation-template-pack/reference/
cp /path/to/Buddy_Grok_Idle_Sprite_Sheet.png packages/buddy-animation-template-pack/reference/
cp /path/to/Buddy_Grok_Emote_Sprite_Sheet.png packages/buddy-animation-template-pack/reference/
git add packages/buddy-animation-template-pack/reference/*.png
git commit -m "Add Buddy animation reference sheets"
git push
```

## Style lock

- Hard-edged pixel art only.
- No blur.
- No antialiasing.
- Consistent black or dark-purple outline weight.
- Shared Buddy silhouette across all states.
- Same frame dimensions for every state in a variant.
