# Local Gemma Setup in BeMore iOS

## Goal

BeMore should implement the same practical local-model pattern as Google AI Edge Gallery inside this app:

1. Save a mobile model artifact inside app storage.
2. Verify the artifact shape.
3. Select the matching native runtime.
4. Load the model.
5. Generate fully on-device.

Users should not need a separate gallery app once BeMore links the native runtime.

## Runtime path

The in-app path is:

```text
Models tab
  -> add model source, download, or import from Files
  -> Application Support/BeMoreAgent/Models
  -> LocalBrainService
  -> OnDeviceModelRouterEngine
  -> GoogleModelFileEngine for .task/.bin
  -> MLCBridgeEngine for prepared MLC packages
```

## Supported artifact shapes

Use one of these:

- `.task` for Google task-bundle style model files.
- `.bin` for MediaPipe LLM Inference model files.
- prepared MLC package folder containing:
  - `mlc-chat-config.json`
  - `tokenizer.json`
  - `params_shard_0.bin`

Do not use these as live iOS routes:

- `.gguf`
- `.safetensors`
- `.pt`
- `.pth`
- repository landing pages that are not actual model files

## Native dependency

For the Google mobile path, link the MediaPipe GenAI iOS pods into the app target:

```ruby
target 'BeMoreAgent' do
  use_frameworks!
  pod 'MediaPipeTasksGenAI'
  pod 'MediaPipeTasksGenAIC'
end
```

The Swift import used by the app is:

```swift
import MediaPipeTasksGenai
```

The route initializes `LlmInferenceOptions`, sets `options.baseOptions.modelPath`, then creates `LlmInference` and calls `generateResponse(inputText:)`.

## Validator

From repo root:

```bash
node scripts/validate-gemma-local-model.mjs --path ./apps/bemore-ios-native/LocalModels
```

Strict check:

```bash
node scripts/validate-gemma-local-model.mjs --strict --path ./apps/bemore-ios-native/LocalModels
```

Check a single artifact:

```bash
node scripts/validate-gemma-local-model.mjs --path ~/Downloads/model.task
node scripts/validate-gemma-local-model.mjs --path ~/Downloads/model.bin
```

## Acceptance test

The local route is ready when:

1. The app imports or saves the model file.
2. The validator recognizes it as `.task`, `.bin`, or a prepared MLC package.
3. The app build links the matching native runtime.
4. The Models tab can activate the local route.
5. Chat generates a response with network providers disabled.
6. LocalBrainService records load and generation events.

## Current implementation status

This branch adds:

- `OnDeviceModelRouterEngine`
- `GoogleModelFileEngine`
- `.task` / `.bin` validation pass-through in `LocalBrainService`
- `scripts/validate-gemma-local-model.mjs`
- Models tab routing to the already-compiled `ModelsTabView`, which has add-source, download, import, select, probe, and diagnostics flows

## Remaining runtime work

The native MediaPipe/LiteRT dependency still has to be linked in the Xcode target before `.task` / `.bin` files can produce real tokens. Until then, the app can store and select artifacts, but local generation should report a runtime-missing state rather than pretending to run.
