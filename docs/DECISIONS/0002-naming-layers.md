# 0002 - Naming layers for repo, product, and app identifiers

## Status
Accepted

## Decision

Use different names for different layers instead of forcing one label everywhere.

## Naming layers

- **Prismtek Apps** = repo / monorepo identity
- **BeMore** = flagship product identity
- **BeMore iOS** = practical current display name where the plain BeMore app name is unavailable
- **BeMoreAgent** = internal technical identifiers and bundle-id lineage that do not need immediate renaming

## Why

Trying to force one name to cover repo identity, product identity, store/display naming, and technical identifiers creates confusion.

Layered naming is cleaner and more durable.

## Consequences

- repo docs should use `Prismtek Apps`
- product-facing UI should prefer `BeMore`
- app-store or target naming may temporarily use `BeMore iOS`
- internal identifiers can keep `BeMoreAgent` until there is a good reason to migrate them
