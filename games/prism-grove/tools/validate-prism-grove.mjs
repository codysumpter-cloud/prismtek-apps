#!/usr/bin/env node
import assert from "node:assert/strict";
import { existsSync, readFileSync } from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const gameDir = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
function readJson(file) {
  return JSON.parse(readFileSync(path.join(gameDir, file), "utf8"));
}
for (const file of ["index.html", "README.md", "package.json", "data/crops.json", "data/mutations.json", "data/cosmetics.json", "data/pets.json", "data/prism-grove.manifest.json"]) {
  assert.ok(existsSync(path.join(gameDir, file)), `Prism Grove requires ${file}`);
}
const crops = readJson("data/crops.json");
const variants = readJson("data/mutations.json");
const cosmetics = readJson("data/cosmetics.json");
const pets = readJson("data/pets.json");
const manifest = readJson("data/prism-grove.manifest.json");
assert.ok(crops.length >= 8, "Prism Grove needs crop data");
assert.ok(variants.length >= 6, "Prism Grove needs crop variant data");
assert.ok(cosmetics.length >= 6, "Prism Grove needs cosmetic data");
assert.ok(pets.length >= 5, "Prism Grove needs helper data");
assert.equal(manifest.id, "prism-grove");
assert.equal(manifest.platforms.web, true);
assert.equal(manifest.platforms.macos, true);
assert.equal(manifest.platforms.ios, true);
const html = readFileSync(path.join(gameDir, "index.html"), "utf8");
assert.ok(html.includes("id=\"game-root\""));
assert.ok(html.includes("arcade-core.js"));
assert.ok(html.includes("createArcadeGame"));
assert.ok(html.includes("prismcade.localAccount.v0"));
assert.ok(html.includes("prismGrove.save.v0"));
assert.ok(html.includes("openCharacterCreator"));
assert.ok(html.includes("applyOfflineGrowth"));
assert.ok(html.includes("drawAvatar"));
assert.ok(html.includes("seedShop"));
console.log(`Prism Grove validation passed: ${crops.length} crops, ${variants.length} variants, ${cosmetics.length} cosmetics, ${pets.length} helpers.`);
