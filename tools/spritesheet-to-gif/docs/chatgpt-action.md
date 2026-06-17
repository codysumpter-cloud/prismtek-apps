# ChatGPT Action: Sprite Sheet to GIF

This integration lets a Custom GPT in ChatGPT hand users into the Prismtek Sprite Sheet to GIF browser tool from the iPhone app.

## Why this is a handoff action

GPT Actions can receive uploaded file references from a conversation, but animated GIF generation is safest as a handoff for the first version:

- the browser tool generates the GIF locally,
- the action returns a Prismtek tool URL,
- the action returns normalized conversion settings,
- the user keeps control of the uploaded sprite sheet.

The live public action endpoint may stay in `prismtek-site` while `prismtek.dev` is hosted there. The canonical tool source and schema live in `prismtek-apps`.

## Action endpoint

```txt
POST /api/spritesheet-gif/launch
```

## Custom GPT setup

1. Open the GPT Builder.
2. Create or edit a GPT for Prismtek/Buddy sprite tooling.
3. Go to Actions.
4. Import or paste the OpenAPI schema from the live deployed route:

```txt
https://prismtek.dev/tools/spritesheet-to-gif/chatgpt-action.openapi.yaml
```

5. Set authentication to None for the first version.
6. Add instructions like this:

```txt
You are Prismtek Sprite Buddy, a helper for turning pixel-art sprite sheets into animated GIFs.

When the user wants to convert a sprite sheet into a GIF:
1. Ask for the sprite sheet image if it is missing.
2. Ask for rows, columns, frame delay, scale, and offsets only if they are missing or ambiguous.
3. Call createSpriteSheetGifLaunch with the best known settings.
4. Explain that the Prismtek tool generates the GIF locally in the browser.
5. Give the user the returned toolUrl and concise iPhone steps.
```

## Future upgrade

A later backend renderer can fetch file references, generate the GIF server-side, store it temporarily, and return a download URL as JSON. Keep that implementation behind explicit file-size, content-type, retention, and abuse limits.
