# Local Runtime Implementation Plan

This file exists to save implementation time and avoid rediscovering the current iPhone runtime boundary.

Use it as the execution map for replacing the current stub local runtime with a real on-device inference path and native iPhone capability bridges.

## Current boundary you should start from

### Exact source files

- App entrypoint: `apps/bemore-ios-native/BeMoreAgentShell/BeMoreAgentApp.swift`
- Runtime/model/download/state boundary: `apps/bemore-ios-native/BeMoreAgentShell/RuntimeServices.swift`
- Runtime blockers summary: `apps/bemore-ios-native/LOCAL_RUNTIME_BLOCKERS.md`
- Current truthful shell summary: `apps/bemore-ios-native/BE_MORE_AGENT_STATUS.md`
- Native iOS handoff docs: `apps/bemore-ios-native/HANDOFF.md`
- Current Xcode target definition: `apps/bemore-ios-native/project.yml`
- Main iOS validate/TestFlight workflow: `.github/workflows/bemore-ios-ci-testflight.yml`
- Current TestFlight runbook: `apps/bemore-ios-native/ADMIN_TESTFLIGHT_RUNBOOK.md`

### Exact current runtime facts

- `BeMoreAgentApp.swift` still boots `AppState(engine: MLCBridgeEngine())`
- `RuntimeServices.swift` already contains:
  - `Paths`
  - `DownloadCenter`
  - `ModelSourceValidator`
  - `ModelCatalogStore`
  - `LocalLLMEngine`
  - `MLCBridgeEngine`
  - `AppState`
- `RuntimeServices.swift` already stages models in `Application Support` under `Paths.modelsDirectory`
- `RuntimeServices.swift` already downloads/imports model assets and tracks installed model metadata
- the real local path is currently hidden behind `#if canImport(MLCSwift)`
- the current non-runtime path returns an explicit simulated/stub response
- `project.yml` still has `dependencies: []`

Practical meaning:

You do **not** need to invent a new runtime architecture from scratch. The repo already has one central runtime/service file. The work is to replace the fake path with a real one, split responsibilities where needed, and prove it on device.

## Implementation goal

Deliver a real on-device path that can:

1. resolve a selected local model
2. verify the asset exists and is loadable
3. load the model on a real iPhone
4. generate a first token from a tiny prompt
5. cancel or unload cleanly
6. survive memory pressure honestly
7. expose native iPhone powers through typed app-approved actions, not fake shell claims

## Non-goals

Do **not** pretend iOS has Mac shell parity.

Do **not** claim arbitrary local process execution, arbitrary filesystem access outside the sandbox, or silent message sending.

Do **not** mark the local runtime complete based on simulator-only validation.

## Recommended execution order

### Phase 1 — make the runtime observable before making it stronger

Work in or around `RuntimeServices.swift` first.

Add:

- structured runtime event logging
- explicit state transitions for load / generate / cancel / unload / fail
- clear error classification for:
  - missing model file
  - invalid model asset
  - runtime dependency unavailable
  - generation returned empty output
  - memory warning / runtime unload
  - request cancelled

Minimum event list:

- model selection changed
- model path resolved
- model file existence verified
- load started
- load finished
- first token received
- generation finished
- cancel requested
- unload requested
- unload finished
- memory warning received
- failure class + message

Acceptance for Phase 1:

- logs or receipts make it obvious whether the app hung, returned empty output, or hit a runtime/memory failure
- no more black-box local runtime behavior

### Phase 2 — split the runtime owner cleanly

If `RuntimeServices.swift` becomes too dense, extract a focused runtime set of types while keeping call sites small.

Suggested split:

- `LocalBrainService.swift`
- `LocalInferenceEngine.swift`
- `ModelStore.swift`
- `MemoryPressureCoordinator.swift`
- `RuntimeDiagnostics.swift`

You do not have to use these exact filenames, but the responsibilities must exist.

At minimum, one owner should own:

- selected model
- load / unload lifecycle
- single in-flight generation
- cancellation
- memory-pressure reaction

