# Runtime Pairing Contract

This document defines the runtime state that the BeMore product may consume.

## Goal

Show honest pairing and reachability in the app without importing the full operator surface.

## Product-safe fields

The app may read and render these fields:

- `pairing_state` — `unpaired | pairing | paired | degraded | limited`
- `selected_transport_mode` — `online | mesh | reticulum_fallback | auto`
- `last_transport_reason` — short human-readable explanation
- `runtime_reachable` — whether the paired runtime answered recently
- `remote_session_available` — whether a richer paired session path is available
- `last_heartbeat_at` — ISO-8601 timestamp of the last successful heartbeat

## Product rules

1. The app must not claim local execution when the capability is relayed.
2. The app may present `paired`, `degraded`, or `limited` states, but should avoid operator-only language.
3. If only a compact fallback path is available, the UI should say so clearly.
4. The app must not surface raw bridge configuration details.

## Good placements

- Buddy status card
- Settings pairing screen
- model / runtime truth copy
- lightweight capability status rows

## Not for the product shell

- transport override commands
- field hotkeys
- shell diagnostics
- bridge configuration details

## Source of truth

- executable runtime behavior lives in `omni-bmo`
- canonical operator contract lives in `bmo-stack`
- this document defines the filtered subset the Buddy product may consume
