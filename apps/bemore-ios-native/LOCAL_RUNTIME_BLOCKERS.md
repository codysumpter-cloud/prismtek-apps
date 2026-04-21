# Local Runtime Blockers

This file records the exact blockers for honest on-device runtime completion on current `main`.

## Current state

- `apps/bemore-ios-native/BeMoreAgentShell/BeMoreAgentShellApp.swift` still boots `AppState(engine: MLCBridgeEngine())`.
- `apps/bemore-ios-native/project.yml` still has `dependencies: []`.
- `apps/bemore-ios-native/BeMoreAgentShell/RuntimeServices.swift` only runs real local generation behind `#if canImport(MLCSwift)`.
- When `MLCSwift` is unavailable, the app falls back to the stub response path and explicitly says the result is simulated.

## Exact blockers

1. There is no runtime package or vendored framework wired into the iOS target today.
2. There is no packaged, app-loadable local model library flow proven for this target.
3. There is no device-level proof on current `main` showing a selected local model generating a real response on-device.
4. Because those pieces are missing, any PR that claims the local runtime is complete would be dishonest.

## Honest definition of done

A local-runtime PR is only complete when all of the following are true:

- the iOS target has a real runtime dependency wired in
- a local model can be selected from `Models`
- the app generates a real response on-device without using a cloud route
- the result is verified on a concrete device/model pair and reported with exact details

Until then, the shell should keep treating local runtime work as blocked rather than shipped.
