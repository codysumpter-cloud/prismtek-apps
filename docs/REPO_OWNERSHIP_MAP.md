# Repo Ownership Map

## Purpose

This document defines the canonical repo roles across the Prismtek, BeMore, and OpenClaw ecosystem.

The goal is to reduce the number of repos acting like they might be the source of truth for the same thing.

## Canonical repos

These are the repos that should remain first-class in the mental model.

### `openclaw`
Role:
- runtime engine
- execution substrate
- tools, sessions, nodes, channels
- gateway and native platform plumbing

Owns:
- runtime delivery and execution primitives
- local and remote assistant control-plane capabilities
- OpenClaw setup, config patterns, and skills ecosystem

Does not own:
- BeMore product implementation
- Buddy/council policy and identity rules
- public Prismtek website ownership

### `bmo-stack`
Role:
- brain / policy / council / identity layer
- operator and orchestration repo for BMO behavior

Owns:
- Buddy and council behavior rules
- identity and memory philosophy
- cross-repo orchestration
- operator workflows, runbooks, and policy-facing automation

Does not own:
- deep runtime substrate
- the canonical BeMore product app surfaces
- the public Prismtek website

### `prismtek-site`
Role:
- public web world
- public Prismtek site and site-backed experiences

Owns:
- `prismtek.dev`
- public marketing and navigation surfaces
- site-backed APIs and public web experiences
- web-only public experiments that truly belong to the site

Does not own:
- assistant runtime substrate
- the full BeMore product app family
- Buddy/council policy source of truth

### `prismtek-apps`
Role:
- canonical product monorepo
- shipped app family for BeMore and future Prismtek apps

Owns:
- BeMore product implementation
- app surfaces and product-facing APIs
- shared product packages
- Buddy Workshop and workspace product surfaces
- app-owned build and release automation over time

Does not own:
- OpenClaw runtime substrate
- BMO identity/council policy layer
- public website ownership

## Repo classification model

Use these statuses consistently.

### Canonical
Actively owned source-of-truth repos.

### Satellite
Useful supporting repos that should not define the architecture.
They should either point to a canonical repo, get folded in, or be clearly labeled transitional.

### Experiment
Interesting prototypes or incubators.
They may influence the future, but they are not the source of truth.

### Archive
Historical repos kept for reference only.
They should not be treated as active ownership centers.

## Recommended treatment for known repo families

### `omni-bmo`
Recommendation:
- treat as **satellite** or **archive candidate** unless it still owns a distinct technical layer

Likely destination:
- behavior/orchestration concepts → `bmo-stack`
- product-facing features → `prismtek-apps`

### `PrismBot` and PrismBot variants
Recommendation:
- treat as **historical reference + migration input**, not as parallel product homes

Likely destination:
- useful agent behavior, orchestration, and logic → `bmo-stack`
- useful user-facing product patterns → `prismtek-apps`
- duplicate public-facing or half-canonical variants → archive with clear banners

### `automindlab-stack`
Recommendation:
- treat as **migration input**, probably not a long-term first-class repo

Likely destination:
- orchestration/operator patterns → `bmo-stack`
- product implementation worth keeping → `prismtek-apps`
- runtime/tooling assumptions → `openclaw`

### old BeMore/BMO app repos
Recommendation:
- do not let these remain shadow canonical homes
- either fold them into `prismtek-apps` or clearly demote/archive them

## Where things should live

### OpenClaw setup, skills, and runtime config
Store in:
- `openclaw`
- OpenClaw workspace/config/docs
- skill repos or skill directories

Examples:
- gateway configuration
- node setup
- local machine integration
- skill definitions and tool integrations
- runtime capability docs

### Buddy, council, memory philosophy, and agent operating behavior
Store in:
- `bmo-stack`

Examples:
- behavior rules
- council structure
- agent contracts
- memory/identity policy
- orchestration and runbooks

### BeMore app features and product surfaces
Store in:
- `prismtek-apps`

Examples:
- BeMore web and iOS product surfaces
- product-facing API routes
- workspace and Buddy Workshop UI
- app-owned release automation
- shared product packages

### Public Prismtek web experiences
Store in:
- `prismtek-site`

Examples:
- marketing pages
- public navigation
- site-backed web features
- public arcade/world surfaces if they are site-owned

## Migration rules

1. Do not keep multiple repos as equal product sources of truth.
2. Mine older repos for value, then fold or archive them.
3. Move product implementation toward `prismtek-apps`.
4. Keep runtime/platform concerns in `openclaw`.
5. Keep policy/behavior/orchestration in `bmo-stack`.
6. Keep public-site ownership in `prismtek-site`.
7. Rename only when the ownership model is already clear.

## Immediate next moves

1. classify each non-canonical repo as satellite, experiment, or archive
2. add README banners to superseded repos
3. create a migration inventory for Omni-BMO, PrismBot, and Automindlab-derived features
4. decide which BeMore app repos should fold into `prismtek-apps` first
5. keep one implementation roadmap in `prismtek-apps` and one policy/vision roadmap in `bmo-stack`

## Rule of thumb

If the question is “where does this ship to users?”, the answer is usually `prismtek-apps`.

If the question is “how should the assistant behave?”, the answer is usually `bmo-stack`.

If the question is “how does the runtime actually execute?”, the answer is usually `openclaw`.

If the question is “is this the public web presence?”, the answer is usually `prismtek-site`.
