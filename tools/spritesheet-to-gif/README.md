# Sprite Sheet to GIF

This is the canonical Prismtek Apps source for the browser-based sprite sheet to GIF tool.

Ownership note: `prismtek-apps` owns the runnable tool source. `prismtek-site` may host or mirror the deployed `/tools/spritesheet-to-gif/` route and Cloudflare Pages handoff endpoint for `prismtek.dev`, but product/tool source changes should start here.

## What it does

- Converts pixel-art sprite sheets into animated GIFs locally in the browser.
- Supports rows, columns, frame delay, scale, start/end frame, and top/bottom/left/right offset trimming.
- Provides a grid preview and extracted-frame preview before export.
- Keeps processing local; no sprite sheet upload is required for the browser export path.

## Files

```txt
tools/spritesheet-to-gif/
  index.html
  chatgpt-action.openapi.yaml
  README.md
  docs/chatgpt-action.md
```

## Run locally

Open `index.html` directly in a browser, or serve the repo root with any static server and open:

```txt
/tools/spritesheet-to-gif/
```

## Site deployment relationship

The live public route can still be served from `prismtek-site` because that repo owns `prismtek.dev` and its Cloudflare Pages Functions. The source-of-truth implementation lives here so the tool can be reused by games, asset workflows, Buddy tooling, and future packaged Prismtek Apps surfaces.
