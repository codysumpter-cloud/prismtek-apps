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

## Pixel Fruit Arena prototype

The iOS app now includes **Pixel Fruit Arena**, an original pixel-art platform fighting MVP inspired by arena fighters. It uses original “Mystic Fruit” power names and placeholder rectangle sprites only; no One Piece names, assets, logos, locations, characters, or copyrighted terms are used.

### Run the prototype

```bash
cd apps/bemore-ios-native
xcodegen generate
xcodebuild -project BeMoreAgent.xcodeproj -scheme BeMoreAgent -sdk iphonesimulator build
```

Then open the app and choose the **Arena** tab. Existing users who customized visible tabs may need to enable the Arena tab from Settings.

### MVP flow

1. Open **Arena**.
2. Use **Character Creator** to edit fighter name, body palette, hair palette, and outfit color.
3. Use **Fruit Select** to unlock/equip one Mystic Fruit.
4. Use **Local Match Setup** to choose 1–4 local slots. Empty local slots become CPU placeholders.
5. Start a match on **Prism Pier**, the original placeholder arena stage.

### Controls

Current MVP controls are on-screen buttons:

- Move left / stop / move right
- Jump
- Basic attack
- Special 1
- Special 2
- Special 3
- Dodge

The code keeps input calls separate on `PixelFruitArenaStore` (`move`, `jump`, `basicAttack`, `special`, `dodge`) so keyboard/controller adapters can be added without rewriting combat or fruit data.

### Playable fruits

Fruits are defined in `PixelFruitLibrary` and represented independently from the player profile:

- **Flame Fruit** — fire projectile, flame dash, burn hit
- **Frost Fruit** — ice spike, freeze zone, slippery dash
- **Volt Fruit** — lightning bolt, blink dash, chain shock
- **Shadow Fruit** — pull field, dark burst, short-range null effect
- **Rubber Fruit** — stretch punch, bounce jump, giant fist
- **Gravity Fruit** — pull, slam, floating heavy attack

Each fruit also has stubbed mastery data (`FruitMastery`) with level and XP fields so real progression can be wired later.

### How fruits are defined

The prototype separates data and behavior:

- `PixelFighterProfile` — name and cosmetic palettes
- `PixelFruitKind`, `PixelFruitDefinition`, `FruitAbilityDefinition`, `FruitMastery` — fruit data and progression metadata
- `PixelFruitArenaStore` — match state, combat, cooldowns, CPU placeholders, and input actions
- `PixelArenaStage` and `ArenaPlatform` — stage dimensions, platforms, spawns, hazards
- SwiftUI views — menu, creator, fruit select, setup, match HUD, arena rendering, controls

### Add a new fruit

1. Add a case to `PixelFruitKind`.
2. Add a `PixelFruitDefinition` entry to `PixelFruitLibrary.all` with three `FruitAbilityDefinition` values.
3. Add the three special behaviors to `PixelFruitArenaStore.performSpecial(_:for:)`.
4. Tune damage, knockback, duration, cooldowns, and status effects.
5. Add mastery migration if the fruit should unlock after progression instead of at start.

### Current limitations

- Placeholder pixel rectangles are used instead of final sprite sheets.
- Local multiplayer uses shared on-screen MVP controls for player 1; other occupied local slots can exist, and unfilled slots are CPU placeholders.
- Keyboard/controller adapters are not fully mapped yet.
- Combat is intentionally simple: percentage damage, knockback scaling, hit stun, stocks, ring-out, respawn, and one hazard.
- Persistence is stubbed in memory for the prototype; permanent character/fruit save data should be added before shipping.

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
- **Local sparring** — Buddy battles with loadout strategy
- **Pixel Fruit Arena** — original pixel-art platform fighter MVP with Mystic Fruit powers
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
- **Pixel Fruit Arena prototype** — original arena fighter with character creator, 6 fruits, one stage, stocks, ring-out, respawn, HUD, and CPU placeholders
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
