# Pixel Fruit Arena Device Gap Report

Generated from code inspection on 2026-06-12. This report verifies implementation, not README claims.

## Windows

* status: Works as browser/static HTML prototype; no native `.exe` package.
* blockers: Browser launch only; no desktop installer; controller behavior depends on browser Gamepad API support.
* fixes: Keep browser build as primary Windows target. Add optional Electron/Tauri only when desktop distribution is required.

## macOS

* status: Works as browser/static HTML prototype; no native `.app` package.
* blockers: Browser launch only; no signed/notarized desktop package.
* fixes: Keep browser build as primary macOS target. Add optional desktop packaging later if needed.

## Web

* status: Playable static HTML5 Canvas prototype after opening or serving `index.html`.
* blockers: PWA/offline/install support was missing before this patch; browser runtime still needs manual QA.
* fixes: Added web app manifest, service worker registration, install prompt support, fullscreen control, and build inclusion.

## Steam Deck

* status: Requires changes / partially supported through browser mode.
* blockers: No native Steam package; controller support uses browser Gamepad API and needs hardware QA; menu navigation is still pointer/keyboard first.
* fixes: Added fullscreen button, gamepad status display, responsive scaling, and handheld documentation. Future work should add complete controller-first menu focus navigation.

## RGDS Android

* status: Requires changes / browser-PWA target only.
* blockers: No APK; no touch controls; Android browser Gamepad API support varies; hardware QA not performed.
* fixes: Added installable PWA/offline support and square/720p responsive scaling. Touch controls remain future work.

## RGDS Linux

* status: Requires changes / unverified.
* blockers: No native Linux/AppImage build; no verified Chromium/Firefox/Gamepad stack on device; no PortMaster package.
* fixes: Static web build is the safest starting point. Future work should add a Linux launcher package or PortMaster-compatible wrapper after device testing.
