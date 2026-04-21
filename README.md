# Prismtek Apps

![CI](https://github.com/codysumpter-cloud/prismtek-apps/actions/workflows/ci.yml/badge.svg) ![CodeQL](https://github.com/codysumpter-cloud/prismtek-apps/actions/workflows/codeql.yml/badge.svg)

Canonical product monorepo for **BeMore** and future **Prismtek** apps.

This repository implements the BeMore iOS app — a companion-first product where users adopt, train, and care for AI Buddies. It does **not** own the runtime substrate, policy layer, or public website.

## What BeMore Is

A **native iPhone app** with a loop: create Buddy instances from archetypes, customize their appearance with ASCII or pixel art, train their proficiencies through daily interaction, spar locally to test growth, and export/import trade packages. OAuth linking surfaces for GitHub and ChatGPT enable runtime-powered workflows. A macOS dual-target supports operator command execution when paired.

## Quick start

```bash
npm install
npm run dev
```

For iOS development:
```bash
cd apps/bemore-ios-native
xcodegen generate
open BeMoreAgent.xcodeproj
```

## At a glance

- **Product:** BeMore — AI companion
- **Target:** iPhone iOS app (with macOS dual-target for operator commands)
- **Current version:** 0.2 (build 41 in TestFlight)
- **Architecture:** Native SwiftUI + TCA pattern + sync-over-async relay to runtime

## What this repo owns

- **BeMore iOS app** — SwiftUI-based Buddy management UI
- **Buddy lifecycle** — creation, equipment, training, care, trade
- **Appearance studio** — ASCII/PixelLab hybrid customization
- **OAuth surfaces** — GitHub, ChatGPT account linking (relay-based)
- **Tamagotchi loop** — daily check-ins, care actions, streaks
- **Local sparring** — Buddy v. Buddy battles with growth reflection
- **Trade packages** — export/import with sanitation
- **Operator command UI** — macOS only; iOS shows "use Mac relay" fallback

## What it does not own

- Execution runtime (lives in BeMore-stack)
- LLM inference (relayed)
- Public marketing site (prismtek-site)
- Council/policy (BeMore-stack)

## Product architecture

```
┌─────────────────────────────────────────┐
│           BeMore iOS App               │
│  ┌─────────┐ ┌──────────┐ ┌─────────┐  │
│  │  Buddy  │ │ Appearance│ │  OAuth  │  │
│  │  View   │ │ Studio    │ │ Links   │  │
│  └────┬────┘ └─────┬─────┘ └────┬────┘  │
│       └────────────┴────────────┘      │
│                  │                       │
│           BuddyInstanceStore            │
│                  │                       │
│         ┌──────┴─────┐                 │
│         ▼            ▼                 │
│   Tamagotchi    RelayServices         │
│   Engine        (sync-over-async)     │
└─────────────────────────────────────────┘
                    │
                    ▼
              BeMore-stack
         (execution substrate)
```

## Current features

- **Guided Buddy creation** — archetype selection, appearance mode (ASCII/Pixel), voice config
- **Daily care loop** — feed, play, train, check-in with streaks
- **Proficiency training** — 12 skill categories, incremental growth
- **Local sparring** — Buddy battles with loadout strategy
- **Trade packages** — sanitized export/import with validation
- **OAuth account linking** — GitHub (private repo access), ChatGPT (API integration)
- **Tamagotchi-like care** — energy, attention, mood, daily goals
- **Operator commands** — macOS dual-target only; security-audited shell execution

## Getting started

### Prerequisites

- Xcode 16.3+
- iOS 18.3+ target
- macOS 15.3+ (for dual-target)

### Build the app

```bash
cd apps/bemore-ios-native
xcodegen generate
xcodebuild -project BeMoreAgent.xcodeproj -scheme BeMoreAgent -sdk iphonesimulator build
```

### Useful commands

```bash
npm run lint
npm run build
npm run dev
```

## Structure

```
apps/
  bemore-ios-native/    SwiftUI app, Xcode project
  api/                  Product-facing backend
  web/                  React web surface

packages/
  agent-protocol/       Runtime communication contracts
  core/                 Shared types
  app-factory/          App scaffolding

Docs in docs/ORGANIZATION.md
```

## Runtime boundary

- **Product (this repo)** renders UI, manages Buddy state, handles OAuth flows
- **BeMore-stack** owns execution, skills, council decisions, Codex runs
- **Relay** sync-over-async bridge between them

## License

Apache-2.0. See `LICENSE`.
