# Buddy Action Loop v1

Buddy is not a model picker and not a normal chatbot. Buddy is an agent living in a safe product environment: browser, memory, drafts, approvals, receipts, and model/tool routing.

This document defines the first shippable vertical slice for `prismtek-apps` after the guarded Agent Browser MVP.

## Product promise

Buddy can:

1. Read a user-selected page or prompt.
2. Prepare a useful draft action.
3. Ask for review before anything external happens.
4. Save a receipt.
5. Remember the useful result for later.

The first version should prove the loop, not every possible tool.

```text
user intent
  -> BuddyAction draft
  -> risk policy
  -> review / approval card
  -> draft-only or approved execution
  -> BuddyReceipt
  -> optional BuddyMemoryWrite
```

## What ships in v1

### App surface

- Agent tab stays first-class.
- Browser remains guarded to `http`, `https`, and `about` navigation.
- Tool chips create typed `BuddyAction` drafts instead of local-only ad hoc structs.
- Approval card shows the action title, risk class, current page/input, provider/tool, and what will happen.
- Receipt timeline shows completed, cancelled, denied, or failed actions.

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
- Background autonomous operation without receipts and user-visible state.

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

### 3. Wire browser tool chips

Each chip should create a `BuddyAction`:

- Summarize Page -> `browser.summarize`
- Save to Memory -> `memory.remember`
- Calendar Draft -> `calendar.draft`
- Message Draft -> `message.draft`
- Email Draft -> `email.draft`

### 4. Add receipts timeline

Add a simple timeline to Agent tab or Artifacts:

- action title
- status
- risk
- tool/provider
- timestamp
- redaction notes

Receipts should never store raw secrets, tokens, cookies, private keys, OAuth materials, or full private prompts.

### 5. Bridge to Buddy-Agent later

Once app-local loop is stable, bridge actions to `buddy-agent`:

```text
POST /buddy/actions
GET /buddy/actions/:id
GET /buddy/receipts
```

The runtime should accept only typed actions and should return sanitized receipts.

## Done definition

Buddy Action Loop v1 is done when a tester can:

1. Open the Agent tab.
2. Load a page or search.
3. Tap Summarize Page.
4. See a typed approval/result card.
5. Save the result to memory.
6. See a receipt in the timeline.
7. Recall the saved item later.

No action should send, post, create calendar events, mutate repos, or touch money without explicit review and a receipt.
