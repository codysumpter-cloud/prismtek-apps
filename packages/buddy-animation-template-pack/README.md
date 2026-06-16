# Buddy Animation Template Pack

This package defines the reusable Buddy/Grok animation template format for Prismtek sprite companions.

It exists so Grok, ChatGPT, Codex, and future Buddy workers can generate new Buddy variants and animation GIFs with the same frame layout, naming rules, animation states, and metadata contract.

> Important: this commit stores the source template contract directly in the repo. The original ZIP archive and binary PNG sprite sheets were not available to the execution environment, so the binary `reference/*.png` files are reserved by name but not committed in this source-only import.

## Target path

```text
packages/buddy-animation-template-pack/
```

## What this pack owns

- canonical animation state names,
- sprite-sheet grid conventions,
- DS/3DS/retro-friendly sizing guidance,
- required buddy variant metadata,
- reusable Grok prompt templates,
- reusable ChatGPT/Codex handoff templates,
- examples for melee, emotes, idle, movement, and RPG-style attacks.

## Expected binary reference files

When the original image files are available, place them in `reference/` using these exact names:

```text
reference/Buddy_Full_Sprite_Sheet.png
reference/Buddy_Grok_Idle_Sprite_Sheet.png
reference/Buddy_Grok_Emote_Sprite_Sheet.png
reference/Buddy_Grok_Attack_Sprite_Sheet.png
reference/Buddy_Grok_RPG_Effects_Sprite_Sheet.png
```

The source contract in this package is designed to remain useful even before those binary files are added.

## Sprite size guidance

Use **64x64 frames** as the default game-ready target.

Use **128x128 frames** only for master/reference sheets that need extra detail before downsampling or hand-cleanup.

Recommended export stack:

1. Generate or draw at 128x128 when detail matters.
2. Clean hard-edged pixel silhouettes.
3. Downsample/redraw to 64x64 for runtime sheets.
4. Keep all animation states aligned to the same frame box.
5. Avoid antialiasing, blur, mixed palettes, and mismatched outline weights.

## Required layout

```text
packages/buddy-animation-template-pack/
  README.md
  package.json
  metadata.json
  reference/
    README.md
    EXPECTED_FILES.md
  animation-contract/
    BUDDY_ANIMATION_CONTRACT.md
    animation-schema.json
  prompts/
    grok-animation-generation-prompt.md
    chatgpt-storage-handoff-prompt.md
  examples/
    buddy-animation-manifest.example.json
    buddy-variant.example.json
```

## Usage

Give `prompts/grok-animation-generation-prompt.md` to Grok along with one or more reference sheets. Grok should output a new sprite sheet and/or GIF that matches `animation-contract/animation-schema.json`.

Give `prompts/chatgpt-storage-handoff-prompt.md` to a new ChatGPT/Codex session when the output needs to be stored back into this repository.

## Buddy animation families

The first shared Buddy animation set should include:

- idle,
- blink,
- breathe,
- walk,
- run,
- jump,
- land,
- hurt,
- faint,
- wave,
- happy,
- shocked,
- thinking,
- charge,
- melee slash,
- melee jab,
- melee spin,
- magic cast,
- projectile launch,
- RPG status effect,
- victory,
- defeat.

## Safety and provenance

- Store only original Prismtek/Buddy assets or clearly licensed assets.
- Do not commit copied franchise sprites.
- Do not ship third-party reference art as production assets.
- Keep generated outputs marked with model/tool provenance in `metadata.json` or per-variant manifests.
