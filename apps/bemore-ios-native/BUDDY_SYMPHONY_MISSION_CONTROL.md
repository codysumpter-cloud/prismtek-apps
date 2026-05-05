# Buddy Symphony Mission Control

## Purpose

This app slice surfaces Buddy Symphony as a read-only Mission Control panel inside `MissionControlView`.

The iPhone app should help the user understand Buddy work state, proof requirements, and relay posture without becoming the execution runtime.

## Current behavior

- Shows a Buddy Symphony card on Buddy Home.
- Uses the active Buddy when available.
- Shows relay-required posture when execution is not connected.
- Lists proof requirements before Buddy growth can be applied.
- Routes to existing Results and Mac Runtime checks.
- Does not start, stop, approve, or mutate Symphony runs.

## Boundary

`prismtek-apps` owns:

- read-only Buddy-facing mission status
- proof and handoff summaries
- UX copy explaining receipts and relay posture

`bmo-stack` owns:

- Buddy Symphony contract
- workflow generation
- runtime receipts
- policy and approval rules
- Buddy state-machine effects

Symphony owns:

- scheduling work
- isolated workspaces
- agent execution attempts
- retry/reconciliation loop

## Future relay data

Replace the current preview model with relay-backed data once `bmo-stack` emits accepted Buddy Symphony summaries.

Suggested payload shape:

```json
{
  "run_id": "uuid",
  "work_item_id": "string",
  "buddy_id": "string",
  "title": "string",
  "summary": "string",
  "state": "queued | claimed | preparing | running | waiting_review | accepted | rejected | failed | canceled",
  "workspace_summary": "string",
  "policy_summary": "string",
  "proofs": [
    {
      "kind": "diff | pr | ci_status | artifact | receipt | review_feedback",
      "title": "string",
      "summary": "string",
      "is_satisfied": true
    }
  ]
}
```

## Safety rule

The app may show growth recommendations, but BMO must apply all Buddy XP, bond, memory, unlock, and evolution effects after receipt validation.
