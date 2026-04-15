# Organization

## Naming layers

Use these names deliberately instead of flattening everything into one label.

### Repo / implementation layer
- **Prismtek Apps**
- GitHub repo: `prismtek-apps`
- Purpose: canonical product monorepo

### Product / flagship layer
- **BeMore**
- Purpose: flagship personal agent app

### Transitional app-display layer
- **BeMore iOS**
- Purpose: practical current display name when the plain BeMore app name is unavailable

### Internal technical identifiers
- **BeMoreAgent**
- Purpose: bundle id lineage, technical identifiers, and other internal references that do not need user-facing renaming yet

## Ownership split

### `prismtek-apps`
Owns:
- product implementation
- app surfaces
- shared product packages
- product APIs
- app build and release logic over time

### `BeMore-stack`
Owns:
- Buddy and council policy
- agent operating rules
- identity and memory philosophy
- cross-repo automation
- operator workflows and runbooks

### Legacy runtime substrate
Owns:
- runtime engine
- tools, sessions, nodes, channels
- deep execution substrate

### `prismtek-site`
Owns:
- public web presence
- prismtek.dev
- site-backed public surfaces

## Migration posture

Do not move everything at once.

### Keep where it is for now if it is:
- active and working
- owned by policy/brain/operator concerns
- risky to migrate immediately

### Move into `prismtek-apps` when it is:
- app implementation
- build or release automation for BeMore
- product-owned APIs or packages
- Buddy Workshop or workspace product code

## Current cleanup priorities

1. Keep repo naming and docs aligned
2. Remove stale scaffold leftovers
3. Clarify package responsibilities
4. Gradually move product-owned automation into `prismtek-apps`
5. Avoid duplicating the same source of truth across repos

## Canonical repo map

Use `docs/REPO_OWNERSHIP_MAP.md` as the ecosystem-level ownership map when deciding whether work belongs in the runtime substrate, `BeMore-stack`, `prismtek-site`, or `prismtek-apps`.
