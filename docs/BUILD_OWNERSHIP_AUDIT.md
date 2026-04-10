# Build Ownership Audit

## Purpose

Use this document to track which build and release workflows are still owned outside `prismtek-apps` and which ones should eventually move here.

## Status key

- **current owner** = where the workflow really lives today
- **target owner** = where it should live long-term
- **status** = keep / transitional / migrate / done

## Audit table

| Workflow | Current owner | Target owner | Status | Notes |
|---|---|---|---|---|
| BeMore iOS build | `bmo-stack` or other current path | `prismtek-apps` | transitional | verify scripts, signing, archive/export steps |
| BeMore iOS release | `bmo-stack` or other current path | `prismtek-apps` | transitional | migrate only after build path is proven |
| BeMore web build | `prismtek-apps` | `prismtek-apps` | keep | current product-repo ownership is correct |
| Product API build | `prismtek-apps` | `prismtek-apps` | keep | current product-repo ownership is correct |

## How to use this

For each workflow:
1. identify the real current owner
2. decide the target owner
3. mark whether it should stay, migrate, or is already correct
4. only move it after there is a tested replacement path

## Rule

Do not move working release machinery just to satisfy architecture neatness.

Move it only when:
- ownership is clearly wrong
- the replacement path exists
- the new path has been tested
