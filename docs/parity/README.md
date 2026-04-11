# BeMore Parity Status

This folder tracks what BeMore can safely claim against the legacy OpenClaw reference and Codex-class coding workflow expectations.

## Safe Claims After This Pass

- BeMore has a standalone product-owned CLI at `apps/bemore-cli`.
- BeMore Mac and the CLI share the same local runtime API for workspace, file, command, task, diff, artifact, receipt, Buddy, and pairing state.
- BeMore supports a stronger coding loop: open workspace, inspect tree, create tasks, delegate subtasks, preview/apply/reject structured patches, run commands, inspect output, retry failed tasks within a bounded policy, review diffs, and inspect receipts/artifacts.
- BeMore exposes a workspace-bound sandbox session with path enforcement, command blocking, timeouts, output caps, and receipt logging.

## Not Safe To Claim Yet

- Full legacy OpenClaw parity for multi-channel gateways, provider plugin ecosystem, installers, service management, and channel-specific operations.
- Full Codex-level autonomy for parallel model-backed subagents, autonomous fix planning, and VM/container-grade sandbox isolation.

## Evidence Files

- `openclaw-vs-bemore.json`
- `codex-workflow-vs-bemore.json`
