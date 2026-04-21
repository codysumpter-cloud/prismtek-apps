# Buddy Creator Redesign Brief

This brief exists to keep the Buddy creation overhaul focused on player experience instead of preserving the current wedge UX.

## Problem statement

The current Buddy creation and Appearance Studio flow is too unintuitive for a front-door iPhone product surface.

Observed issues:
- Pixel Studio feels weak and constrained
- the color system feels far too limited
- the creation flow feels editor-like instead of game-like
- appearance/profile concepts are exposed too early
- the user has to think too much before they get a Buddy that feels good

The iPhone product surface is supposed to lead with the Buddy loop. That means Buddy creation should feel fast, clear, playful, and rewarding.

## Product goal

Make Buddy creation feel like a simplified video-game character creator.

That means:
- the user gets a good-looking Buddy quickly
- the flow is visually guided
- live preview is always present
- advanced editing exists but is secondary
- defaults are strong enough that even a lazy path produces a good result

## Design principle

**Front door = make a Buddy. Advanced door = edit a Buddy.**

Do not lead with the advanced/studio/editor mental model.

## Recommended information architecture

### Primary path: Create Buddy

This should be the main flow shown to first-time and casual users.

Suggested steps:
1. Choose a starter template or archetype
2. Choose a palette/theme
3. Pick a few obvious features
4. Preview live
5. Name the Buddy
6. Save and enter the Buddy loop

### Secondary path: Customize More

This is where the current Appearance Studio ideas should move.

Suggested use:
- detailed palette tweaks
- accessory/feature adjustments
- saved appearance profiles
- profile export/import or advanced appearance manipulation

The current Studio should become an optional deeper layer, not the front door.

## UX targets

### 1. Template-first creation

Start with visually strong Buddy templates.

Each template should already feel "good enough" before any edits.

Examples of player-facing starter choices:
- Cozy
- Brave
- Mystic
- Gremlin
- Arcade
- Nature
- Shadow
- Spark

The names can change, but they should feel playful and immediately understandable.

### 2. Real palette system

The current color system needs a major upgrade.

At minimum, support:
- body/base color
- accent color
- eye color
- accessory/effect color

Better version:
- curated palette families with multiple swatches per family
- themed sets such as Warm, Cool, Forest, Arcade, Cosmic, Pastel, Shadow, Neon
- optional randomize button

Do not force a tiny fixed palette if the Buddy is meant to feel expressive.

### 3. Live preview always visible

The preview should be visible throughout creation.

Rules:
- every change updates immediately
- preview is central, not hidden
- the user should not need to navigate away to see the result

### 4. Fewer hard decisions up front

Do not ask the user to manage too many appearance concepts in one step.

Better pattern:
- one simple decision per screen or section
- visible defaults already selected
- quick path to continue without overthinking

### 5. Randomize and remix

The creator should support:
- Random Buddy
- Random palette
- Remix current Buddy
- Reset to template

This makes the system feel playful and reduces creative paralysis.

### 6. Better copy

Avoid low-level/internal wording in the creation path.

Prefer:
- Look
- Colors
- Style
- Features
- Vibe
- Save Buddy

Avoid leading with words like:
- profile
- manifest
- state
- continuity
- bundle

Those may still exist underneath, but should not dominate the player-facing flow.

## App factory integration angle

The iPhone creator should probably borrow the best part of app-factory thinking: let the system assemble a rich result from a few easy inputs.

That means the user should be able to choose a small number of player-facing traits while the app derives:
- a coherent starter appearance
- a compatible palette set
- a starter expression/vibe
- a usable saved appearance profile

In other words:
- **simple inputs for the player**
- **richer composition under the hood**

This is the right place to use composition/generation logic instead of exposing raw editing burden.

## Suggested shipping order

### Phase 1 — quick win
- expand palette options significantly
- add randomize/remix
- rename current front-door labels to feel more like a creator
- ensure live preview is more obvious

### Phase 2 — flow restructure
- add a simplified Create Buddy flow
- move current Studio behavior behind Customize More / Advanced
- make starter templates the default entry point

### Phase 3 — smarter composition
- add app-factory-style generation of starter looks from a few user choices
- auto-generate stronger defaults
- preserve advanced saved profiles behind the scenes

## Validation questions

A redesign is only good if these answers improve:

1. Can a first-time user make a Buddy without explanation?
2. Can the user get a good-looking Buddy in under a minute?
3. Does the creator feel playful instead of technical?
4. Is the color system expressive enough that users do not immediately feel constrained?
5. Does the advanced Studio remain available without burdening the front door?

## Success criteria

This redesign is successful when:
- creating a Buddy feels closer to a game character creator than a low-level editor
- the color system is visibly richer
- users can get a satisfying Buddy quickly
- advanced appearance control still exists, but no longer dominates the first-run flow
- the Buddy creator becomes one of the strongest parts of the iPhone app
