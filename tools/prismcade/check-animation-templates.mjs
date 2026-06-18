#!/usr/bin/env node
import { existsSync, readdirSync, readFileSync, statSync } from "node:fs";
import path from "node:path";

const root = process.cwd();
const templatesDir = path.join(root, "data/prismcade/animation-templates");
const sizeTiersPath = path.join(root, "data/prismcade/animation-size-tiers.json");
const requiredFields = ["schemaVersion", "templateId", "viewFamily", "frameSize", "origin", "anchors", "layers", "slots", "compatibilityLevels"];
let failures = 0;
let maxFrameSize = [256, 256];

function walk(dir) {
  const files = [];
  for (const entry of readdirSync(dir)) {
    const full = path.join(dir, entry);
    if (statSync(full).isDirectory()) files.push(...walk(full));
    else if (entry.endsWith(".json")) files.push(full);
  }
  return files;
}

function report(message) {
  failures += 1;
  console.error(message);
}

function validSize(value) {
  return Array.isArray(value) && value.length === 2 && value.every((n) => Number.isInteger(n) && n > 0);
}

if (existsSync(sizeTiersPath)) {
  try {
    const sizeTiers = JSON.parse(readFileSync(sizeTiersPath, "utf8"));
    if (validSize(sizeTiers.maxFrameSize)) maxFrameSize = sizeTiers.maxFrameSize;
  } catch (error) {
    report(`Invalid animation size tiers JSON: ${error.message}`);
  }
}

if (!existsSync(templatesDir)) {
  report("Missing data/prismcade/animation-templates");
} else {
  const files = walk(templatesDir);
  if (files.length === 0) report("No animation template JSON files found");

  for (const file of files) {
    const rel = path.relative(root, file).split(path.sep).join("/");
    let data;
    try {
      data = JSON.parse(readFileSync(file, "utf8"));
    } catch (error) {
      report(`${rel} is not valid JSON: ${error.message}`);
      continue;
    }

    for (const field of requiredFields) {
      if (!(field in data)) report(`${rel} missing ${field}`);
    }

    if (!validSize(data.frameSize)) {
      report(`${rel} frameSize must be [width, height]`);
    } else if (data.frameSize[0] > maxFrameSize[0] || data.frameSize[1] > maxFrameSize[1]) {
      report(`${rel} frameSize exceeds max ${maxFrameSize[0]}x${maxFrameSize[1]}`);
    }

    if (!Array.isArray(data.origin) || data.origin.length !== 2) report(`${rel} origin must be [x, y]`);
    if (!Array.isArray(data.layers) || data.layers.length === 0) report(`${rel} layers must be a non-empty array`);
    if (!Array.isArray(data.slots) || data.slots.length === 0) report(`${rel} slots must be a non-empty array`);
  }
}

if (failures > 0) {
  process.exitCode = 1;
} else {
  console.log(`Prismcade animation templates are valid up to ${maxFrameSize[0]}x${maxFrameSize[1]}.`);
}
