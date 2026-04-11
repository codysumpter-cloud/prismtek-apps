# 0001 - Prismtek Apps is the product monorepo

## Status
Accepted

## Decision

`prismtek-apps` is the canonical product monorepo for **BeMore** and future **Prismtek** apps.

## Why

The previous repo posture was too ambiguous. It mixed platform language, app-factory language, and product implementation in a way that made ownership unclear.

The product ecosystem needs a single implementation home for:
- BeMore app surfaces
- shared product packages
- product-facing APIs
- future product-family app code when it shares real infrastructure

## Does not change

This decision does **not** move ownership of:
- legacy runtime substrate ownership
- council and Buddy policy in `bmo-stack`
- public website ownership in `prismtek-site`

## Consequences

- product implementation should converge here over time
- overlapping app repos should eventually be folded in, renamed, or archived
- product-owned automation should migrate here when safe
- working systems should not be broken just to force immediate purity
