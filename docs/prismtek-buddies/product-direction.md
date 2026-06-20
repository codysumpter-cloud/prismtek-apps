# Prismtek Buddies Product Direction

Prismtek Buddies Desktop is a cozy productivity room built around BUAP/Codex pets.

## Current prototype

The prototype should support:

- loading Codex pet packages
- animating Bitbud-style pet atlases
- a cozy room scene
- a to-do list
- a memo pad
- a focus timer
- focus XP and level stubs
- ambience controls
- compact Mini Mode
- state mapping between productivity events and pet animations

## State mapping

| Product event | Pet state |
| --- | --- |
| Default presence | `idle` |
| Waiting on user | `waiting` |
| Focus running | `review` or `running` |
| Work review | `review` |
| Error/failure | `failed` |
| Session complete | `jumping` |
| Greeting/music action | `waving` |

## Differentiator

The Prismtek version should be local-first and BUAP-aware. The pet is not just decoration: it should eventually react to tasks, notes, GitHub checks, PR state, Obsidian context, and Buddy/Lil Buddy work phases.

## Safety

Use original Prismtek UI and assets. Do not copy third-party art, audio, UI, branding, or text.
