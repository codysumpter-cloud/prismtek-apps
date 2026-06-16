# Game engine adapter contracts

Game engine adapters let Prismtek evaluate engines and frameworks without dumping third-party source into shipped game folders.

The machine-readable source of truth is [`../../data/integrations/game-engine-adapters.json`](../../data/integrations/game-engine-adapters.json).

## Contract stance

These adapters are **contracts**, not engine imports. A contract can describe how Prismtek will talk to an engine, validate generated output, and record receipts. It does not mean the repo now owns that engine, bundles that engine, or can ship upstream sample content.

The safe path is:

1. Define the adapter manifest.
2. Build a tiny plugin around that manifest.
3. Run the plugin against a local engine install or remote reference.
4. Emit receipts.
5. Promote only Prismtek-owned or explicitly reviewed outputs.

## Current adapter contracts

| Adapter | Status | Primary use | Best first game/use case | Guardrail |
| --- | --- | --- | --- | --- |
| Godot Engine Adapter | Contract-only | Broad 2D/3D experiments across web, desktop, mobile, and RGDS targets. | Creature/world prototypes, 3D arena tests, dense map experiments. | Do not vendor Godot source or exports without explicit receipts. |
| Phaser Web Adapter | Contract-only | Browser-first arcade loops and itch-style ZIP builds. | Prismtek arcade browser games and Pixel Fruit Arena web packaging. | Do not commit vendored npm caches or generated files without receipts. |
| OpenBOR Brawler Adapter | Contract-only | Original Prismtek beat-'em-up and brawler experiments. | Future original brawler/spin-off combat experiments. | Do not copy existing OpenBOR modules, sprites, or audio. |
| Castagne Fighter Adapter | Contract-only | Pixel Fruit Arena combat architecture research. | Input buffering, cancel windows, move-data modeling, directional specials. | Do not copy sample characters, stages, or unreviewed engine exports. |
| Ikemen GO Fighter Adapter | Contract-only | Traditional 2D fighter-system research. | Versus fighter experiments and roster/stage rule comparisons. | Do not copy MUGEN content packs, characters, or stages. |
| raylib Handheld Adapter | Contract-only | Lightweight native arcade and Linux handheld experiments. | RGDS Linux/native arcade spikes and low-overhead tools. | Do not commit unchecked binaries or untracked toolchain downloads. |

## Candidate expansion queue

The manifest intentionally starts with the highest-value contracts, but the integration system should be able to absorb additional engines without changing the shape of the contract.

| Candidate | Likely adapter family | Why it matters | First validation target |
| --- | --- | --- | --- |
| PixiJS | Web renderer adapter | Fast 2D rendering without adopting a full engine. | Existing canvas arcade games. |
| Three.js | Web 3D renderer adapter | Browser-first 3D scenes and effects. | Creature arena prototype. |
| Babylon.js | Web 3D engine adapter | Higher-level browser 3D and physics experiments. | Dense world/arena spike. |
| Bevy | Rust ECS adapter | Simulation, AI, creature behavior, and ECS architecture. | NPC/creature systems. |
| libGDX | Cross-platform framework adapter | Android/desktop comparison with Java/Kotlin-friendly runtime. | RGDS Android mode test. |
| LÖVE | Lua arcade adapter | Tiny arcade prototypes and rapid gameplay iteration. | Lightweight handheld-style arcade game. |
| HaxeFlixel | 2D pixel framework adapter | Pixel games across web/native targets. | Pixel platformer/fighter experiment. |
| MonoGame | XNA-style framework adapter | C# game structure and desktop/mobile lessons. | Desktop packaging research. |
| Flame | Flutter game adapter | Mobile-first minigames and BeMore-adjacent surfaces. | Companion minigame prototype. |
| GDevelop | Visual tooling adapter | Event-based game authoring and editor UX lessons. | No-code/low-code game creation research. |
| O3DE | Large 3D engine adapter | Heavy 3D and simulation research. | Research-only architecture audit. |
| Stride | C# 3D engine adapter | C# 2D/3D runtime comparison. | Desktop 3D spike. |
| OGRE | Native rendering adapter | Rendering pipeline research. | Renderer architecture notes. |
| Panda3D | Python 3D adapter | Python-friendly tooling and 3D research. | Tool prototype. |
| PlayCanvas | Web 3D adapter | Web-native 3D runtime comparison. | Browser 3D scene spike. |
| TORCS | Racing/simulation reference adapter | Vehicle dynamics and AI racing research. | Research-only simulation notes. |

