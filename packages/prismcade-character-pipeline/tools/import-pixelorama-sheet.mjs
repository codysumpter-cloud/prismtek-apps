#!/usr/bin/env node
import { copyFileSync, existsSync, mkdirSync, writeFileSync } from "node:fs";
import path from "node:path";
import { readPngInfo } from "./lib/png-info.mjs";

function parseArgs(argv) {
  const options = new Map();
  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    if (!arg.startsWith("--")) continue;
    const key = arg.slice(2);
    const next = argv[index + 1];
    if (!next || next.startsWith("--")) options.set(key, true);
    else {
      options.set(key, next);
      index += 1;
    }
  }
  return options;
}

function requireOption(options, key) {
  const value = options.get(key);
  if (!value) {
    console.error(`Missing --${key}`);
    process.exit(1);
  }
  return String(value);
}

function ensureDir(dir) {
  mkdirSync(dir, { recursive: true });
}

function writeJson(file, value) {
  ensureDir(path.dirname(file));
  writeFileSync(file, `${JSON.stringify(value, null, 2)}\n`, "utf8");
}

const options = parseArgs(process.argv.slice(2));
const sheet = requireOption(options, "sheet");
const outputDir = requireOption(options, "output");
const animationId = String(options.get("animation") || "idle");
const characterId = String(options.get("character-id") || path.basename(outputDir));
const displayName = String(options.get("display-name") || characterId);
const frameWidth = Number(options.get("frame-width") || 64);
const frameHeight = Number(options.get("frame-height") || 64);
const fps = Number(options.get("fps") || 8);

if (!existsSync(sheet)) {
  console.error(`Missing sheet: ${sheet}`);
  process.exit(1);
}

ensureDir(path.join(outputDir, "spritesheets"));
const target = path.join(outputDir, "spritesheets", `${animationId}.png`);
copyFileSync(sheet, target);

const info = readPngInfo(target);
const columns = Math.max(1, Math.floor(info.width / frameWidth));
const rows = Math.max(1, Math.floor(info.height / frameHeight));
const frameCount = columns * rows;
const anchor = { x: Math.floor(frameWidth / 2), y: Math.floor(frameHeight * 0.875) };
const baselineY = Math.floor(frameHeight * 0.875);

writeJson(path.join(outputDir, "metadata.json"), {
  schemaVersion: "prismcade-character-pack-v0",
  characterId,
  displayName,
  sourceTool: "pixelorama",
  assetMode: "assets-required",
  targetFrame: { width: frameWidth, height: frameHeight },
  transparentBackground: true,
  pipeline: {
    sourceGeneration: "Pixelorama-edited sprite sheet",
    cleanup: "Pixelorama frame cleanup",
    normalization: "Prismcade sheet import"
  },
  provenance: [{ type: "source-import", note: `Imported Pixelorama sheet ${sheet}` }]
});

writeJson(path.join(outputDir, "manifest.json"), {
  schemaVersion: "prismcade-animation-manifest-v0",
  characterId,
  frameWidth,
  frameHeight,
  anchor,
  baselineY,
  requiredAnimations: [animationId],
  animations: [
    {
      id: animationId,
      source: `spritesheets/${animationId}.png`,
      frameWidth,
      frameHeight,
      frameCount,
      columns,
      rows,
      fps,
      loop: true,
      anchor,
      baselineY,
      hitbox: { x: 20, y: 16, width: 24, height: 42 },
      hurtbox: { x: 16, y: 10, width: 32, height: 48 },
      tags: ["pixelorama-import", animationId]
    }
  ]
});

console.log(`Imported ${animationId} (${frameCount} frames) into ${outputDir}`);
