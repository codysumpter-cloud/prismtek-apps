# Automation Migration

## Purpose

This document tracks how product-owned automation should gradually move into `prismtek-apps` without breaking currently working systems.

## Principle

Do not move automation just to make the architecture look clean.

Move it when:
- the automation is clearly product-owned
- there is a safe replacement path
- the new home can actually run and maintain it

## Keep in `BeMore-stack` for now when it is about

- council routing
- Buddy or memory operating rules
- operator workflows
- cross-repo orchestration
- runbooks and policy enforcement
- recovery or continuity automation

## Move to `prismtek-apps` over time when it is about

- BeMore app builds
- product release automation
- app-specific code generation
- product-owned test and packaging flows
- Buddy Workshop implementation automation
- BeMore-specific migrations or fixture generation

## Transitional rule

If a working automation path currently lives in `BeMore-stack` but clearly serves the BeMore product, treat it as transitional:

1. document current ownership
2. recreate it in `prismtek-apps`
3. verify the new path works
4. demote or remove the old path only after the new one is proven

## Immediate candidate

### BeMore iOS build and release automation

Current posture:
- may still live in `BeMore-stack`
- should eventually live in `prismtek-apps`

Migration goal:
- app build and release ownership should sit with the product repo
- `BeMore-stack` can keep higher-level orchestration only if needed

## Recommended next step

Create a small inventory of current product-owned automations and mark each one:
- keep in `BeMore-stack`
- move to `prismtek-apps`
- split between both
