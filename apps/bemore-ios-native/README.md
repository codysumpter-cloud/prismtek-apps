# BeMoreAgent iOS Shell

Native SwiftUI iPhone shell for the BeMoreAgent operator stack.

Architecture boundary:
- `prismtek-apps` (this repo) is the iPhone-native primary host and user surface.
- `prismtek-site` / prismtek.dev is the web shell + relay layer.
- `bmo-stack` is canonical for posture, council behavior, skills/manifests, and Codex/runtime discipline.

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

## Skills + capabilities model (iPhone-first)

The app now separates **executable skills** from **built-in tools**:

- Built-in tools (for example GitHub Search and Web Browser) are app/network capabilities and are shown as built-in capabilities, not mislabeled as skills.
- Skills are executable reusable units with registry identity, permissions, run surfaces, and run artifacts.
- User-taught chat-to-skill is now real:
  1. user says “teach yourself how to …”
  2. Buddy drafts a reusable skill package in workspace state
  3. user reviews, refines, validates, and approves it
  4. the skill installs and becomes runnable from Skills
- Skill runs for manifest-backed workflows now persist run logs under `skills/<id>/runs/` for visible refinement history.

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
- `.bemore/state/buddy-runtime-events.json`
- `.bemore/buddy.md`
- `.bemore/buddies.md`

The active runtime identity is **BeMore workspace** under `.bemore`. Legacy `.bemore` paths may still be migrated for continuity, but they are not the active platform model.

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
cd apps/bemore-ios-native
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
- Buddy actions regenerate the readable `.bemore/buddy.md` and `.bemore/buddies.md` continuity
  files alongside the machine-readable JSON state.

## Known limits

- The local runtime path is still a stub unless the runtime package is added and configured.
- Provider testing depends on real upstream credentials and network reachability.
- Simulator builds can be blocked by host-side Xcode/CoreSimulator state even when the project files are valid.
- Live marketplace selling, billing, moderation, and networked trading are not part of this shell
  wedge yet; the current phone-first implementation ships real local trade package export/import and
  a standalone Buddy loop first.
