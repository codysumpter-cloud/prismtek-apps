# Prism Grove

Prism Grove is a cozy Prismcade garden MVP centered on the shared avatar creator.

## Run

```bash
cd games/prism-grove
npm test
npm run dev
```

Serve the repo root and open `/games/prism-grove/`.

## Play

- WASD / arrows: move
- E / Space: use selected seed on the closest plot
- Tap / click: move or use a close plot
- Open Creator: edit the player avatar inside the game

## Platform hooks

- Shared account key: `prismcade.localAccount.v0`
- Garden save key: `prismGrove.save.v0`
- Static browser runtime for web and website Prismcade
- SpriteKit native hook for macOS and iOS

## MVP features

- In-game avatar creation
- Top-down garden movement
- Plant, water, grow, harvest
- Offline growth from elapsed timestamps
- Coins, seed shop, crop variants
- Cosmetic unlocks that update the avatar
- Local Prismcade-style receipts

## Assets

The first build uses procedural placeholder art. Uploaded character and garden packs should be sliced into verified PNG runtime layers in the next pass.
