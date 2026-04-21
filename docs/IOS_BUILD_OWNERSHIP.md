# iOS Build Ownership

`prismtek-apps` is now the current owner of the BeMore iOS product build and release lane.

The working native iPhone project inputs live here in `apps/bemore-ios-native`, and the current repo-owned GitHub Actions path also lives here.

## Rule

Treat `prismtek-apps` as the canonical product repo for the native iPhone app source, build docs, and iOS workflow references unless and until there is a deliberate rename or re-home.

## Current assets already in this repo

This repo now contains:
- the real native BeMore iPhone app path in `apps/bemore-ios-native`
- XcodeGen `project.yml`
- `Info.plist`
- export options plist for upload
- handoff and build docs for the current native app path
- current repo-owned iOS workflow files

## Current workflow ownership

The active repo-owned iOS workflows are:
- `.github/workflows/bemoreagent-platform-ios-validate.yml`
- `.github/workflows/bemore-ios-ci-testflight.yml`

## Practical boundary

`prismtek-apps` owns:
- native app source and project inputs
- product-facing iOS build/release docs
- workflow references and repo-side release hygiene for the native app

`bmo-stack` still owns:
- deeper operator/runtime posture
- policy and council behavior
- runtime contracts and integration depth that the app consumes

## Current status

As of the current repo state, this repo is already the canonical iOS project and workflow owner. The remaining work is to keep the release lane green and the docs truthful, not to keep describing the working iOS project as if it lives somewhere else.
