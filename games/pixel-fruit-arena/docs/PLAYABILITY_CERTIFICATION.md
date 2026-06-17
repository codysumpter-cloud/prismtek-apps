# Pixel Fruit Arena Playability Certification

Generated from source inspection on 2026-06-12. This is conservative: docs are not counted unless supported by implementation.

## Current Completion Estimate

Playable portability alpha: 62%.

The game has a functional local browser prototype with real movement, combat, fruits, stocks, ring-outs, respawn, character profile persistence, and 2-4 player match setup. It is not production ready and is not yet verified on physical handheld hardware.

## Runtime Format

* Runtime: static HTML5 Canvas app with JavaScript modules.
* Engine: custom canvas and DOM code. No Phaser, Pixi, Godot, Electron, or Tauri dependency found.
* Launch: open or serve `games/pixel-fruit-arena/index.html`.
* Build: `npm run build` copies static files into `games/pixel-fruit-arena/dist` and removes development reference assets.
* Distribution today: static web folder or generated `dist` folder.

## Verified Working Features

### Character System

* Character creation exists through `createCharacter`.
* Customization exists for name and preset color fields.
* Persistence exists through `localStorage` key `prismtek.pixelFruitArena.profile`.
* Missing: multiple saved profiles, avatar/body-part editor, import/export, per-player persistent profiles.

### Fruit System

Verified fruits: Flame, Frost, Volt, Shadow, Rubber, Gravity.

Each fruit has three abilities and an awakening label. Shared combat applies ability cooldowns, damage, knockback, awakening charge, and mastery gain on hit.

Limitations: fruit effects mostly share common combat logic; switching is menu/profile based; mastery persists only for the stored profile.

### Combat

Verified: movement, jump, double jump, attacks, dodge, hit stun, damage-scaled knockback, ring-outs, respawn invulnerability, stocks, and match completion.

Limitations: no training mode, no audio, no detailed results screen.

### Stage

Verified: Sky Ruins Arena, four spawn points, platforms, and ring-out bounds/zones.

### Multiplayer

Verified: 2P, 3P, and 4P match setup. Keyboard supports P1/P2. Browser Gamepad API maps connected controllers by index up to slot 3. Slots above player 2 use simple CPU behavior if not actively controlled.

Limitations: 3P/4P keyboard-only controls are not implemented; controller rebinding is missing; controller-first menu navigation is incomplete; physical multi-controller QA is unverified.

## Platform Verdicts

| Platform | Verdict | Reason |
| --- | --- | --- |
| Windows PC | Works as browser build | Static HTML/JS app; no native package. |
| macOS | Works as browser build | Static HTML/JS app; no native package. |
| Web Browser | Works as intended target | Browser is the native runtime. PWA/offline files added. |
| Steam Deck | Requires hardware QA | Browser/gamepad path exists; no Steam package; menus need controller polish. |
| RGDS Android Mode | Requires hardware QA | PWA/browser path exists; no APK; touch controls missing. |
| RGDS Linux Mode | Unsupported as native target | No native Linux package, launcher, AppImage, or PortMaster wrapper. Browser path may work but is unverified. |

## Deployment Support

| Capability | Status |
| --- | --- |
| Browser hosting | PASS |
| PWA manifest | PASS |
| Service worker/offline cache | PASS |
| Install prompt hook | PASS where browser exposes `beforeinstallprompt` |
| Desktop packaging | MISSING |
| Offline play | PASS after first served load in a service-worker-capable browser |
| Save data persistence | PASS through localStorage |
| Touch controls | MISSING |
| Screen mode control | PARTIAL through shell button and browser APIs |
| Resolution scaling | PASS baseline responsive/square-screen CSS |
| Gamepad detection | PASS basic status display |
| Controller rebinding | MISSING |

## Known Limitations

* Physical testing was not performed on target devices from this environment.
* Service workers require the game to be served from a browser-compatible origin; direct `file://` launch may not enable PWA/offline behavior.
* Native app packaging is not present for Windows, macOS, Android, Steam, or Linux.
* Touch controls remain missing, so RGDS Android without a working controller/browser Gamepad API is not playable.
* 3P/4P is best with gamepads; keyboard maps only P1/P2.

## Recommended Next Sprint

1. Real-device QA on Windows, macOS, Steam Deck, RGDS Android, and RGDS Linux.
2. Controller-first menu navigation and visible button prompts.
3. Touch controls for Android fallback.
4. Download/install buttons on the Prismtek site.
5. Optional desktop shell after browser/PWA target is stable.
6. PortMaster/Linux wrapper after RGDS Linux constraints are known.

## Final Verdict

Playable Alpha for browser-first platforms.

Not beta. Not production ready. Not fully verified across all target devices yet.
