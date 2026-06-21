# Prismcade Game Catalog Parity

This document defines the current catalog-parity target for Prismcade across web, Windows/HTML packaging, and native macOS/iOS.

## Goal

Prismcade should behave like one platform with multiple runtime adapters:

- website / web Prismcade
- Windows/HTML package
- native macOS/iOS Prismcade

Games should not fork into unrelated versions with the same title. If an older web/HTML entry shares a canonical identity with a newer native/canonical game, the newer canonical entry should replace the old duplicate while preserving aliases in docs and manifests.

## Canonical replacement rule

Preferred canonical version order:

1. Polished native/canonical Prismcade version.
2. Maintained HTML/web Prismcade version.
3. Older legacy game entry.
4. Placeholder only when no implementation exists.

Do not show duplicate game cards for the same canonical game.

## Current launch set

| Canonical game | Web/HTML | Windows package | Native macOS/iOS | Website card | Notes |
| --- | --- | --- | --- | --- | --- |
| Flappy Pixel | Present in site/web references | Should map to web package when available | Present in `apps/prismcade-native` | Must show under Prismcade | Native version should supersede older duplicate Flappy entries. |
| Prismtek Dino Dash | Pending / native-first | Pending | Present in `apps/prismcade-native` | Must show under Prismcade | Do not use Google/Chrome Dino assets or naming. |
| Beat Em Up Buck | Pending / native-first | Pending | Present in `apps/prismcade-native` | Must show under Prismcade | Canonical Buck Borris brawler direction. |
| Pixel Fruit Arena | Existing Prismcade-adjacent game | Existing support should be audited | Native parity pending | Should show as playable or planned based on repo truth | Next major polish target. |
| Prism Sky Hunt | Needs discovery/audit | Needs discovery/audit | Native parity pending | Should show as playable or planned based on repo truth | Next major polish target after Pixel Fruit Arena. |

## Native hub requirement

`apps/prismcade-native` should eventually read a canonical game catalog or a generated native subset rather than hardcoding a tiny enum forever.

Until that migration lands, the native hub should keep its hand-coded game list aligned with the canonical catalog and replacement rules in this document.

## Website requirement

`prismtek-site` should visibly surface Prismcade with game cards for canonical Prismcade games. If the website cannot directly consume `prismtek-apps` catalog data, mirror the catalog intentionally and document the sync path.

## Next implementation steps

1. Create or update the canonical catalog in `data/prismcade/`.
2. Add alias/replacement metadata for older Flappy/Buck/Dino entries.
3. Generate or manually sync a native-compatible catalog subset.
4. Update `apps/prismcade-native` hub to use real catalog metadata.
5. Update `prismtek-site` so Prismcade appears with canonical game cards.
6. Stage Pixel Fruit Arena and Prism Sky Hunt as the next polish targets.
