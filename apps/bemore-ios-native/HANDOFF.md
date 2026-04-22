# BeMoreAgent Xcode / TestFlight handoff

Use this guide when handing the native app to someone with a Mac and Apple Developer access.

## App location

- `apps/bemore-ios-native`

## What is already true in the repo

- the app target is `BeMoreAgent`
- the project definition is generated from `project.yml`
- the native iPhone source of truth now lives in this repo
- the current GitHub-hosted iOS validate/TestFlight lane also lives in this repo
- first launch routes into onboarding
- onboarding completion persists locally
- the app has native Home, Chat, Files, and Models surfaces
- the current runtime is still a stub until the real on-device runtime bridge is wired in
- the current repo build number is 42 in `BeMoreAgentShell/Info.plist` after App Store Connect rejected a duplicate upload of 41
- the app currently boots `AppState(engine: MLCBridgeEngine())` from `BeMoreAgentShell/BeMoreAgentApp.swift`
- the current runtime/model/download boundary lives in `BeMoreAgentShell/RuntimeServices.swift`

## Generate and open the project

```bash
brew install xcodegen
cd apps/bemore-ios-native
xcodegen generate
open BeMoreAgent.xcodeproj
```

## Local simulator build check

```bash
xcodebuild -project BeMoreAgent.xcodeproj \
  -scheme BeMoreAgent \
  -sdk iphonesimulator \
  -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath .build/DerivedData \
  build
```

## In Xcode

1. Select the `BeMoreAgent` target.
2. Choose the correct Apple Developer team in Signing & Capabilities.
3. Make sure the bundle identifier is owned by that team.
4. Build on simulator first.
5. Then test on a real iPhone.

## TestFlight

1. In Xcode, choose **Product > Archive**.
2. Open Organizer.
3. Choose **Distribute App**.
4. Upload to App Store Connect.
5. Add internal testers in TestFlight.

## GitHub Actions setup for future PRs and releases

The current repo-owned iOS workflows are:

- `.github/workflows/bemoreagent-platform-ios-validate.yml` for the older `apps/bemoreagent-platform-ios/**` path
- `.github/workflows/bemore-ios-ci-testflight.yml` for the main current `apps/bemore-ios-native` validate + TestFlight lane

Required GitHub repo configuration:

### App Store Connect secrets

- `APPSTORE_CONNECT_API_KEY`
- `APPSTORE_CONNECT_KEY_ID`
- `APPSTORE_CONNECT_ISSUER_ID`

### iOS signing secrets

- `BEMORE_IOS_DISTRIBUTION_CERTIFICATE_P12_BASE64`
- `BEMORE_IOS_DISTRIBUTION_CERTIFICATE_PASSWORD`
- `BEMORE_IOS_APPSTORE_PROFILE_BASE64`

### Optional runner variable

- `BEMOREAGENT_XCODE_DEVELOPER_DIR`

Notes:

- the main iOS workflow is currently pinned to a self-hosted runner label set that includes `prismtek-apps`
- the workflow writes the App Store Connect `.p8` key to a temporary file and uses Xcode authentication-key flags, so it does not depend on an interactive Xcode account login
- keep `.p8` files, signing certificates, and provisioning profiles out of git

## Repo-native runtime implementation aids

Before attempting the real on-device runtime work, start with these repo-native guides:

- `apps/bemore-ios-native/LOCAL_RUNTIME_BLOCKERS.md`
- `apps/bemore-ios-native/LOCAL_RUNTIME_IMPLEMENTATION_PLAN.md`
- `apps/bemore-ios-native/BE_MORE_AGENT_STATUS.md`

These files now point at the exact source files and acceptance criteria Codex should use instead of rediscovering the runtime boundary from scratch.

## Honest limits

This repo is now set up for native Xcode handoff, onboarding demos, model/file management, and repo-owned iOS validation/TestFlight automation. The remaining Mac-only or device-proven work is:

- validating the Xcode build end to end when project structure changes
- replacing the stub runtime with the real local inference backend
- proving each TestFlight submission against the currently configured runner, signing assets, and App Store Connect state
- proving local model load and first-token generation on a real iPhone, not just in the simulator
