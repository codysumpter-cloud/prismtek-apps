# Fork Upgrade Program

_Date: 2026-04-23_

## Purpose

Use the owned fork graph as a donor system to upgrade two real targets:

1. **Hermes on the MacBook** (`codysumpter-cloud/hermes-agent`)
2. **Buddy agents in the shipped app** (`codysumpter-cloud/prismtek-apps`)

This program is explicitly **not** a blind sync/update exercise. The goal is to mine the fork inventory for reusable capabilities, route those capabilities into the correct landing repos, and keep ownership boundaries honest.

## Confirmed repo roles

### Primary landing repos

- **`prismtek-apps`** — shipped Buddy product surface and real app landing zone
- **`bmo-stack`** — runtime/operator truth, contracts, manifests, and integration glue
- **`hermes-agent`** — MacBook Hermes runtime base

### Donor-only / reference repos

- **`BMO-app`** — donor/reference only; not the live app landing zone
- Any repo listed below as `reference-only` or `triage-needed`

## Verified architecture constraints

- `prismtek-apps` is the real Buddy app surface.
- `bmo-stack` remains the deeper operator/runtime truth behind the app when the app needs posture, contracts, skills manifests, or integration depth.
- `prismtek-apps` already reads `BMO_STACK_ROOT` in the API layer and builds a Buddy/BMO adapter snapshot from the stack repo.
- The Buddy product work already points toward native-first app surfaces, real linked accounts, stronger memory/runtime honesty, and deeper companion behavior.

## Upgrade lanes

### Lane A — Hermes Mac runtime

**Target repo:** `codysumpter-cloud/hermes-agent`

**Goal:** Upgrade the local Hermes runtime using fork donors without turning Hermes into a second app shell.

**Primary donors:**

| Donor repo | Confidence | Extract / adapt | Land in |
|---|---:|---|---|
| `agentmemory` | high | persistent memory, retrieval, MCP memory tools, Hermes plugin integration | `hermes-agent` |
| `openclaw` | high | multi-channel gateway, node/device posture, voice/canvas patterns | `hermes-agent` or `bmo-stack` |
| `learn-hermes-agent` | high | clean subsystem references for loop, tools, sessions, memory, skills, scheduler, MCP | `hermes-agent` / `bmo-stack` |
| `hermes-ecosystem` | high | ecosystem discovery and prioritization map | planning only |
| `hermes-workspace` | medium | workspace conventions / runtime posture | `hermes-agent` / `bmo-stack` |
| `hermes-control-interface` | medium | control-plane / operator affordance ideas | `bmo-stack` |
| `hermes-desktop` | medium | desktop companion patterns | `hermes-agent` / reference |
| `hermes-webui` | medium | web control surface patterns | `bmo-stack` / reference |
| `hermes-hudui` | medium | compact HUD patterns | reference |
| `hermes-lcm` | medium | lifecycle / model management ideas | `bmo-stack` |
| `hermes-paperclip-adapter` | medium | external adapter patterns | `bmo-stack` |
| `hermes-agent-orange-book` | medium | docs / operating guidance | docs only |
| `hermes-agent-self-evolution` | medium | self-improvement patterns | `hermes-agent` / reference |
| `Hermes-Wiki` | low | docs inventory | docs only |
| `awesome-hermes-agent` | low | ecosystem discovery | planning only |
| `superpowers-zh` | low | docs / references | reference |

### Lane B — Runtime truth and contracts

**Target repo:** `codysumpter-cloud/bmo-stack`

**Goal:** Keep one runtime/operator truth for posture, manifests, contracts, Codex/Council integration, and shared donor-derived capabilities consumed by the app.

**Primary donors:**

| Donor repo | Confidence | Extract / adapt | Land in |
|---|---:|---|---|
| `learn-hermes-agent` | high | subsystem patterns for session store, prompt builder, compression, scheduler, MCP | `bmo-stack` |
| `openclaw` | high | channel routing, node/device abstraction, gateway safety posture | `bmo-stack` |
| `agentmemory` | high | shared memory service posture and retrieval contracts | `bmo-stack` |
| `hermes-control-interface` | medium | operator/control-plane ideas | `bmo-stack` |
| `hermes-lcm` | medium | lifecycle coordination concepts | `bmo-stack` |
| `agentic-stack` | medium | generic agent architecture donor | `bmo-stack` |
| `gbrain` | medium | memory/brain donor candidate; verify before landing | triage |
| `claw-code` | medium | code-runtime / toolchain donor candidate; verify before landing | triage |
| `nemoclaw` | medium | OpenClaw-adjacent runtime donor candidate; verify before landing | triage |
| `openclaw` | high | authoritative source for donorized gateway/node patterns | `bmo-stack` |

### Lane C — Buddy product upgrades

**Target repo:** `codysumpter-cloud/prismtek-apps`

**Goal:** Make Buddy materially better inside the real app surface, using donor capabilities routed through the app/runtime boundary instead of reviving donor repos as product owners.

**Primary donors:**

