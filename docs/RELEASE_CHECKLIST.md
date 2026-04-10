# Release Checklist

This is a lightweight release-prep checklist for `prismtek-apps`.

## Before release-oriented changes merge

- confirm the release-related work belongs in this repo
- confirm whether the workflow is already product-owned here or still transitional
- update ownership docs if the release path moved or changed

## If BeMore iOS release behavior is involved

- check `docs/BEMORE_IOS_BUILD_MIGRATION.md`
- check `docs/BUILD_OWNERSHIP_AUDIT.md`
- note whether the workflow is still owned elsewhere

## Release-path hygiene

- avoid duplicating release truth across repos
- avoid moving a working release path without a tested replacement
- keep product-owned release automation close to the product repo over time

## After release-path changes

- update docs
- record transitional ownership if it still exists
- note what still has to migrate later
