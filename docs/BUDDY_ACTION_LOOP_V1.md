# Buddy Action Loop v1

Buddy is not a model picker and not a normal chatbot. Buddy is an agent operating environment: browser, memory, drafts, approvals, receipts, model/tool routing, and a minimum two-agent execution loop.

This document defines the first shippable vertical slice for `prismtek-apps` after the guarded Agent Browser MVP.

## Product promise

Buddy can:

1. Receive a human request through the Orchestrator agent.
2. Break the request into safe worker steps.
3. Delegate work to a Worker agent.
4. Let the Worker continue across steps without interrupting the human for safe actions.
5. Stop and ask the human only when a dangerous, external, destructive, credential, identity, money, location, or repo-mutation action is requested.
6. Save receipts for each completed, cancelled, denied, or failed action.
7. Remember useful results for later.

The first version should prove the loop, not every possible tool.

```text
human intent
  -> Orchestrator receives request
  -> Orchestrator creates BuddyAgentSession
  -> Orchestrator delegates next step to Worker
  -> Worker performs safe BuddyAction(s)
  -> Worker reports step result to Orchestrator
  -> Orchestrator reprompts Worker with the next step
  -> repeat until done, blocked, failed, or human approval is required
  -> BuddyReceipt(s)
  -> optional BuddyMemoryWrite
```

## Minimum complete architecture

Buddy is considered minimally complete only when it supports at least two agents:

| Agent | Role | Human contact | Tool execution | Required behavior |
| --- | --- | --- | --- | --- |
| Orchestrator | Talks to the human, owns the original request, decomposes work, approves next worker instruction | Yes | Limited / policy-driven | Must receive worker reports, decide next step, and request human approval when risk policy requires it. |
| Worker | Performs delegated steps, uses tools, reports progress | No direct human contact by default | Yes, within policy | Must report after each completed step and must stop when a dangerous action requires approval. |

The Worker should not keep asking the human for direction. It should report to the Orchestrator, and the Orchestrator should continue the process from the human's original request unless approval is required.

## Autonomy boundary

The default run mode is `supervised-autonomy`:

- Safe `read-only` and `draft-only` actions can continue without human interruption.
- The Worker must report each completed step to the Orchestrator.
- The Orchestrator may reprompt the Worker with the next instruction.
- The Orchestrator is the only default human-facing agent.
- Unknown or missing risk classification stops the loop.
- Dangerous requests pause the worker and create an approval request.

Human approval is required for:

| Risk class | Default |
| --- | --- |
| `write` | confirm |
| `external-action` | confirm |
| `destructive` | deny-by-default |
| `money` | deny-by-default |
| `identity` | deny-by-default |
| `location` | confirm |
| `credential` | deny |
| `repo-mutation` | confirm |

## What ships in v1

### App surface

- Agent tab stays first-class.
- Browser remains guarded to `http`, `https`, and `about` navigation.
- Tool chips create typed `BuddyAction` drafts instead of local-only ad hoc structs.
- Approval card shows the action title, risk class, current page/input, provider/tool, and what will happen.
- Receipt timeline shows completed, cancelled, denied, or failed actions.
- Contracts support `BuddyAgentSession`, `BuddyAgentRuntimeProfile`, `BuddyDelegation`, and `BuddyWorkerReport`.

### Safe v1 actions

| Action | Type | Risk | Default | Notes |
| --- | --- | --- | --- | --- |
| Open page/search | `browser.open` | `read-only` | allow | Current guarded WKWebView path. |
| Summarize page | `browser.summarize` | `read-only` | allow | Draft summary until extraction/model bridge is wired. |
| Save memory | `memory.remember` | `draft-only` | allow | Save page URL + user-reviewed summary. |
| Draft note | `note.draft` | `draft-only` | allow | No external write in v1 unless adapter is enabled. |
| Draft calendar event | `calendar.draft` | `draft-only` | allow | EventKit create remains follow-up approval. |
| Draft message/email | `message.draft` / `email.draft` | `draft-only` | allow | No silent sending. |

