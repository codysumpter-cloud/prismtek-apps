# Android and RGDS porting kit

This kit covers Android APK wrappers and RGDS-friendly runtime paths.

Prismtek games should reach Android/RGDS through the smallest reliable path first:

1. stable browser build
2. self-contained web ZIP/PWA
3. Android wrapper only after the web artifact is clean
4. RGDS Android test
5. RGDS Linux/browser/launcher test

## Android paths

### Option A: Capacitor wrapper

Best for web-first games that need an APK without a Rust native layer.

Required local tools:

- Node.js LTS
- Android Studio
- Android SDK
- Android SDK Platform-Tools
- Android SDK Build-Tools
- Android SDK Command-line Tools

Capacitor's current docs note that Android Studio installs the proper JDK, so a separate JDK install should not be needed for normal Capacitor setup.

Starter flow after a clean web build:

```bash
cd games/<game-slug>
npm install
npm run build
npm install @capacitor/core @capacitor/cli @capacitor/android --save-dev
npx cap init "Prismtek <Game Name>" "dev.prismtek.<game-slug>" --web-dir dist
npx cap add android
npx cap copy android
npx cap open android
```

Build the APK/AAB from Android Studio first, then script Gradle builds after the wrapper is stable.

### Option B: Tauri Android wrapper

Best if the desktop wrapper already uses Tauri and the game benefits from a shared Rust/WebView package path.

Required local tools:

- Tauri prerequisites
- Android Studio
- Android SDK Platform
- Platform-Tools
- NDK side-by-side
- SDK Build-Tools
- SDK Command-line Tools
- Rust Android targets:

```bash
rustup target add aarch64-linux-android armv7-linux-androideabi i686-linux-android x86_64-linux-android
```

## RGDS Android mode

Treat RGDS Android as a real Android device test, not a generic emulator claim.

Verification needs:

- APK installed on RGDS Android mode
- game launches offline
- screen scaling works on the device display
- physical controls or mapped controls are documented
- touch fallback works where relevant
- performance is playable for at least one full match/run

## RGDS Linux mode

Start with the browser/static path before native Linux packaging.

Candidate launch paths:

- local browser pointed at extracted game ZIP
- static local server launched from a shell script
- Tauri Linux/AppImage after desktop packaging exists
- PrismDS launcher entry once a stable artifact path is known

A minimal launcher receipt should record:

```text
Device:
Mode: RGDS Linux
Game:
Artifact:
Launch command:
Controls tested:
Scaling notes:
Result:
Date:
```

## Controller and screen rules

- Avoid tiny UI text.
- Support keyboard first, then controller mappings.
- Keep touch optional for core gameplay.
- Make pause/restart obvious.
- Prefer 16:9-safe layouts but test square-ish handheld screens separately.
- Do not mark RGDS verified from desktop Linux alone.

## Verification checklist

Android/RGDS targets are **Verified** only after:

- artifact exists: APK, extracted web ZIP, or Linux package
- artifact launches on the target mode
- controls are documented
- one full game loop completes
- performance/scaling notes are captured
- README/platform matrix links to the receipt
