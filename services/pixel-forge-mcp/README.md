# Prismtek Pixel Forge MCP

This service exposes the deterministic Prismtek Pixel Forge pipeline to MCP-capable agents.

It is intentionally **not** a PixelLab clone and it does not store API keys. It provides the clean-room pieces Prismtek owns:

- sprite-sheet grid validation,
- frame rectangle slicing,
- asset manifest generation,
- animation slot listing,
- safe prompt/provider-job construction,
- manifest validation.

## Run locally

```bash
node services/pixel-forge-mcp/src/server.mjs
```

Smoke test:

```bash
npm --prefix services/pixel-forge-mcp run smoke
```

## Tools

| Tool | Purpose |
| --- | --- |
| `validate_pixel_asset` | Validate image dimensions and 64x64/128x128 frame constraints. |
| `slice_sprite_sheet` | Produce frame rectangles for a sprite sheet. |
| `build_animation_manifest` | Build a Prismtek manifest from frame indexes and provenance. |
| `validate_animation_manifest` | Validate a generated manifest before committing it. |
| `build_generation_prompt` | Produce a safe provider prompt for original sprite sheets. |
| `build_provider_job` | Produce provider-neutral generation job JSON. |
| `list_animation_slots` | Return the canonical Buddy/Prismtek animation slot IDs. |

## ChatGPT / Codex config shape

Use this from a local MCP client that supports stdio servers:

```json
{
  "mcpServers": {
    "prismtek-pixel-forge": {
      "command": "node",
      "args": ["services/pixel-forge-mcp/src/server.mjs"]
    }
  }
}
```

For a hosted ChatGPT connector, wrap these tools in a remote HTTPS MCP transport. Keep provider tokens in deployment secrets, never in repo files or prompt text.

## Provider boundary

Pixel Forge can later call Pixellab, OpenAI image generation, Replicate, ComfyUI, or a local model through adapter packages. Those adapters should consume `build_provider_job` output and return original assets plus provenance receipts. This MCP server does not make network calls in the foundation PR.
