# Hermes native command center integration

## Intent / product spec

Use the forked Hermes WebUI and Hermes Desktop repositories to improve BeMore's iOS and macOS app surfaces without mixing incompatible stacks.

Hermes WebUI is a self-hosted browser interface for Hermes Agent. Hermes Desktop is an Electron + React + TypeScript desktop shell. BeMore iOS/macOS are SwiftUI apps. The safe product move is to adopt the Hermes interaction model and local-runtime launch contract, not to paste Python, vanilla JS, or Electron renderer code into Swift.

## Implementation / tech spec

This wedge adds:

- an iOS `HermesCommandCenterView` with local WebUI launch, fork links, local launch command, and runtime-boundary guidance
- a visible `Hermes` app tab in the iOS native shell
- a macOS `HermesMacCommandCenterView` source artifact that mirrors the same command-center model for the native Mac shell

The integration uses URLs only:

- `http://127.0.0.1:8787` for local Hermes WebUI
- `http://127.0.0.1:8642` for the local Hermes gateway API
- GitHub fork links for source provenance

No secrets, provider keys, Hermes memory, or live agent state are committed.

## Verification / test plan

1. Run the normal repository checks:

```bash
npm ci
npm run lint
npm run build
```

2. Run the iOS validation workflow or locally generate/build:

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

3. Confirm the iOS app shows a `Hermes` tab after onboarding.
4. Confirm tapping `Open local WebUI` attempts to open `http://127.0.0.1:8787`.
5. Confirm the page clearly states that public exposure of a live Hermes agent session is not allowed without private-network and auth controls.

## Rollback

Revert this PR to remove the Hermes tab, Hermes command-center views, and this spec document. Existing BeMore chat, Buddy, workspace, and model flows are not modified.
