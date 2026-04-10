# @prismtek/sandbox

Product-level sandbox and session adapters for `prismtek-apps`.

## Current role

This package currently exposes sandbox session management used by the product-facing API.

## Direction

Keep this package focused on app-facing adapters.

Deep runtime substrate and execution primitives belong in `openclaw`, not here. This package should stay at the product-integration layer.
