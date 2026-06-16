# Prismtek Pixel Forge

Prismtek Pixel Forge is the repo-owned foundation for a Pixellab-style pixel-art asset workflow without copying Pixellab's product, UI, models, or proprietary server code.

The first version is pipeline-first:

- import a sprite sheet,
- validate frame size/grid constraints,
- preview frames and animation timing,
- generate a Prismtek asset manifest,
- generate a safe provider prompt/job for future AI backends,
- keep provenance and originality rules visible.

## Why this lives in `prismtek-apps`

`prismtek-apps` owns the runnable app/tool source for Prismtek games, Buddy tools, asset workflows, packaged apps, and MCP services.

`prismtek-site` may host public routes on `prismtek.dev`, but the source of truth for Pixel Forge belongs here.

## Relationship to existing work

Before adding this tool, the repo already had these relevant pieces:

- `apps/bemore-ios-native/.../PixelLabClient.swift` and `PixelLabPreviewService.swift` for optional linked PixelLab previews in the iOS Buddy path.
- Open PR #174 moving the Sprite Sheet to GIF tool into `prismtek-apps` as a canonical local-browser tool.
- Open PR #175 adding `packages/buddy-animation-template-pack/`, the canonical Buddy/Grok 64x64 animation contract. Pixel Forge is stacked on that branch.
- `prismtek-site` PR #72 added the live `/tools/spritesheet-to-gif/` route and ChatGPT Action handoff.

Pixel Forge does not replace those. It becomes the broader asset lab around them.

## Run locally

Open this file directly in a browser:

```txt
tools/pixel-forge/index.html
```

Or serve the repo root with any static server and open:

```txt
/tools/pixel-forge/
```

## Foundation limitations

This PR does not include:

- hosted image generation,
- copied PixelLab backend code,
- third-party model weights,
- committed binary output images,
- secrets or API tokens,
- direct repo-write automation.

Those should land as separate provider-adapter PRs after the deterministic manifest and validation flow is stable.
