# Prismtek Pixel Forge Integration Plan

Status: **foundation implemented**

Prismtek Pixel Forge is the clean-room, Prismtek-owned version of the pixel-art asset workflow Cody wanted from Pixellab-style tooling.

It should not copy Pixellab.ai's product, backend, models, hosted MCP server, private prompts, or proprietary implementation. Public SDKs and editor extensions are useful only as workflow references: request construction, animation categories, image import/export, and provider integration boundaries.

## What this PR adds

```txt
tools/pixel-forge/
  README.md
  index.html
packages/pixel-asset-pipeline/
  package.json
  src/index.mjs
  tests/pixel-asset-pipeline.test.mjs
services/pixel-forge-mcp/
  README.md
  package.json
  src/server.mjs
data/integrations/pixellab-character-export-registry.json
docs/integrations/prismtek-pixel-forge.md
```

## Existing Prismtek work checked first

Before creating Pixel Forge, the repo already had several pieces that should be reused instead of rewritten:

1. **iOS PixelLab preview client**
   - `apps/bemore-ios-native/BeMoreAgentShell/Services/PixelLabClient.swift`
   - `apps/bemore-ios-native/BeMoreAgentShell/Services/PixelLabPreviewService.swift`
   - Existing behavior: optional linked PixelLab preview generation, local asset caching, and secure credential boundaries.

2. **Sprite Sheet to GIF tool**
   - `prismtek-site` PR #72 added the public `/tools/spritesheet-to-gif/` route and GPT Action handoff.
   - `prismtek-apps` PR #174 adopts that tool as the canonical app/tool source.
   - Pixel Forge should use or link to that GIF exporter rather than duplicate its encoder.

3. **Buddy animation template pack**
   - `prismtek-apps` PR #175 adds `packages/buddy-animation-template-pack/`.
   - Pixel Forge is stacked on that branch so its defaults align with 64x64 Buddy/Grok animation contracts.

4. **Game and integration adapter registry**
   - Existing integration docs and manifests already distinguish contracts, adapters, receipts, and blocked third-party asset copying.
   - Pixel Forge follows that policy: provider adapters later, deterministic local validation first.

## Product boundary

Pixel Forge owns:

- deterministic sprite-sheet slicing metadata,
- canonical Prismtek animation slot naming,
- 64x64 runtime target validation,
- 128x128 source/master warning rules,
- manifest generation,
- provider-neutral prompt/job creation,
- MCP tools for ChatGPT/Codex/local agents,
- provenance and originality reminders.

Pixel Forge does **not** own yet:

- hosted image generation,
- file storage,
- generated binary asset commits,
- model weights,
- provider credentials,
- automatic GitHub commits from generated assets,
- moderation review for public creator uploads.

## Provider adapter path

Later provider adapters should implement this shape:

```txt
provider job JSON
  -> provider adapter
  -> generated sprite sheet
  -> generated manifest
  -> deterministic validation
  -> originality/provenance receipt
  -> optional GIF preview
  -> repo export or user download
```

Recommended providers:

| Provider | Role | Safety note |
| --- | --- | --- |
| `manual` | User draws/uploads sprite sheet. | Safest default. |
| `pixellab-compatible` | Optional hosted pixel-art generation. | Credentials must stay in secure storage or deployment environment. |
| `openai-image` | Prompt/reference image generation. | Must still pass pixel cleanup and manifest validation. |
| `comfyui-local` | Local workflow experimentation. | Keep workflow files and model licenses reviewed. |
| `aseprite` | Manual polish/export plugin target. | Do not copy third-party extension source into Prismtek. |

## First user-facing flow

1. User opens `tools/pixel-forge/index.html`.
2. User uploads a sprite sheet.
3. Tool validates frame grid using default 64x64 frames.
4. User previews selected animation frames.
5. Tool exports `prismtek-pixel-asset-manifest-v1` JSON.
6. User or agent runs MCP validation before committing the manifest.
7. Optional follow-up: send the manifest to Sprite Sheet to GIF for preview exports.

## MCP usage

The MCP server exposes deterministic, non-network tools:

- `validate_pixel_asset`
- `slice_sprite_sheet`
- `build_animation_manifest`
- `validate_animation_manifest`
- `build_generation_prompt`
- `build_provider_job`
- `list_animation_slots`
- `list_pixellab_template_pack`
- `build_pixellab_character_export_descriptor`
- `build_pixellab_animation_job_plan`

This gives ChatGPT/Codex a safe integration point now, before any hosted generation is added.

## Repeatable PixelLab export loop

The real PixelLab MCP owns account state, generation jobs, and export downloads. Pixel Forge owns deterministic planning around those outputs.

Recommended loop for Buddy, Prismtek, Female Character Blue Hoodie, and Ponytail Guy:

1. Run `list_characters(limit=50)` in the PixelLab MCP and confirm the target character IDs.
2. Run `get_character(character_id=...)` for each target and record status, directions, size, completed animations, pending jobs, failed jobs, and download URL.
3. Feed that metadata into `build_pixellab_character_export_descriptor`.
4. Feed the descriptors into `build_pixellab_animation_job_plan` with the core template slots: `idle`, `walk`, `run`, `hurt`, `jump`, `melee_thrust`, `melee_spin`, and `projectile`.
5. Review the emitted `animate_character(...)` calls and confirm the PixelLab generation budget before queueing any missing jobs.
6. Poll `get_character` until pending jobs are complete and failed jobs are retried or intentionally skipped.
7. Download the export packet with `curl --fail <downloadUrl>` only after PixelLab reports the packet is ready.
8. Convert the export packet into game-ready sheets/manifests through Pixel Forge validation, then use the Sprite Sheet to GIF flow for preview.

The current account snapshot is stored in `data/integrations/pixellab-character-export-registry.json`. As of June 17, 2026, Buddy has existing animations, Prismtek has 56 animations and an export-ready packet with one failed `fight-stance-idle-8-frames(north-east)` job, and Female Character Blue Hoodie plus Ponytail Guy need animation jobs before they are fully template-covered. Buddy and Prismtek both have useful generated animations that need curation and polish before they become shippable. Prismtek Jones, PrismBot Pixel God, and Prismtek Pixel God are tracked as usable source sprites. The BMO variants are tracked as a 4-direction source group; preserve them as cardinal-direction sprites unless a separate 8-direction derivative is generated.

## Security and IP rules

- Do not commit provider credentials.
- Do not ship third-party reference images as production assets.
- Do not clone Pixellab branding, UI, backend, private prompts, or model internals.
- Every generated or imported asset needs provenance.
- Any public creator upload flow needs file size limits, content-type checks, retention policy, abuse controls, and moderation review.

## Next PRs

1. Merge/adopt the Sprite Sheet to GIF tool and link it from Pixel Forge.
2. Add asset export tooling that writes generated manifests under game-local `assets/` paths.
3. Add a secure provider adapter interface with deployment-secret injection only.
4. Add server-side GIF preview generation with strict temporary storage limits.
5. Add Aseprite export/import docs and a clean-room Prismtek extension skeleton.
