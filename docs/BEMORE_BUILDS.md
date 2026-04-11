# BeMore Builds

## macOS Build 1

BeMore Mac Build 1 now lives in `apps/bemore-macos`.

It is a product-owned local workstation slice with:
- workspace selection and file tree browsing
- text file open/edit/save
- command/process runner with output and stop receipts
- task creation and task command launch
- git diff/review state
- artifact and receipt panels
- Buddy state
- iPhone pairing boundary through the runtime snapshot API

The runtime server defaults to loopback:

```sh
npm --workspace apps/bemore-macos run dev
```

Use `BEMORE_MAC_RUNTIME_HOST=0.0.0.0` only when intentionally exposing the runtime for a paired iPhone or trusted tunnel.

## iOS Build 18

The working BeMoreAgent iOS Build 18 source and release validation path still live in `bmo-stack` under `apps/openclaw-shell-ios`.

Build 18 is kept there until the real native project is re-homed into `apps/bemore-ios` and a TestFlight upload is proven from this repo. The current product direction is still BeMore-first: the iOS app can run standalone, and the Build 18 pairing path can inspect BeMore Mac runtime state when the Mac endpoint is intentionally exposed.
