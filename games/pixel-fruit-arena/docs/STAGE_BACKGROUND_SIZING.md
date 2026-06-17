# Stage Background Sizing

Pixel Fruit Arena renders at a fixed internal arena size of `960 x 540`.

Stage images should not be repeated or stretched directly. The renderer uses a fitted-image helper for stage textures.

- `cover` fills the arena and center-crops overflow.
- `contain` preserves the full image and letterboxes inside the arena.

Default behavior is `cover`.

After adding new stage images or tilesets, refresh the generated catalog with `npm run catalog:assets` and check it with `npm run validate:catalog`.
