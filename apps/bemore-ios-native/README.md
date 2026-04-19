# BeMoreAgent iOS Shell

Native SwiftUI iPhone shell for the BeMoreAgent operator stack.

## Current product shell

The app is no longer just a thin operator shell. The strongest shipped wedge is now a standalone Buddy experience on iPhone:

- companion care with visible return-friendly stats
- customization across name, focus, palette, ASCII style, and identity expression
- training and taught-preference loops that persist locally
- collectible Buddy roster growth from the starter pack
- lightweight local sparring with persisted battle records
- trade-ready Buddy export/import packages with validation

The shell still exposes the broader technical surfaces too:

- `Control` for Mission Control style operator visibility over live local state, routing posture, provider linkage, and persistence health.
- `Models` as the primary route and model control surface for local installs, cloud route activation, and active-route visibility.
- `Chat` for conversation history and file-context assisted prompts.
- `Buddy` for the bundled Council Starter Pack, local Buddy installs, personalization, active-Buddy continuity, and receipt-backed check-ins/training.
- `Files` for app-scoped workspace imports.
- `Settings` for provider editing, maintenance, shell management, and storage summaries.

The shell persists local state under app-scoped Application Support, including:

- chat history
- workspace file copies
- installed model metadata
- provider configuration
- runtime selection
- tab order and visibility
- buddy library state and runtime events
- operator preferences

The Buddy surface now bundles repo-owned canonical Buddy contracts and starter content from the
main `BeMore-stack` repo. Installing or personalizing a Buddy persists:

- `State/buddy-instances.json`
- `.openclaw/state/buddy-runtime-events.json`
- `.openclaw/buddy.md`
- `.openclaw/buddies.md`

Bundle identity continuity matters for this state. See [`BUILD_14_CONTINUITY_NOTE.md`](./BUILD_14_CONTINUITY_NOTE.md) for why build 14 could look like a fresh install after the bundle identifier briefly changed.

## Runtime posture

This subtree does not claim a completed on-device runtime. It builds without `MLCSwift` by falling back to a stub local engine boundary, and real local inference still depends on packaging and wiring an actual runtime.

Today the honest split is:

- local state, model import/download, route selection, and shell persistence are real
- Buddy care, training, collection, sparring, and trade package loops are real
- cloud chat routes are real when the operator links valid provider credentials
- on-device inference remains gated on the missing runtime package and packaged model libraries

## Quick start

```bash
brew install xcodegen
cd apps/openclaw-shell-ios
xcodegen generate
xcodebuild -project BeMoreAgent.xcodeproj \
  -scheme BeMoreAgent \
  -sdk iphonesimulator \
  -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath .build/DerivedData \
  build
open BeMoreAgent.xcodeproj
```

Admin and release notes live in [`ADMIN_TESTFLIGHT_RUNBOOK.md`](./ADMIN_TESTFLIGHT_RUNBOOK.md).

## Operator notes

- Use `Models` to choose the active local model or cloud route.
- Use `Settings` to edit provider credentials and manage tab visibility/order.
- Use `Control` to inspect the companion-first home and then optional operator depth.
- Use `Buddy` to care for a Buddy, train them, build a roster, spar locally, export/import trade
  packages, and only then reach for deeper operator behavior if needed.
- Buddy actions regenerate the readable `.openclaw/buddy.md` and `.openclaw/buddies.md` continuity
  files alongside the machine-readable JSON state.

## Known limits

- The local runtime path is still a stub unless the runtime package is added and configured.
- Provider testing depends on real upstream credentials and network reachability.
- Simulator builds can be blocked by host-side Xcode/CoreSimulator state even when the project files are valid.
- Live marketplace selling, billing, moderation, and networked trading are not part of this shell
  wedge yet; the current phone-first implementation ships real local trade package export/import and
  a standalone Buddy loop first.
