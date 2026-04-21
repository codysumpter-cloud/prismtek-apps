# BeMoreAgent native iOS status

This file summarizes the current truthful state of the iOS shell on `main`.

## Current source of truth

The native app lives in:

- `apps/bemore-ios-native`

Current shipped shell surfaces include:

- first-run onboarding with persisted stack config
- Mission Control as the post-onboarding landing surface
- Models as the route-control surface for local and cloud selection
- Chat, Skills, Artifacts, Buddy, Files, and Settings tabs
- `.bemore/` workspace artifacts, JSON state stores, action/event logs, and a skills registry
- Pokémon Team Builder as a registry-backed skill that saves JSON and Markdown artifacts
- ClawHub local starter-skill installs that persist manifest and README artifacts
- editable/exportable/deletable Files workspace entries and `.bemore` artifacts
- persisted tab ordering and visibility
- bundled Council Starter Pack Buddy templates with local install flow
- persisted Buddy library state, runtime events, active selection, and personalization
- receipt-backed Buddy check-ins/training that regenerate `.bemore/buddy.md` and `.bemore/buddies.md`
- bundled repo-backed surface briefs inside Mission Control

## Important current behavior

- First launch routes into onboarding until `stackConfig.isOnboardingComplete` becomes true.
- Relaunch returns to the main tab shell after onboarding is complete.
- The local runtime is still stubbed unless a real on-device inference backend is actually present and wired.
- Cloud routes can be configured in Settings and switched in Models.
- Workspace actions run through BeMore runtime receipts. The UI should not claim files, memory,
  skills, or sandbox work completed unless the runtime returns a completed or persisted receipt.
- Buddy install/personalize/check-in/training actions also run through BeMore runtime receipts and
  should not claim continuity updates unless the receipt persisted the Buddy bundle artifacts.
- Cloud/local replies are sanitized before display so hidden reasoning/thought blocks are not shown
  unless the operator explicitly asks for an explanation.
- The iOS sandbox currently exposes controlled BeMore commands (`pwd`, `ls`, `cat`, `write`, `regenerate`,
  `skills`, `help`) rather than arbitrary host shell execution.

## Verified native runtime boundary

These are the current implementation boundaries Codex should use as the starting point:

- `apps/bemore-ios-native/BeMoreAgentShell/BeMoreAgentApp.swift` still boots `AppState(engine: MLCBridgeEngine())`.
- `apps/bemore-ios-native/BeMoreAgentShell/RuntimeServices.swift` already owns model paths, downloads, runtime configuration, and the current stub fallback behavior.
- `apps/bemore-ios-native/project.yml` still has `dependencies: []`.
- `apps/bemore-ios-native/LOCAL_RUNTIME_BLOCKERS.md` captures the current hard blockers for honest on-device inference.
- `apps/bemore-ios-native/LOCAL_RUNTIME_IMPLEMENTATION_PLAN.md` is the repo-native implementation brief for replacing the stub safely.

Practical meaning:

- do not claim real on-device inference until `MLCBridgeEngine()` is replaced or upgraded with a working local engine path
- do not claim iPhone shell parity; on-device power should come from native frameworks, App Intents, extensions, local storage, and a real local model lifecycle
- land local-runtime work only when it produces observable first-token generation on a real iPhone and handles memory pressure honestly

## Local build path

```bash
cd apps/bemore-ios-native
xcodegen generate
xcodebuild -project BeMoreAgent.xcodeproj \
  -scheme BeMoreAgent \
  -sdk iphonesimulator \
  -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath .build/DerivedData \
  build
```

## Release path

- `CFBundleVersion` is currently `41`.
- `IPHONEOS_DEPLOYMENT_TARGET` is currently `26.0`.
- The current repo-owned iOS validate/TestFlight lane is `.github/workflows/bemore-ios-ci-testflight.yml`.
- The separate `.github/workflows/bemoreagent-platform-ios-validate.yml` workflow is for `apps/bemoreagent-platform-ios/**`, not the current `apps/bemore-ios-native` source of truth.
- The operator runbook for the main native iOS upload path is `apps/bemore-ios-native/ADMIN_TESTFLIGHT_RUNBOOK.md`.
- Xcode Cloud is not the required release path for this target right now.

## Honest limits

- `apps/bemore-ios-native/BeMoreAgentShell/BeMoreAgentApp.swift` still boots `AppState(engine: MLCBridgeEngine())`.
- `project.yml` still has `dependencies: []`.
- When the local runtime backend is not actually linked and working, the app still uses the stub local-runtime path and cannot claim real on-device inference.
- Arbitrary codex-style shell/process execution is not available on-device in this build. The current iOS sandbox is a receipt-backed controlled surface rather than a hardened general-purpose process host.
- Buddy Workshop authoring, external package publishing, and marketplace flows are not shipped in this wedge; the source of truth is the bundled canonical starter pack inside `bmo-stack`.

## Next native work

1. replace the stub runtime with a real on-device inference path that proves model staging, load, first token, cancel, and unload
2. add structured diagnostics so silent death vs hang vs empty response can be classified from logs and receipts
3. unlock iPhone power through typed native actions such as Reminders, compose-style messaging, App Intents, and a share/action extension
4. keep shell truth, build docs, and runtime claims aligned with what is actually shipped
5. only mark the local-runtime work complete after real-device validation, not simulator-only validation
