# Repo Positioning

## Purpose

`prismtek-apps` is the canonical product monorepo for **BeMore** and future **Prismtek** apps.

It exists to hold product-facing implementation in one place so app surfaces, shared packages, and product APIs stop drifting across multiple repos.

## Owns

- BeMore app implementation
- shared product packages
- product-facing APIs
- Buddy and Buddy Workshop product surfaces
- shared auth, account, and profile systems
- shared design-system and app-shell patterns

## Does not own

- deep runtime substrate, tool runtime, sessions, nodes, channels, or execution primitives outside the BeMore product adapter
- `BeMore-stack` council policy, Buddy identity rules, agent operating behavior, or cross-repo governance
- `prismtek-site` public website ownership, site-backed marketing surfaces, or site-specific APIs

## Repo map

- BeMore runtime substrate = execution engine and inherited runtime primitives
- `BeMore-stack` = brain / policy / council / identity
- `prismtek-site` = public web world
- `prismtek-apps` = shipped app family

## Current posture

This repo is being promoted from an ambiguously positioned platform monorepo into the canonical Prismtek product repo.

That means:
- product language should replace generic platform language
- stale identity leftovers should be removed over time
- overlapping app repos should either fold into this repo or be clearly demoted

## Cleanup guidance

Low-risk cleanup can proceed immediately:
- rename mismatched repo/package metadata
- rewrite README and app metadata
- align manifest and page titles
- document ownership boundaries

Higher-risk cleanup should be done deliberately:
- deleting stale root-level scaffold files
- moving packages between repos
- folding in overlapping app repos
- changing live deployment ownership
