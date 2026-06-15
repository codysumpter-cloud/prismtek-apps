# Web and itch.io porting kit

Use this path first for every Prismtek game. Web ZIPs are the simplest release artifact and the best base for desktop, Android, RGDS Android, and RGDS Linux wrappers.

## Required local tools

- Node.js LTS
- npm matching the repo package manager
- zip tooling:
  - Windows: PowerShell `Compress-Archive`
  - macOS/Linux: `zip`
- optional: itch.io Butler CLI for uploads

## Game build pattern

Each active browser game should support this shape:

```bash
cd games/<game-slug>
npm install
npm test
npm run build
npm run package:zip
```

The output should be a self-contained static ZIP that can be extracted and opened without pulling files from elsewhere in the monorepo.

## itch.io artifact expectations

A game is ready for itch upload only when the ZIP contains:

- `index.html`
- bundled JS/CSS/assets
- no broken relative paths outside the ZIP
- no reference/test assets
- no secrets or `.env` files
- playable offline or with clearly documented browser requirements
- a version or commit receipt

## Butler upload pattern

After installing Butler and authenticating locally:

```bash
butler login
butler push path/to/game.zip prismtek/<itch-project>:web
```

Use separate channels for platform-specific bundles when they exist:

```bash
butler push path/to/windows.zip prismtek/<itch-project>:windows
butler push path/to/macos.zip prismtek/<itch-project>:macos
butler push path/to/linux.zip prismtek/<itch-project>:linux
butler push path/to/android.apk prismtek/<itch-project>:android
```

Do not add these channel links to the root README until the artifacts exist on itch.io.

## Validation checklist

Before a web/itch target is marked **Verified**:

- build command succeeds
- package command succeeds
- generated ZIP extracts cleanly
- `index.html` launches locally
- controls work with keyboard and, where expected, controller/touch
- asset loading works from the extracted ZIP
- release/readme docs point to a real artifact

## Browser-first platform rule

If the web ZIP is not clean, do not wrap it yet. Desktop/mobile wrappers hide broken packaging bugs instead of fixing them.
