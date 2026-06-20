# Prismtek Buddies Desktop

Cozy productivity room prototype for Bitbud and future BUAP pets.

## Current scope

- Load local pet files.
- Animate Bitbud atlas states.
- Room shell with wall, shelf, window, desk, floor, pet zone, and focus XP card.
- To-do list.
- Memo pad.
- Focus timer.
- Focus XP and gift placeholder.
- Ambience controls.
- Mini Mode.
- Productivity events mapped to pet states.

## Run locally

```bash
cd apps/prismtek-buddies-desktop
npm install
npm run dev
```

Choose the Bitbud package files from the local Bitbud pet folder.

## State mapping

| Event | Pet state |
| --- | --- |
| Default room presence | `idle` |
| Waiting on user | `waiting` |
| Active work | `running` |
| Review work | `review` |
| Failure | `failed` |
| Session complete | `jumping` |
| Greeting | `waving` |
