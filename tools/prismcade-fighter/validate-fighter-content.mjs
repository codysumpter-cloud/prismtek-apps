#!/usr/bin/env node
import { existsSync, readdirSync, readFileSync, statSync } from "node:fs";
import path from "node:path";

const root = process.cwd();
const fighterRoot = path.join(root, "games/prismcade-fighter");
const charactersRoot = path.join(fighterRoot, "content/characters");
const stagesRoot = path.join(fighterRoot, "content/stages");
const requiredCharacterFiles = ["manifest.json", "moves.json", "animations.json", "hitboxes.json", "palettes.json"];
let failures = 0;

function fail(message) {
  failures += 1;
  console.error(message);
}

function readJson(file) {
  return JSON.parse(readFileSync(file, "utf8"));
}

function dirs(parent) {
  if (!existsSync(parent)) return [];
  return readdirSync(parent)
    .map((entry) => path.join(parent, entry))
    .filter((entry) => statSync(entry).isDirectory());
}

if (!existsSync(fighterRoot)) fail("Missing games/prismcade-fighter");
if (!existsSync(charactersRoot)) fail("Missing fighter characters folder");

for (const characterDir of dirs(charactersRoot)) {
  const rel = path.relative(root, characterDir).split(path.sep).join("/");
  for (const file of requiredCharacterFiles) {
    const full = path.join(characterDir, file);
    if (!existsSync(full)) fail(`${rel} missing ${file}`);
    else {
      try { readJson(full); } catch (error) { fail(`${rel}/${file} is invalid JSON: ${error.message}`); }
    }
  }

  const manifestPath = path.join(characterDir, "manifest.json");
  if (existsSync(manifestPath)) {
    const manifest = readJson(manifestPath);
    if (!manifest.id) fail(`${rel}/manifest.json missing id`);
    if (!manifest.displayName) fail(`${rel}/manifest.json missing displayName`);
    if (!Array.isArray(manifest.spriteSize) || manifest.spriteSize.length !== 2) fail(`${rel}/manifest.json missing spriteSize`);
    if (!manifest.avatarSupport) fail(`${rel}/manifest.json missing avatarSupport`);
  }
}

if (existsSync(stagesRoot)) {
  for (const stageDir of dirs(stagesRoot)) {
    const stagePath = path.join(stageDir, "stage.json");
    const rel = path.relative(root, stageDir).split(path.sep).join("/");
    if (!existsSync(stagePath)) fail(`${rel} missing stage.json`);
    else {
      try { readJson(stagePath); } catch (error) { fail(`${rel}/stage.json is invalid JSON: ${error.message}`); }
    }
  }
}

if (failures > 0) {
  process.exitCode = 1;
} else {
  console.log("Prismcade Fighter content is valid.");
}
