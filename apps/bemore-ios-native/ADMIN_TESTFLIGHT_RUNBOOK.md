# BeMoreAgent PR -> TestFlight admin runbook

This is the single source of truth for producing a BeMoreAgent TestFlight upload from GitHub.

## Safe baseline

- Current safe runtime baseline: `main` uses `MLCBridgeEngine()` from `apps/bemore-ios-native/BeMoreAgentShell/BeMoreAgentApp.swift`.
- Build 52 bundles the prepared Gemma MLC package during the TestFlight archive workflow so testers do not have to download every shard in-app.
- Do not merge speculative local-runtime branches just to force a build green.
- The current source build number in `apps/bemore-ios-native/BeMoreAgentShell/Info.plist` is `52`.

## Required repo state

### Secrets

The `BeMore iOS CI & TestFlight` workflow expects these GitHub repository secrets:

- `APPSTORE_CONNECT_API_KEY`
- `APPSTORE_CONNECT_KEY_ID`
- `APPSTORE_CONNECT_ISSUER_ID`
- `BEMORE_IOS_DISTRIBUTION_CERTIFICATE_P12_BASE64`
- `BEMORE_IOS_DISTRIBUTION_CERTIFICATE_PASSWORD`
- `BEMORE_IOS_APPSTORE_PROFILE_BASE64`

The runner must not rely on Apple automatic certificate creation. It imports the BeMoreAgent
App Store signing certificate and App Store provisioning profile first, then lets Xcode automatic
signing select those existing assets. This avoids the Apple Developer certificate-quota failure:

```text
Choose a certificate to revoke. Your account has reached the maximum number of certificates.
```

Current expected signing inputs:

- Team: `DY9FHPRZA9`
- Bundle identifier: `BeMoreAgent`
- Profile application identifier: `DY9FHPRZA9.BeMoreAgent`
- Profile name: `iOS Team Store Provisioning Profile: BeMoreAgent`
- Certificate: `iPhone Distribution: Cody Sumpter (DY9FHPRZA9)`

If the `.p12` private-key export is blocked by macOS Keychain UI authorization, export it from Keychain
Access on the Mac with the matching private key, base64 encode it, and set the three `BEMORE_IOS_*`
secrets before rerunning `BeMore iOS CI & TestFlight`.

### Runner / variables

The current native iPhone workflow is pinned to a self-hosted runner label set that includes:

- `self-hosted`
- `prismtek-apps`

Optional variable used by the workflow:

- `BEMOREAGENT_XCODE_DEVELOPER_DIR`

This is an optional Xcode path override. If unset, the workflow defaults to `/Applications/Xcode.app/Contents/Developer`.

## What must be true before merge

1. `apps/bemore-ios-native/project.yml` generates cleanly with `xcodegen generate`.
2. `BeMoreAgent` builds for `generic/platform=iOS Simulator`.
3. `apps/bemore-ios-native/project.yml` keeps `PRODUCT_BUNDLE_IDENTIFIER: BeMoreAgent` exactly. Do not change it to a reverse-DNS id unless the Apple identifier itself is changed first.
4. The PR body includes the required task contract when the repo is using that contract for the change.
5. The PR is mergeable and the relevant checks are green.
6. `CFBundleVersion` is higher than the last uploaded build **only if** App Store Connect requires a newer build than the current source value.

## How to ship the current build

1. Branch from current `main`.
2. Make the smallest safe iOS change.
3. Keep `apps/bemore-ios-native/BeMoreAgentShell/Info.plist` `CFBundleVersion` aligned with the intended App Store Connect upload build. Current intended upload is `52`.
4. The TestFlight workflow now runs `scripts/prepare-bundled-mlc-model.sh` before archive and verifies the archived app contains the bundled Gemma MLC package.
5. Run local verification:

```bash
cd apps/bemore-ios-native
xcodegen generate
xcodebuild \
  -project BeMoreAgent.xcodeproj \
  -scheme BeMoreAgent \
  -sdk iphonesimulator \
  -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath .build/DerivedData \
  build
```

6. Open the PR with a clear summary, verification, and rollback notes.
7. Wait for the relevant iOS/native checks to pass.
8. Merge to `main`.
9. Confirm `.github/workflows/bemore-ios-ci-testflight.yml` starts automatically, or run it manually with `workflow_dispatch` if needed.
10. Open the workflow run summary and verify the archived/source version and build number match the intended release.
11. Confirm the summary reports `Bundled Gemma MLC package: yes`.
12. Do not claim success until the upload path actually succeeds.

## Workflow triggers

### Main native iOS validation + TestFlight upload

`.github/workflows/bemore-ios-ci-testflight.yml` runs on:

- pushes to `main` for changes touching `apps/bemore-ios-native/**`, relevant shared packages, or the workflow file itself
- pull requests touching the same paths
- manual `workflow_dispatch`

This is the main current repo-owned lane for the native iPhone app in `apps/bemore-ios-native`.

### Legacy fallback workflow

`.github/workflows/testflight.yml` is a manual fallback only via `workflow_dispatch`.

Do not rely on it as the normal shipping path for `apps/bemore-ios-native`, or it can race the main
TestFlight lane and attempt a duplicate upload for the same build number.

### Separate platform validation workflow

`.github/workflows/bemoreagent-platform-ios-validate.yml` validates `apps/bemoreagent-platform-ios/**`.

Do not confuse that workflow with the current BeMore native iPhone source of truth in `apps/bemore-ios-native`.

## What counts as proof

A release candidate is valid when all of the following are true:

- the intended commit is on `main`
- the `.github/workflows/bemore-ios-ci-testflight.yml` run for that commit succeeds
- the workflow summary shows the expected version/build pair
- the workflow summary shows the bundled Gemma MLC package was present
- there is no archive/export/upload failure in the run logs

## External beta readiness checklist

A build is only considered external-tester ready when **both** the GitHub upload path and the Apple-side TestFlight configuration are complete. Verify all of the following in App Store Connect before announcing external beta availability:

- the uploaded build appears in TestFlight for `BeMoreAgent`
- Test Information is filled in
- Beta App Description is present
- Feedback Email is present
- at least one Internal Testing group exists
- at least one External Testing group exists
- the new build is assigned to the intended External Testing group
- any required Beta App Review is submitted, or Apple already approved the current metadata/build pairing
- the build is not restricted to internal-only availability

If any Apple-side item above is missing, report the exact blocker plainly instead of claiming the build is ready for external testers.

## Current local-runtime note

The local runtime should be rebuilt as a fresh minimal PR from current `main`. Do not merge speculative historical runtime branches as a shortcut. Start from the implementation boundaries documented in `apps/bemore-ios-native/LOCAL_RUNTIME_IMPLEMENTATION_PLAN.md` and prove real-device first-token generation before expanding native power claims.
