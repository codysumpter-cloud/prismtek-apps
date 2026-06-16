# Nintendo DS platform notes

This folder tracks DS homebrew platform research for Prismtek Apps.

## Repo rule

Only original Prismtek code and assets should ship from this repository unless a third-party dependency has a clear, compatible license and attribution path.

Public source repositories may still be unsuitable for direct vendoring when the license is missing, non-commercial only, or tied to another game brand.

## Current direction

Use external DS projects as local research references, then rebuild the useful platform patterns as Prismtek-owned templates:

- devkitPro/devkitARM build layout
- Makefile-based DS builds
- sprite and tile conversion pipelines
- dual-screen UI patterns
- touch controls
- small asset budgets
- save/load patterns
- entity culling for handheld performance

Local third-party checkouts belong under `.external/` or `third_party/local/`; both are ignored by git.
