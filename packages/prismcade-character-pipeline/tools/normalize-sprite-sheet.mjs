#!/usr/bin/env node
import { existsSync, writeFileSync } from "node:fs";
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

const { positional, options } = parseArgs(process.argv.slice(2));
const sheet = positional[0] || options.get("sheet");
if (!sheet || !existsSync(sheet)) {
  console.error("Usage: node tools/normalize-sprite-sheet.mjs <sheet.png> --frame-width 64 --frame-height 64 [--out normalized.manifest.json]");
  process.exit(1);
}

const frameWidth = Number(options.get("frame-width") || 64);
const frameHeight = Number(options.get("frame-height") || 64);
const out = String(options.get("out") || `${sheet}.normalized.json`);
const info = readPngInfo(sheet);

if (info.width % frameWidth !== 0 || info.height % frameHeight !== 0) {
  console.error(`${sheet} is not aligned to ${frameWidth}x${frameHeight} frames. Current size: ${info.width}x${info.height}`);
  process.exit(1);
}

const columns = info.width / frameWidth;
const rows = info.height / frameHeight;
const manifest = {
  source: path.normalize(sheet).split(path.sep).join("/"),
  frameWidth,
  frameHeight,
  width: info.width,
  height: info.height,
  columns,
  rows,
  frameCount: columns * rows,
  hasAlpha: info.hasAlpha,
  notes: "This tool validates a pre-normalized sheet and writes metadata. Pixel resampling/canvas edits should happen in Pixelorama or another image editor before import."
};

writeFileSync(out, `${JSON.stringify(manifest, null, 2)}\n`, "utf8");
console.log(`Wrote ${out}`);
