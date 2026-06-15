#!/usr/bin/env node
import assert from "node:assert/strict";
import { existsSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "../..");
const toolsRoot = path.join(root, ".prismtek-tools");
const manifestPath = path.join(root, "tools/bootstrap/toolchains.manifest.json");
const manifest = JSON.parse(readFileSync(manifestPath, "utf8"));
const command = process.argv[2] || "help";
const target = process.argv[3] || "all";

const toolchains = new Map(manifest.toolchains.map((toolchain) => [toolchain.id, toolchain]));

function rel(...parts) {
  return path.join(root, ...parts);
}

function ensureDir(dir) {
  mkdirSync(dir, { recursive: true });
}

function writeIfMissing(file, content) {
  if (!existsSync(file)) writeFileSync(file, content);
}

function selectedTargets() {
  if (target === "all") return [...toolchains.keys()];
  if (!toolchains.has(target)) throw new Error(`Unknown toolchain: ${target}`);
  return [target];
}

function prepare(toolchain) {
  const cachePath = rel(toolchain.cachePath);
  ensureDir(cachePath);

  if (toolchain.id === "npm-cache") {
    ensureDir(cachePath);
    return;
  }

  if (toolchain.id === "nds-devkitpro") {
    writeIfMissing(path.join(cachePath, "env.sh"), `#!/usr/bin/env bash\nexport DEVKITPRO=\"${cachePath}\"\nexport DEVKITARM=\"${cachePath}/devkitARM\"\nexport PATH=\"$DEVKITARM/bin:$DEVKITPRO/tools/bin:$PATH\"\n`);
    writeIfMissing(path.join(cachePath, "env.ps1"), `$env:DEVKITPRO = '${cachePath}'\n$env:DEVKITARM = '${cachePath}/devkitARM'\n$env:PATH = \"$env:DEVKITARM/bin;$env:DEVKITPRO/tools/bin;$env:PATH\"\n`);
    writeIfMissing(path.join(cachePath, "README.md"), "# devkitPro cache\n\nPlace official devkitPro/devkitARM/libnds tooling here through the bootstrap flow. Do not store Nintendo SDKs, BIOS files, commercial ROMs, or generated game outputs here.\n");
    return;
  }

  if (toolchain.id === "itch-butler") {
    writeIfMissing(path.join(cachePath, "README.md"), "# Butler cache\n\nThis directory is reserved for the itch.io Butler publishing tool. Download only official Butler builds and keep them out of git.\n");
    return;
  }

  if (toolchain.id === "android-rgds") {
    writeIfMissing(path.join(cachePath, "README.md"), "# Android and RGDS Android cache\n\nThis directory is reserved for Android command-line tools, platform-tools, adb, and APK wrapper build assets. Android SDK license acceptance must stay explicit.\n");
    return;
  }

  if (toolchain.id === "jdk") {
    writeIfMissing(path.join(cachePath, "README.md"), "# JDK cache\n\nThis directory is reserved for a repo-local Java/JDK runtime used by Android packaging. Use official Temurin/OpenJDK sources.\n");
    return;
  }

  if (toolchain.id === "rust-tauri") {
    writeIfMissing(path.join(cachePath, "env.sh"), `#!/usr/bin/env bash\nexport RUSTUP_HOME=\"${path.join(cachePath, "rustup")}\"\nexport CARGO_HOME=\"${path.join(cachePath, "cargo")}\"\nexport PATH=\"$CARGO_HOME/bin:$PATH\"\n`);
    writeIfMissing(path.join(cachePath, "env.ps1"), `$env:RUSTUP_HOME = '${path.join(cachePath, "rustup")}'\n$env:CARGO_HOME = '${path.join(cachePath, "cargo")}'\n$env:PATH = \"$env:CARGO_HOME/bin;$env:PATH\"\n`);
    return;
  }

  if (toolchain.id === "media-tools") {
    writeIfMissing(path.join(cachePath, "README.md"), "# Media tools cache\n\nThis directory is reserved for local media conversion tools such as ffmpeg, ImageMagick, Tiled helpers, and sprite export wrappers.\n");
  }
}

function verify(toolchain) {
  for (const item of toolchain.verify || []) {
    const expanded = item.replace("${nodeVersion}", readFileSync(rel("tools/bootstrap/node-version.txt"), "utf8").trim());
    assert.ok(existsSync(rel(expanded)), `${toolchain.id}: missing ${expanded}`);
  }
}

function list() {
  for (const toolchain of manifest.toolchains) {
    console.log(`${toolchain.id.padEnd(18)} ${toolchain.status.padEnd(12)} ${toolchain.purpose}`);
  }
}

function help() {
  console.log(`Usage:\n  node tools/bootstrap/toolchain.mjs list\n  node tools/bootstrap/toolchain.mjs prepare [all|toolchain-id]\n  node tools/bootstrap/toolchain.mjs verify [all|toolchain-id]\n`);
  list();
}

if (command === "help") {
  help();
} else if (command === "list") {
  list();
} else if (command === "prepare") {
  ensureDir(toolsRoot);
  for (const id of selectedTargets()) {
    const toolchain = toolchains.get(id);
    prepare(toolchain);
    console.log(`prepared: ${id}`);
  }
} else if (command === "verify") {
  for (const id of selectedTargets()) {
    const toolchain = toolchains.get(id);
    verify(toolchain);
    console.log(`verified: ${id}`);
  }
} else {
  throw new Error(`Unknown command: ${command}`);
}
