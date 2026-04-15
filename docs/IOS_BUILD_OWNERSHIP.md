# iOS Build Ownership

`prismtek-apps` is the intended long-term owner of BeMore iOS product build and release automation.

At the moment, `BeMore-stack` still owns the working BeMoreAgent iOS validation and TestFlight workflows.
That is a transitional state, not the target state.

## Rule

Do not move release workflow ownership here until the actual iOS project inputs live in this repo.

## Required assets before workflow migration

Before canonical iOS build ownership can move here, this repo should contain:
- a real BeMore iOS app path
- XcodeGen `project.yml`
- `Info.plist`
- export options plist for TestFlight upload
- any build/runbook files needed for release

Recommended target path:
- `apps/bemore-ios`

## Intended future workflows

Once the project lives here, this repo should own:
- `.github/workflows/bemore-ios-validate.yml`
- `.github/workflows/bemore-ios-testflight.yml`
- optional: platform-specific validation workflow only if a second iOS target still exists

## Safe migration order

1. Keep the working path alive in `BeMore-stack`
2. Re-home the iOS project here
3. Port validate workflow here
4. Port TestFlight workflow here
5. Mirror repo variables and secrets here
6. Prove one real upload from this repo
7. Then demote old workflow ownership in `BeMore-stack`

## Current status

As of now, this repo is the product monorepo, but it is not yet the canonical iOS release owner.
That changes only after the project and workflows are proven here.
