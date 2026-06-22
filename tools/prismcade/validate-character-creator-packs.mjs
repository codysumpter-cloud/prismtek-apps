import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const repoRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "../..");
const registryPath = path.join(repoRoot, "data/prismcade/character-creator-packs.json");
const registry = JSON.parse(readFileSync(registryPath, "utf8"));

assert.equal(registry.schemaVersion, "prismcade-character-creator-packs-v0");
assert.deepEqual(registry.frameSize, [64, 64], "Prismcade character creator currently expects 64x64 frames");
assert.equal(registry.safeExportPolicy?.starterOutfitRequired, true, "starter outfit must be required");
assert.equal(registry.safeExportPolicy?.bodyOnlyExport, "blocked", "body-only export must stay blocked");
assert.ok(Array.isArray(registry.renderLayerOrder) && registry.renderLayerOrder.length >= 6, "render layer order is required");
assert.ok(Array.isArray(registry.sourcePacks) && registry.sourcePacks.length >= 2, "female and male source packs are required");
assert.ok(registry.sourcePacks.some((pack) => pack.bodyFamily === "female"), "female source pack is required");
assert.ok(registry.sourcePacks.some((pack) => pack.bodyFamily === "male"), "male source pack is required");

const requiredSlots = ["bodyPreset", "skinTone", "face", "hair", "outfit", "accessory", "emote", "animation"];
for (const slot of requiredSlots) {
  assert.ok(Array.isArray(registry.slots?.[slot]) && registry.slots[slot].length > 0, `${slot} slot options are required`);
}

const slotIds = Object.fromEntries(requiredSlots.map((slot) => [slot, new Set(registry.slots[slot].map((entry) => entry.id))]));
for (const [slot, value] of Object.entries(registry.defaultRecipe?.slots || {})) {
  assert.ok(slotIds[slot]?.has(value), `defaultRecipe slot ${slot} references unknown option ${value}`);
}

const safeOutfits = registry.slots.outfit.filter((entry) => entry.safeForExport === true);
assert.ok(safeOutfits.length > 0, "at least one safe outfit is required");
assert.ok(safeOutfits.some((entry) => entry.id === registry.defaultRecipe.slots.outfit), "default outfit must be safe for export");

for (const pack of registry.sourcePacks) {
  assert.match(pack.id, /^[a-z0-9][a-z0-9-]*$/, `pack id must be slug-like: ${pack.id}`);
  assert.ok(pack.displayName, `pack ${pack.id} needs displayName`);
  assert.ok(pack.status, `pack ${pack.id} needs status`);
  assert.ok(pack.coverage && typeof pack.coverage === "object", `pack ${pack.id} needs coverage`);
  assert.ok(Array.isArray(pack.missingBeforePublicCreator), `pack ${pack.id} needs missingBeforePublicCreator list`);
  for (const file of pack.sourceFiles || []) {
    assert.ok(file.fileName, `pack ${pack.id} source file needs fileName`);
    assert.ok(file.recommendedRepoPath, `pack ${pack.id} source file needs recommendedRepoPath`);
    assert.match(file.recommendedRepoPath, /^[^/]+\//, `recommended path must be repo-relative: ${file.recommendedRepoPath}`);
  }
}

console.log(`Validated ${registry.sourcePacks.length} Prismcade character creator source packs.`);
