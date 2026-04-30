# Gemma 4 iOS Package Contract

This document prevents the app from drifting back into a model identity mismatch.

## Current decision

BeMoreAgent iOS uses two separate Gemma 4 references:

1. **Implementation/reference repo**
   - `codysumpter-cloud/gemma`
   - Purpose: source/reference fork of the Gemma JAX/PyPI implementation.
   - Not directly bundled into the iOS app.

2. **Prepared iOS MLC package source**
   - `welcoma/gemma-4-E2B-it-q4f16_1-MLC`
   - Purpose: prepared MLC package folder that contains runtime markers and parameter shards.
   - This is the current source used by the TestFlight bundle-prep script.

## Required bundled app shape

The archived app must contain:

```text
BeMoreAgent.app/BundledModels/gemma-4-E2B-it-q4f16_1-MLC/mlc-chat-config.json
BeMoreAgent.app/BundledModels/gemma-4-E2B-it-q4f16_1-MLC/tokenizer.json
BeMoreAgent.app/BundledModels/gemma-4-E2B-it-q4f16_1-MLC/tokenizer.model
BeMoreAgent.app/BundledModels/gemma-4-E2B-it-q4f16_1-MLC/tokenizer_config.json
BeMoreAgent.app/BundledModels/gemma-4-E2B-it-q4f16_1-MLC/params_shard_0.bin
```

The workflow must verify at least:

```text
BundledModels/gemma-4-E2B-it-q4f16_1-MLC/mlc-chat-config.json
BundledModels/gemma-4-E2B-it-q4f16_1-MLC/params_shard_0.bin
```

inside the archived `.app` before claiming TestFlight delivery success.

## Why the fork is not the bundle source yet

`codysumpter-cloud/gemma` is currently a Gemma implementation fork. It is useful for source-level reference and future packaging work, but it does not currently provide the app bundle folder with:

- `mlc-chat-config.json`
- tokenizer files
- `params_shard_*.bin`
- iPhone-ready MLC package metadata

Do not point the iOS bundle-prep script at `codysumpter-cloud/gemma` unless that repo adds a release asset, package folder, or generated MLC artifact with the required shape.

## Future migration path

If Prismtek wants to fully own the package source, add one of these to `codysumpter-cloud/gemma` or a dedicated `codysumpter-cloud/gemma-mlc` repo:

1. GitHub Release asset containing `gemma-4-E2B-it-q4f16_1-MLC.tar.zst`.
2. Git LFS-backed folder containing the full MLC package.
3. CI workflow that runs the official MLC packaging flow and publishes release artifacts.

After that exists, update:

- `apps/bemore-ios-native/scripts/prepare-bundled-mlc-model.sh`
- `apps/bemore-ios-native/BeMoreAgentShell/MLCPackageInstaller.swift`
- `apps/bemore-ios-native/mlc-package-config.json`
- `.github/workflows/bemore-ios-ci-testflight.yml`

and rerun archive verification.

## Non-negotiable checks

Before a build can claim bundled Gemma 4 success:

1. The UI label must say Gemma 4.
2. The model ID must be `gemma-4-E2B-it-q4f16_1-MLC`.
3. The model folder must be `BundledModels/gemma-4-E2B-it-q4f16_1-MLC`.
4. The app archive must include MLC markers and parameter shards.
5. Runtime token generation must not be claimed until the native MLC/TVM runtime is linked and real-device first token is proven.
