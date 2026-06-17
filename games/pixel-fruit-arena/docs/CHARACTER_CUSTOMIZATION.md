# Pixel Fruit Arena Character Customization

This PR adds the first repo-stored customizable player bodies for Pixel Fruit Arena.

## Playable bodies

- `male_basic`
- `female_basic`

Both bodies are stored as lightweight pixel-style SVG sprite sheets under:

```text
assets/characters/prismtek-custom/
```

They are registered in:

```text
src/assets/assetManifest.js
```

and can be selected from the character creator and lobby body picker.

## Customization layers

The renderer now draws cosmetic layers on top of the selected body sprite so the existing customization values are visible in-game:

- hair style
- hair color
- skin tone
- clothing style
- outfit primary color
- outfit trim color
- accessory color

The customization is drawn as crisp pixel rectangles on the canvas, which keeps it visually aligned with the existing tiny-hero character style and avoids needing a separate baked sprite sheet for every possible outfit combination.

## Clothing styles

Current clothing style ids:

```text
runner
jacket
hoodie
armor
robe
skirt
gi
coat
```

## Hair styles

Current hair style ids:

```text
crest
bob
spikes
cap
long
ponytail
mohawk
hood
```

## Runtime behavior

- New profiles default to `male_basic`.
- Guest defaults rotate through male, female, and existing tiny-hero bodies.
- Training dummy uses `female_basic`.
- Existing saved profiles continue to load and get missing customization defaults filled in.
- The service worker caches the new SVG body sheets for offline/PWA use.