Acceptance for Phase 2:

- one clear local-runtime owner exists
- model lifecycle is no longer spread across unrelated UI state

### Phase 3 — make the smallest real on-device path work

Start with the smallest viable model / quantization path that the actual target device can handle.

Do **not** start by chasing the biggest model.

The first prompt should be tiny and deterministic, for example:

- `Reply with OK.`

Acceptance for Phase 3:

- selected local model loads on a real iPhone
- first-token generation is proven with logs/screenshots/receipt text
- empty response path is treated as failure, not success

### Phase 4 — harden asset staging

The repo already stages model assets under `Paths.modelsDirectory` in Application Support.

Improve this path with:

- manifest metadata for each installed model
- checksum verification if available
- explicit “file missing / invalid / corrupt” errors
- clear mapping from selected UI model to actual local file + runtime library name

Acceptance for Phase 4:

- model selection cannot silently point at a missing or unusable file
- the UI can explain why a selected model is not runnable

### Phase 5 — memory pressure honesty

Add a dedicated memory-pressure coordinator and test the unload path.

Requirements:

- respond to iOS memory warnings
- unload model on warning/critical pressure
- do not keep pretending the runtime is ready after an unload event
- surface a user-visible explanation when pressure forced an unload

Acceptance for Phase 5:

- on-device memory pressure results in a classified runtime event, not a mystery failure
- runtime state recovers cleanly or reports why it cannot

### Phase 6 — unlock iPhone power through native actions

Do **not** wire model text directly to side effects.

Instead:

1. model proposes a typed action
2. app validates it
3. native framework executes it
4. app returns a user-visible receipt/result

First native actions to ship:

- create reminder / reminder draft
- message draft / compose flow with user approval
- local memory save
- share/action extension handoff into app context
- one App Intent path for Shortcut/Siri access

Acceptance for Phase 6:

- BeMore can do more useful iPhone-native work without pretending it has unrestricted system powers
- every side effect is typed, reviewable, and receipt-backed

## Concrete file targets for native power work

These file names may differ in the repo, but the implementation should land near the native iPhone app target in `apps/bemore-ios-native/BeMoreAgentShell/`.

Suggested additions:

- `NativeAction.swift`
- `ReminderActionHandler.swift`
- `MessageDraftHandler.swift`
- `BuddyMemoryStore.swift`
- `BeMoreShareExtension` target or equivalent extension target
- `BeMoreAppIntents.swift`

If the repo already has a better organizational pattern, follow that instead of forcing these names.

## Current workflow / release facts you should not fight

- current build number on `main` is `41`
- main iOS workflow lane is `.github/workflows/bemore-ios-ci-testflight.yml`
- `bemoreagent-platform-ios-validate.yml` is **not** the main `apps/bemore-ios-native` lane

## Validation checklist

### Runtime validation

Required evidence:

- real-device proof of selected model path
- real-device proof of model load
- real-device proof of first token
- proof of cancel/unload path
- proof of memory warning handling if triggered during testing
- exact working device + model asset + quantization notes

### Native power validation

Required evidence:

- reminder create/draft flow works
- message compose flow opens with the intended content
- share/action extension can hand content into app context
- App Intent route is discoverable and executes the intended action

### Release validation

Required evidence:

- current build lane remains green after runtime/native-power changes
- build 41 is treated as the current source-of-truth build unless App Store Connect requires a newer one
- do not claim TestFlight success without a successful upload run

## Definition of done

This work is only done when all of the following are true:

- the app no longer relies on a fake stub response for the selected local route
- a real iPhone can produce first-token output from a selected local model
- runtime failures are observable and classified
- at least one useful native iPhone action path is shipped through typed actions
- docs remain honest about what is on-device vs cloud vs runtime-backed
- CI/TestFlight lane still works after the change

## If time is limited

Ship in this order:

1. runtime observability
2. smallest real local model path
3. memory-pressure unload
4. reminder action
5. share/action extension
6. message compose draft
7. App Intent

That order gives the most real product value with the least wasted iteration.
