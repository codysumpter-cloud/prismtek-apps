#!/usr/bin/env node
import { copyFileSync, existsSync, mkdirSync, readdirSync, writeFileSync } from "node:fs";
import path from "node:path";
import { readPngInfo } from "./lib/png-info.mjs";

function parseArgs(argv) {
  const positional = [];
  const options = new Map();
  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    if (arg.startsWith("--")) {
      const key = arg.slice(2);
      const next = argv[index + 1];
      if (!next || next.startsWith("--")) options.set(key, true);
      else {
        options.set(key, next);
        index += 1;
      }
    } else positional.push(arg);
  }
  return { positional, options };
}

function fail(message) {
  console.error(message);
  process.exit(1);
}

function ensureDir(dir) {
  mkdirSync(dir, { recursive: true });
}

function writeJson(file, value) {
  ensureDir(path.dirname(file));
  writeFileSync(file, `${JSON.stringify(value, null, 2)}\n`, "utf8");
}

function normalizeAnimationId(fileName) {
  return path.basename(fileName, path.extname(fileName))
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "_")
    .replace(/^_+|_+$/g, "") || "animation";
}

function listPngs(dir) {
  const results = [];
  for (const entry of readdirSync(dir, { withFileTypes: true })) {
    const fullPath = path.join(dir, entry.name);
    if (entry.isDirectory()) results.push(...listPngs(fullPath));
    if (entry.isFile() && entry.name.toLowerCase().endsWith(".png")) results.push(fullPath);
  }
  return results.sort();
}

const { positional, options } = parseArgs(process.argv.slice(2));
const inputDir = positional[0];
const outputDir = positional[1];
if (!inputDir || !outputDir) {
  fail("Usage: node tools/import-pixellab-states.mjs <input-dir> <output-pack-dir> --character-id buddy --display-name Buddy --frame-width 64 --frame-height 64");
}
if (!existsSync(inputDir)) fail(`Missing input dir: ${inputDir}`);

const characterId = String(options.get("character-id") || path.basename(outputDir));
const displayName = String(options.get("display-name") || characterId);
const frameWidth = Number(options.get("frame-width") || 64);
const frameHeight = Number(options.get("frame-height") || 64);
const sourceTool = String(options.get("source-tool") || "pixellab");

ensureDir(outputDir);
ensureDir(path.join(outputDir, "spritesheets"));
ensureDir(path.join(outputDir, "source"));
ensureDir(path.join(outputDir, "animations"));

const pngs = listPngs(inputDir);
if (pngs.length === 0) fail(`No PNG files found in ${inputDir}`);

const usedIds = new Map();
const animations = [];
for (const png of pngs) {
  const baseId = normalizeAnimationId(path.basename(png));
  const count = usedIds.get(baseId) || 0;
  usedIds.set(baseId, count + 1);
  const id = count === 0 ? baseId : `${baseId}_${count + 1}`;
  const target = path.join(outputDir, "spritesheets", `${id}.png`);
  copyFileSync(png, target);

  const info = readPngInfo(target);
  const columns = Math.max(1, Math.floor(info.width / frameWidth));
  const rows = Math.max(1, Math.floor(info.height / frameHeight));
  const frameCount = columns * rows;
  animations.push({
    id,
    source: `spritesheets/${id}.png`,
    frameWidth,
    frameHeight,
    frameCount,
    columns,
    rows,
    fps: id.includes("idle") ? 6 : 10,
    loop: !["hurt", "ko", "defeat"].includes(id),
    anchor: { x: Math.floor(frameWidth / 2), y: Math.floor(frameHeight * 0.875) },
    baselineY: Math.floor(frameHeight * 0.875),
    hitbox: { x: 20, y: 16, width: 24, height: 42 },
    hurtbox: { x: 16, y: 10, width: 32, height: 48 },
    tags: ["pixellab-import", id]
  });
}

const requiredAnimations = ["idle", "walk", "hurt"].filter((id) => animations.some((animation) => animation.id === id));
while (requiredAnimations.length < 3 && animations[requiredAnimations.length]) requiredAnimations.push(animations[requiredAnimations.length].id);

writeJson(path.join(outputDir, "metadata.json"), {
  schemaVersion: "prismcade-character-pack-v0",
  characterId,
  displayName,
  sourceTool,
  assetMode: "assets-required",
  targetFrame: { width: frameWidth, height: frameHeight },
  transparentBackground: true,
  pipeline: {
    sourceGeneration: "PixelLab character states or animation export",
    cleanup: "Pixelorama/manual cleanup before shipping",
    normalization: "Prismcade character pipeline import"
  },
  provenance: [{ type: "source-import", note: `Imported ${pngs.length} PNG state files from ${inputDir}` }]
});

writeJson(path.join(outputDir, "manifest.json"), {
  schemaVersion: "prismcade-animation-manifest-v0",
  characterId,
  frameWidth,
  frameHeight,
  anchor: { x: Math.floor(frameWidth / 2), y: Math.floor(frameHeight * 0.875) },
  baselineY: Math.floor(frameHeight * 0.875),
  requiredAnimations,
  animations
});

writeFileSync(path.join(outputDir, "PROVENANCE.md"), `# ${displayName} provenance\n\nImported from PixelLab-style state PNGs. Review and update this file before shipping.\n`, "utf8");
console.log(`Imported ${animations.length} PixelLab state sheet(s) into ${outputDir}`);
