# Prismcade Publishing Loop

Status: **local-first release path**

Prismcade publishing should stay receipt-driven. The catalog can show prototypes, but public release claims require evidence.

## Local loop

1. Pick or create game manifest.
2. Validate manifest.
3. Run game-specific smoke tests.
4. Build/package static ZIP.
5. Verify the ZIP locally.
6. Record receipt.
7. Publish to GitHub Releases, itch.io, or a hosted route.
8. Only then update the public release status.

## Commands

```bash
npm run games:validate-support
npm run prismcade:validate
npm run references:validate
npm run integrations:validate
```

Game examples:

```bash
cd games/pixel-fruit-arena
npm test
npm run build
npm run validate:dist
npm run package:zip
```

```bash
cd games/spin-street-showdown
npm test
npm run package:zip
```

## Future hosted platform hooks

Do not build these before local receipts are stable:

- accounts / creator pages;
- comments / ratings;
- online ranked;
- hosted leaderboard validation;
- multiplayer authority;
- monetization;
- public UGC upload.

## Receipt shape

Minimum receipt fields:

```json
{
  "gameId": "pixel-fruit-arena",
  "command": "npm run package:zip",
  "artifactPath": "games/pixel-fruit-arena/artifacts/pixel-fruit-arena-web.zip",
  "environment": "local",
  "result": "passed",
  "notes": "Local artifact exists; public upload pending."
}
```

Never include secrets, local credentials, private absolute paths, or raw provider prompts that contain private user details.
