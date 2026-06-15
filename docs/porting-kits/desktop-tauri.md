# Desktop porting kit: Windows, macOS, Linux, and Steam Deck

Use this kit after a game has a clean browser build and a self-contained ZIP.

The preferred Prismtek desktop path is a small Tauri wrapper around the static web build. Tauri gives us Windows, macOS, and Linux packaging without turning the game code into a separate engine fork.

## Required local tools

Tauri requires system dependencies, Rust, and Node.js. Tauri's official prerequisites currently call out:

- Linux packages such as WebKitGTK and build tools
- Xcode or Xcode Command Line Tools on macOS
- Microsoft C++ Build Tools and WebView2 on Windows
- Rust through `rustup`
- Node.js LTS for JavaScript frontends

## Windows setup checklist

1. Install Node.js LTS.
2. Install Rust with the MSVC toolchain.
3. Install Microsoft C++ Build Tools with **Desktop development with C++**.
4. Confirm WebView2 Runtime exists. Windows 10 1803+ usually already has it; install the Evergreen Bootstrapper if missing.
5. Verify:

```powershell
node -v
npm -v
rustc -V
cargo -V
```

## macOS setup checklist

1. Install Node.js LTS.
2. Install Xcode or Xcode Command Line Tools:

```bash
xcode-select --install
```

3. Install Rust:

```bash
curl --proto '=https' --tlsv1.2 https://sh.rustup.rs -sSf | sh
```

4. Verify:

```bash
node -v
npm -v
rustc -V
cargo -V
xcode-select -p
```

## Linux / Steam Deck setup checklist

For Debian/Ubuntu-style hosts:

```bash
sudo apt update
sudo apt install -y \
  libwebkit2gtk-4.1-dev \
  build-essential \
  curl \
  wget \
  file \
  libxdo-dev \
  libssl-dev \
  libayatana-appindicator3-dev \
  librsvg2-dev
```

Then install Rust and Node.js LTS.

Steam Deck verification should use the Linux artifact or browser ZIP first. Do not mark Steam Deck verified until it is tested on SteamOS or an actual Steam Deck-like runtime.

## Wrapper structure target

Create wrappers only after the game folder can produce `dist/` or a self-contained ZIP:

```text
games/<game-slug>/
├── package.json
├── src/
├── dist/
└── src-tauri/
    ├── Cargo.toml
    ├── tauri.conf.json
    └── src/main.rs
```

## Build pattern

```bash
cd games/<game-slug>
npm install
npm run build
npm run tauri build
```

Expected outputs vary by host:

- Windows: `.msi` / `.exe` bundle
- macOS: `.app` / `.dmg`
- Linux: AppImage / deb / rpm depending on config

## Verification checklist

A desktop target is **Verified** only after:

- wrapper builds on the target OS or a valid target runner
- installed/launched artifact opens the game
- keyboard/controller mapping works
- fullscreen/window scaling is readable
- save data path is documented
- release artifact is uploaded or attached
- README/platform matrix has exact receipt notes

## Keep it boring

Start with the browser build in a window. Add native menus, file associations, auto-updaters, or OS integrations later. First win: reliable downloadable game.