| Donor repo | Confidence | Extract / adapt | Land in |
|---|---:|---|---|
| `agentmemory` | high | Buddy memory, recall, preferences, cross-session retrieval | `prismtek-apps` via `bmo-stack` |
| `openclaw` | high | Buddy-on-channels posture, device-node concepts, remote companion affordances | `prismtek-apps` / `bmo-stack` |
| `learn-hermes-agent` | high | session, skill, compression, scheduler, MCP patterns portable to app services | `bmo-stack` / `prismtek-apps` |
| `omni-bmo` | medium | Buddy/assistant surface donor; verify scope before landing | triage |
| `Prismbot-BMO` | medium | historical BMO surface donor; verify before landing | triage |
| `PrismBot` | low | older BMO runtime donor; verify before landing | triage |
| `BMO-app` | medium | companion UX donor only; do not treat as product owner | selective donor only |
| `prismbot.wix` | low | site/marketing donor only | reference |
| `WixPrismBot` | low | site/marketing donor only | reference |

## Full fork inventory and current disposition

### High-priority donors

- `agentmemory`
- `openclaw`
- `learn-hermes-agent`
- `hermes-ecosystem`
- `hermes-workspace`
- `hermes-control-interface`
- `hermes-desktop`
- `hermes-webui`
- `hermes-lcm`
- `agentic-stack`
- `claw-code`
- `gbrain`
- `nemoclaw`

### Buddy/BMO donors

- `omni-bmo`
- `Prismbot-BMO`
- `PrismBot`
- `BMO-app`
- `WixPrismBot`
- `prismbot.wix`

### Hermes/docs/reference donors

- `awesome-hermes-agent`
- `Hermes-Wiki`
- `hermes-agent-orange-book`
- `hermes-agent-self-evolution`
- `hermes-hudui`
- `superpowers-zh`

### Site / product / adjacent donors that require triage before use

- `prismtek-site`
- `prismtek-site-replica`
- `Prismtek.dev`
- `OmniAPI-private`
- `omni-openclaw-starter`
- `FlowMaster`
- `Edge-Gallery`
- `Wildlands-Critter-Clash`
- `prismteksmods`
- `Prismtek-s-Mod-Vault`

## Execution order

### Phase 1 — Inventory + extraction map

- [ ] Treat this document as the source-of-truth donor map.
- [ ] For each high-priority donor, record one of: `land now`, `mine later`, `reference-only`, `skip`.
- [ ] Keep feature claims tied to verified source files or READMEs.

### Phase 2 — Hermes Mac runtime upgrade

- [ ] Add a Hermes issue/backlog for fork-derived runtime work.
- [ ] Integrate `agentmemory` as the first memory donor path.
- [ ] Evaluate which `openclaw` patterns belong in Hermes directly vs in `bmo-stack`.
- [ ] Use `learn-hermes-agent` as the clean implementation reference when porting subsystems.

### Phase 3 — Shared runtime truth in `bmo-stack`

- [ ] Add a `bmo-stack` issue/backlog for donor-derived contracts and runtime glue.
- [ ] Decide which donor capabilities become manifests/contracts vs app-only UX.
- [ ] Keep `bmo-stack` as the single runtime/operator truth consumed by the app.

### Phase 4 — Buddy upgrade landing in `prismtek-apps`

- [ ] Land Buddy memory work through app-facing services fed by runtime truth.
- [ ] Land Buddy channel/device affordances only where product-fit is real.
- [ ] Keep app-native UX and Buddy-first product posture central.
- [ ] Do not migrate product ownership back into `BMO-app`.

## Immediate backlog slices

### Slice 1 — agentmemory adoption path

**Why first:** highest-confidence donor, immediately useful for both Hermes and Buddy.

**Targets:**
- `hermes-agent`: MCP/plugin memory integration
- `bmo-stack`: shared memory posture/contracts
- `prismtek-apps`: Buddy-facing recall/usefulness surfaces

### Slice 2 — gateway and device-node donor pass

**Why second:** strongest differentiator for living-assistant behavior.

**Targets:**
- `bmo-stack`: runtime boundary and gateway posture
- `prismtek-apps`: only the product-appropriate Buddy surfaces
- `hermes-agent`: only what improves the Mac runtime directly

### Slice 3 — portable subsystem pass from `learn-hermes-agent`

**Why third:** gives a clean implementation reference for subsystems without dragging upstream product sprawl into the local stack.

**Targets:**
- session store
- prompt builder
- context compression
- scheduler
- MCP integration
- skill system

## Non-goals

- Do not blindly merge every fork.
- Do not treat naming similarity as proof that a donor should land.
- Do not let `BMO-app` retake ownership of the shipped product surface.
- Do not split runtime truth across `prismtek-apps` and `bmo-stack` without an explicit reason.

## Validation

### Product-side validation

```bash
cd /Users/prismtek/code/prismtek-apps
npm install
npm run dev
```

### iOS Buddy validation

```bash
cd /Users/prismtek/code/prismtek-apps/apps/bemore-ios-native
xcodegen generate
xcodebuild build -project /Users/prismtek/code/prismtek-apps/apps/bemore-ios-native/BeMoreAgent.xcodeproj -scheme BeMoreAgent -destination 'platform=iOS Simulator,name=iPhone 17'
```

### Runtime-side validation

```bash
cd /Users/prismtek/code/bmo-stack
make doctor
make runtime-doctor
make workspace-sync
make worker-status
```

### Hermes runtime validation

```bash
cd /Users/prismtek/code/hermes-agent
hermes doctor
hermes version
hermes gateway status
```

## Decision rule

When a fork yields a useful capability, land it in the repo that actually owns that capability:

- **Hermes local runtime behavior** → `hermes-agent`
- **runtime/operator truth, contracts, manifests, integration glue** → `bmo-stack`
- **shipped Buddy UX/product behavior** → `prismtek-apps`
- **docs/reference only** → keep as donor/reference, do not promote blindly
