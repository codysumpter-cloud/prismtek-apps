# BMO Web Stack

This document defines the Prismtek account-backed BMO web experience.

## Product intent

Users should be able to:

1. create or sign in to a Prismtek account
2. create a personal BMO companion
3. chat with that companion from the website
4. keep profile, companion state, chat history, memory, and future tool permissions scoped to the signed-in account

Hermes WebUI is the reference UX pattern. Prismtek converts the idea into a BeMore/BMO companion product instead of exposing a raw local Hermes instance.

## Ownership

- `prismtek-site` owns the public route and frontend shell.
- `prismtek-apps/apps/api` owns authenticated product APIs.
- `bmo-stack` owns deeper execution, council, policy, and agent-runtime orchestration.
- Native iOS/macOS clients consume the same account-scoped contract where possible.

## Required API contract

All write routes require authenticated account identity.

### `GET /wp-json/prismtek/v1/account/me`

Existing account session endpoint used by the site.

### `GET /wp-json/prismtek/v1/bmo/me`

Returns the signed-in user's current BMO profile and recent private messages.

Suggested response:

```json
{
  "ok": true,
  "loggedIn": true,
  "bmo": {
    "id": "bmo_123",
    "ownerId": "user_123",
    "name": "BMO",
    "style": "builder",
    "summary": "Helps plan and ship useful work.",
    "createdAt": "2026-04-29T00:00:00.000Z",
    "updatedAt": "2026-04-29T00:00:00.000Z"
  },
  "messages": []
}
```

### `POST /wp-json/prismtek/v1/bmo/create`

Creates the first BMO profile for the signed-in account.

Request:

```json
{
  "name": "BMO",
  "style": "builder"
}
```

### `POST /wp-json/prismtek/v1/bmo/message`

Appends a private user message and returns the updated conversation. The initial implementation can return a deterministic assistant response; later versions should route through `bmo-stack`.

Request:

```json
{
  "bmoId": "bmo_123",
  "message": "Help me plan today's work."
}
```

## Privacy requirements

- Do not store private BMO conversations in unauthenticated browser-only storage.
- Do not expose raw local Hermes state on the public site.
- Do not run tools until account identity, permissions, and runtime policy are explicit.
- Keep public BMO chat separate from account-owned BMO companion chat.

## Platform upgrade path

### Website

`/buddy-webui` is the canonical product route. `/hermes-webui` can redirect there for compatibility.

### iOS and macOS

Native apps should add an account-scoped BMO companion panel that can use the same profile and message contract. iOS should prefer safe companion chat and read-only state. macOS may expose operator tools after policy checks.

### Windows

The Windows app should be built as a parity desktop shell for account-scoped BMO companion use, local workspace control, receipts, schedules, and operator tools. It should not claim full parity until the permission model and tool execution sandbox are implemented.

## First implementation wedge

1. Ship the website shell and backend contract.
2. Add API routes in `apps/api` for `bmo/me`, `bmo/create`, and `bmo/message`.
3. Persist BMO profiles and messages per authenticated user.
4. Add native app consumers after the web route is stable.
5. Add Windows shell after the shared API contract is proven.