### Explicitly not v1

- Silent message sending.
- Hidden browser automation or signed-in browser session automation.
- Credential inventory.
- Trading, gambling, wallet, deposit, withdrawal, or other money-action execution.
- Destructive repo/file mutations.
- Background autonomous operation without receipts, worker reports, risk policy, and user-visible state.
- Worker-to-human direct contact by default.

## Contract source

The current app consumes the vendor snapshot at:

```text
vendor/buddy-core-contracts/src/actions/BuddyActionLoop.ts
```

This should later move to the canonical `codysumpter-cloud/prismtek-buddy-core` package once package auth/release plumbing is clean.

## Implementation steps

### 1. Replace ad hoc browser structs

Replace local `BuddyAgentToolDraft`, `BuddyAgentReceipt`, and `BuddyAgentRisk` usage in `BuddyAgentBrowserView.swift` with Swift equivalents generated from or manually mirrored against `BuddyAction`, `BuddyReceipt`, and `BuddyRiskClass`.

The Swift mirror should use the same names where practical:

```swift
struct BuddyAction: Identifiable, Codable, Equatable
struct BuddyReceipt: Identifiable, Codable, Equatable
enum BuddyRiskClass: String, Codable, CaseIterable
```

### 2. Add local action store

Create a small app-local store first:

```text
BuddyActionStore
- actions: [BuddyAction]
- receipts: [BuddyReceipt]
- createDraft(...)
- approve(actionId)
- cancel(actionId)
- complete(actionId, result)
```

Persist to app storage using JSON first. Do not block v1 on cloud sync.

### 3. Add local agent session store

Create the minimum two-agent state model:

```text
BuddyAgentSessionStore
- sessions: [BuddyAgentSession]
- delegations: [BuddyDelegation]
- workerReports: [BuddyWorkerReport]
- startSession(originalHumanRequest)
- delegateNextStep(sessionId, instruction)
- receiveWorkerReport(report)
- requestHumanApproval(report)
- resumeAfterApproval(sessionId)
```

The app can start with a local mock Worker, but the contract must already preserve the real Orchestrator/Worker boundary.

### 4. Wire browser tool chips

Each chip should create a `BuddyAction` assigned to either Orchestrator or Worker:

- Summarize Page -> `browser.summarize`
- Save to Memory -> `memory.remember`
- Calendar Draft -> `calendar.draft`
- Message Draft -> `message.draft`
- Email Draft -> `email.draft`

Safe actions may be delegated to Worker. Approval-required actions must pause and route to Orchestrator.

### 5. Add receipts and worker reports timeline

Add a simple timeline to Agent tab or Artifacts:

- session ID
- action title
- assigned agent role
- status
- risk
- tool/provider
- timestamp
- redaction notes
- worker report summary

Receipts should never store raw secrets, tokens, cookies, private keys, OAuth materials, or full private prompts.

### 6. Bridge to Buddy-Agent later

Once app-local loop is stable, bridge sessions/actions to `buddy-agent`:

```text
POST /buddy/sessions
POST /buddy/sessions/:id/delegations
POST /buddy/actions
POST /buddy/worker-reports
GET /buddy/actions/:id
GET /buddy/receipts
```

The runtime should accept only typed sessions/actions/reports and should return sanitized receipts.

## Done definition

Buddy Action Loop v1 is done when a tester can:

1. Open the Agent tab.
2. Enter a request for Buddy.
3. See an Orchestrator session start.
4. See the Orchestrator delegate a safe step to a Worker.
5. See the Worker complete a step and report back.
6. See the Orchestrator continue with the next step without asking the human again.
7. See the loop pause when an approval-required action is requested.
8. Approve or deny through the Orchestrator-facing approval card.
9. See a receipt in the timeline.
10. Save or recall the useful result later.

No action should send, post, create calendar events, mutate repos, execute dangerous commands, or touch money without explicit review and a receipt.
