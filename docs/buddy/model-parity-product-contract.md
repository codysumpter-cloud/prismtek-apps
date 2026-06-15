# Buddy Model Parity Product Contract

Status: product/UX contract  
Created: 2026-06-15

## Purpose

Prismtek Apps owns the user-visible side of Buddy model parity. The app should label model/runtime capability clearly and avoid presenting open architecture research as a hosted frontier model.

OpenMythos and OpenFable can inform local/research model modes. Claude Fable 5 / Mythos 5 behavior should be shown as hosted-provider behavior unless a local runtime receipt proves otherwise.

## Sources

- `https://platform.claude.com/docs/en/about-claude/models/introducing-claude-fable-5-and-claude-mythos-5`
- `https://github.com/kyegomez/OpenMythos`
- `https://github.com/lovestaco/OpenFable`
- `https://github.com/anthropic-fable/claude-fable-5`

## Product requirements

| Surface | Requirement |
|---|---|
| Model picker | Distinguish hosted providers, local models, and experimental architecture backends. |
| Capability labels | Use `supported`, `partial`, `experimental`, `requires hosted provider`, or `missing`. |
| Effort controls | Provide simple labels: quick, balanced, deep. |
| Tool controls | Show when code execution, memory, tool calling, vision, or compaction is unavailable. |
| Receipts | Record model route, feature route, fallback mode, and user-visible limitation. |
| Privacy | Do not imply local/offline operation when a hosted model is used. |

## Feature parity map

| Feature | Product status rule |
|---|---|
| Large context / output | Show only for provider routes or local routes with stress-test receipts. |
| Adaptive effort | Surface as simple effort controls. |
| Memory | Show enabled only when the app has a real memory store/adapter. |
| Code execution | Show enabled only with a guarded sandbox. |
| Tools | Show enabled only when a skill/tool adapter is active. |
| Context editing | Show as missing until a context manager exists. |
| Compaction | Show as missing or partial until long-session tests pass. |
| Vision | Show enabled only for routes with real image/camera handling. |
| Provider fallback | Show degraded/fallback mode when model routing changes. |

## UX copy guardrail

Allowed: "Fable/Mythos-inspired runtime controls."

Not allowed without proof: "OpenMythos has Claude Fable 5 / Mythos 5 parity."

## Next implementation targets

1. Add a model capability card to Buddy settings.
2. Add a receipt viewer for model route, effort, tools, memory, vision, and fallback.
3. Add explicit labels for hosted/local/experimental routes.
4. Add app-side tests that prevent unsupported features from being labeled supported.
