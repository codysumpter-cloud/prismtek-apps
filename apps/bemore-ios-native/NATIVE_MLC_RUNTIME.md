# Native MLC runtime link checklist

Build 51 goal: link BeMoreAgent's iOS target against the native MLC/TVM runtime and compiled Gemma model library.

## Current contract

The bridge already has a real path behind `BEMORE_MLC_RUNTIME_LINKED=1`. The safe default remains `0` in `Config/MLCRuntime.xcconfig` so CI stays green when native artifacts are absent.

## Package config

Use:

```text
apps/bemore-ios-native/mlc-package-config.json
```

Target model:

```text
HF://mlc-ai/gemma-2-2b-it-q4f16_1-MLC
model_id: gemma-2-2b-it-q4f16_1-MLC
model_lib: gemma2_q4f16_1
device: iphone
```

## Generate artifacts

From `apps/bemore-ios-native`:

```bash
bash scripts/package-mlc-runtime.sh
```

Expected generated libraries under `dist/lib`:

```text
libmodel_iphone.a
libmlc_llm.a
libtvm_runtime.a
libtokenizers_cpp.a
libtokenizers_c.a
libsentencepiece.a
```

## Enable link mode

After the artifacts exist:

```bash
bash scripts/enable-mlc-runtime-link.sh
```

This rewrites `Config/MLCRuntime.xcconfig` with the native library search path, linker flags, and `BEMORE_MLC_RUNTIME_LINKED=1`.

## Verify

```bash
xcodegen generate
xcodebuild -project BeMoreAgent.xcodeproj -scheme BeMoreAgent -configuration Debug -destination 'generic/platform=iOS' CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO build
```

## Definition of done

Do not call local generation complete until a real iPhone proves model load, first token, cancel/unload, and memory-pressure recovery.
