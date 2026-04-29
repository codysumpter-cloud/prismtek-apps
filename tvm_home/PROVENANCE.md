This directory vendors the TVM runtime headers required by the MLCSwift bridge used in `apps/bemore-ios-native`.

Source provenance:
- `include/tvm/**` copied from `mlc-ai/relax` commit `c2028da5ac03055f30a52b492260f37b9650ac03`
- `3rdparty/tvm-ffi/include/tvm/**` copied from `apache/tvm-ffi` commit `1fed0ae0421e614d45662e8ee6bcae353d3ab2ea`
- `3rdparty/tvm-ffi/3rdparty/dlpack/include/dlpack/**` copied from `dmlc/dlpack` commit `84d107bf416c6bab9ae68ad285876600d230490d`

These headers are vendored to satisfy the existing `tvm_home/...` header search paths in the iOS app build without introducing an external checkout requirement into Prismtek CI.