## Adapter lifecycle

| Stage | Meaning | Required evidence |
| --- | --- | --- |
| `contract-only` | Manifest/docs exist, but no runtime plugin is implemented. | Manifest validates. Docs explain boundaries. |
| `prototype` | Tool can scaffold or inspect a local experiment. | Plugin command exists. Receipt emitted. No shipped outputs. |
| `verified-local` | Adapter produces repeatable local output. | Clean validation run. Repro steps. File manifest. |
| `release-candidate` | Output can be packaged for a target platform. | Platform receipt. License review. Artifact manifest. |
| `shippable` | Specific generated/promoted output is approved. | Game-local manifest, provenance, review record, release checklist. |

A game should never depend on a `contract-only` adapter at runtime.

## Required adapter receipt

Each implemented engine adapter should emit a receipt under a game-local or docs-local receipt path. Minimum fields:

```json
{
  "adapterId": "phaser-web-adapter",
  "adapterVersion": 1,
  "sourceReferenceId": "phaser",
  "sourceVersion": "exact commit/tag/version or local install version",
  "command": "node tools/integrations/phaser/export.mjs --target games/example",
  "targetPath": "games/example/",
  "targetPlatform": "web",
  "generatedPaths": [],
  "ignoredPaths": [],
  "licenseReview": "pending | reviewed | blocked",
  "artifactReview": "pending | reviewed | blocked",
  "validationResult": "passed | failed",
  "notes": "human-readable summary"
}
```

Receipts must not include secrets, private absolute paths, access tokens, raw prompts, or machine-local credentials.

## Required plugin behavior

Every implemented engine adapter should eventually expose these commands:

| Command | Behavior | Must fail when |
| --- | --- | --- |
| `intake` | Reads adapter config and prepares a quarantined local experiment workspace. | Source reference is missing, target path is unsafe, or required metadata is absent. |
| `validate` | Checks adapter manifest, expected files, output boundaries, receipts, and license-review flags. | Required fields are missing, generated files have no receipt, or forbidden files exist. |
| `export` | Generates Prismtek-owned output for a specific target. | Output would copy external engine code/assets, write outside target path, or lack receipts. |

## Game integration requirements

Before a game can use an adapter output, the game folder should include:

- a game-local manifest describing the generated/promoted files;
- a platform target list;
- a receipt path;
- a clear fallback when adapter output is missing;
- a test or validation script that fails cleanly.

For example, Pixel Fruit Arena could eventually use engine-adapter receipts to compare its current fight engine against Castagne and Phaser experiments, but the live game should keep its current runtime unless a replacement is proven better.

## Platform matrix expectations

| Platform | Minimum evidence before claiming support |
| --- | --- |
| Web browser | Local run instructions, static build, no missing assets. |
| itch.io ZIP | Zip artifact recipe, index entry, asset manifest, offline smoke test. |
| Windows | Build/package command or desktop wrapper receipt. |
| macOS | Build/package command or desktop wrapper receipt. |
| Linux / Steam Deck | Build/package command and controller/input note. |
| RGDS Android mode | Browser/APK/runtime note and screen/input assumptions. |
| RGDS Linux mode | Native/browser runtime note and performance caveats. |
| iOS | Explicit mobile wrapper/build plan; do not claim support until signed build exists. |
| Nintendo DS | Separate demake/porting-kit plan; do not claim direct engine support unless a real DS runtime exists. |

## Non-goals

These contracts do not:

- import engines;
- install engines;
- package engines;
- guarantee legal clearance;
- guarantee platform support;
- make external sample games Prismtek-owned;
- replace game-specific architecture reviews.

## Next implementation slice

The next useful PR after this one should implement one tiny adapter plugin, probably Phaser or asset intake, because those can validate the contract without pretending native/3D toolchains are already solved.

A good first plugin would:

1. Read `data/integrations/game-engine-adapters.json`.
2. Select `phaser-web-adapter`.
3. Verify required fields.
4. Generate a receipt only.
5. Refuse to write runtime files until a target game manifest exists.

That keeps the workflow honest and gives CI something useful to enforce.
