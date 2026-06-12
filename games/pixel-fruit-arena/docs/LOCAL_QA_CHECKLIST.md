# Pixel Fruit Arena Local QA Checklist

Use this checklist for local smoke testing only. Do not use it to claim platform verification unless the exact platform was tested.

## Startup

- Serve the game over HTTP from `games/pixel-fruit-arena/`.
- Confirm the main menu renders without console errors.
- Confirm starting a 2-player match reaches the arena.

## Controls

- Confirm Player 1 keyboard movement, jump, attack, special, dodge, and awaken inputs respond.
- Confirm Player 2 keyboard movement, jump, attack, special, dodge, and awaken inputs respond.
- If a controller is connected, confirm the browser Gamepad API maps movement, jump, abilities, dodge, awaken, and menu input.

## Character Creator

- Edit name and appearance values.
- Reload the page and confirm the profile persists locally.
- Switch equipped fruit and confirm the selected fruit persists locally.

## Combat Smoke Test

- Confirm damage increases after attacks connect.
- Confirm knockback scales as damage rises.
- Confirm ring-outs reduce stocks and respawn players.
- Confirm the match ends when a winner remains.

## Release Safety

- Run the build script.
- Confirm `dist/assets/reference` is not present.
- Confirm no `.gif` files are present in `dist`.
- Confirm reference assets remain development-only.

## Platform Notes

- Web browser support requires actual browser testing.
- Windows, macOS, Steam Deck, RGDS Android, and RGDS Linux support must not be marked verified unless each device/platform is tested directly.
