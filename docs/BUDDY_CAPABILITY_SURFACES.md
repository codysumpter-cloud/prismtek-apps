# Buddy Capability Surfaces

## Purpose

This document defines how Buddy-created and Buddy-operated skills/apps appear inside `prismtek-apps` without duplicating the runtime substrate.

## Core rule

- skills and apps define capability
- Buddy Runtime provides intelligence
- `prismtek-apps` owns product surfaces, install flows, config forms, and app-visible rendering
- `prismtek-apps` does not own planner, routing, memory, or policy per app

## Product-side objects

### Skill Package

A product-visible bounded capability that can be launched from a surface such as:

- Buddy Workshop
- app detail views
- quick actions
- repo/workspace context tools

A skill package may contribute:

- launcher placements
- inspector panels
- settings forms
- artifact renderers

A skill package may not introduce:

- a mini runtime
- hidden background services
- separate memory ownership
- separate routing ownership
- separate policy ownership

### App Package

A product-facing workflow surface that bundles one or more skills into a user-facing concept.

An app package may contribute:

- app cards
- installed app surfaces
- context panels
- dashboards
- settings/config views
- launch surfaces inside iBeMore

An app package still runs through the shared Buddy Runtime.

### Buddy Binding

A product-visible relation that says which Buddy is operating a skill/app.

A Buddy Binding controls:

- display label
- icon
- visibility in app library and Buddy dock
- default config
- extra restrictions beyond the package permission envelope

## iBeMore surfacing model

### Buddy Workshop

Used to:

- create a new skill package draft
- create a new app package draft
- adopt an existing package
- review permissions and repo landing targets
- preview generated changes before repo submission

### Installed Skills

Show:

- package name
- bound Buddy
- permissions
- install scope
- latest receipts
- configure/open/uninstall actions

### Installed Apps

Show:

- app card
- bound Buddy
- linked skills
- launch surface
- latest receipts and activity
- settings and configuration

### Capability Inspector

Show:

- manifest summary
- tools requested
- event types
- artifact types
- source repo ownership
- binding details

## Product repo ownership

`prismtek-apps` owns:

- Buddy Workshop UI
- skill/app install UI
- config forms
- app cards and dashboards
- product routing to installed apps/skills
- receipt and artifact rendering
- product adapters that call the shared Buddy Runtime
- shared TS manifest types used by product code

`prismtek-apps` does not own:

- canonical runtime contract authority
- package execution rules
- package permission evaluation
- global Buddy routing
- global Buddy memory or policy

## Initial implementation direction

- keep canonical schemas in `bmo-stack`
- keep product-facing TS types in `packages/core`
- later move Buddy-specific product models into `packages/buddy-core`
- later move runtime bridge clients into `packages/runtime-adapter`
- keep generated app/skill surfaces landing in real product paths under `prismtek-apps`

## MVP product surface

The smallest useful MVP inside iBeMore is:

1. Buddy Workshop package drafts
2. Installed Skills list
3. Installed Apps list
4. Capability Inspector
5. explicit install/config screens

No package gets its own hidden daemon or mini brain.
