#!/usr/bin/env node
import assert from "node:assert/strict";
import { existsSync, readFileSync } from "node:fs";
import path from "node:path";

const root = process.cwd();
const registryPath = path.join(root, "data/prismcade/character-template-registry.json");
const sourceRegistryPath = path.join(root, "data/integrations/pixellab-character-export-registry.json");
const allowedStatuses = new Set([
  "source-export-ready-needs-game-ready-curation",
  "source-export-ready-needs-polish",
  "source-export-ready-needs-animation-jobs",
  "game-ready",
  "blocked"
]);

function readJson(file) {
  return JSON.parse(readFileSync(file, "utf8"));
}

function assertString(value, label) {
  assert.equal(typeof value, "string", `${label} must be a string`);
  assert.ok(value.trim().length > 0, `${label} cannot be empty`);
}

function assertArray(value, label) {
  assert.ok(Array.isArray(value), `${label} must be an array`);
}

function assertRelativeRepoPath(value, label) {
  assertString(value, label);
  assert.ok(!path.isAbsolute(value), `${label} must be repo-relative`);
  assert.ok(!value.includes(".."), `${label} must not contain ..`);
}

assert.ok(existsSync(registryPath), `Missing ${registryPath}`);
assert.ok(existsSync(sourceRegistryPath), `Missing ${sourceRegistryPath}`);

const registry = readJson(registryPath);
const sourceRegistry = readJson(sourceRegistryPath);

assert.equal(registry.schemaVersion, "prismcade-character-template-registry-v0", "Unexpected schemaVersion");
assert.equal(sourceRegistry.schemaVersion, "prismtek-pixellab-character-export-registry-v1", "Unexpected PixelLab source registry schemaVersion");

assert.ok(registry.docs && typeof registry.docs === "object", "registry.docs is required");
for (const [key, docPath] of Object.entries(registry.docs)) {
  assertRelativeRepoPath(docPath, `docs.${key}`);
  assert.ok(existsSync(path.join(root, docPath)), `Missing docs.${key}: ${docPath}`);
}

assert.ok(registry.gameReadyTarget && typeof registry.gameReadyTarget === "object", "gameReadyTarget is required");
assert.equal(registry.gameReadyTarget.frameWidth, 64, "gameReadyTarget.frameWidth must be 64");
assert.equal(registry.gameReadyTarget.frameHeight, 64, "gameReadyTarget.frameHeight must be 64");
assert.equal(registry.gameReadyTarget.transparentBackground, true, "transparentBackground must be true");
assertArray(registry.gameReadyTarget.directions, "gameReadyTarget.directions");

assertArray(registry.canonicalSlots, "canonicalSlots");
for (const slot of ["idle", "walk", "run", "hurt", "victory", "defeat"]) {
  assert.ok(registry.canonicalSlots.includes(slot), `canonicalSlots must include ${slot}`);
}

const sourceVariantIds = new Set((sourceRegistry.characters || []).map((character) => character.variantId));
for (const group of sourceRegistry.fourDirectionSourceGroups || []) {
  sourceVariantIds.add(group.variantId);
}

assertArray(registry.templateFamilies, "templateFamilies");
assert.ok(registry.templateFamilies.length >= 3, "templateFamilies should include Buddy, Prismtek, and Female templates");

const familyIds = new Set();
for (const family of registry.templateFamilies) {
  assertString(family.id, "templateFamily.id");
  assert.ok(!familyIds.has(family.id), `Duplicate template family id ${family.id}`);
  familyIds.add(family.id);

  assertString(family.displayName, `${family.id}.displayName`);
  assertString(family.sourceVariantId, `${family.id}.sourceVariantId`);
  assert.ok(sourceVariantIds.has(family.sourceVariantId), `${family.id} sourceVariantId ${family.sourceVariantId} is not present in the PixelLab source registry`);
  assert.ok(allowedStatuses.has(family.status), `${family.id}.status is not allowed: ${family.status}`);
  assertString(family.role, `${family.id}.role`);
  assertArray(family.requiredSlots, `${family.id}.requiredSlots`);
  assert.ok(family.requiredSlots.includes("idle"), `${family.id} must require idle`);
  assert.ok(family.requiredSlots.includes("walk"), `${family.id} must require walk`);
  assert.ok(family.requiredSlots.includes("hurt"), `${family.id} must require hurt`);
  for (const slot of family.requiredSlots) {
    assert.ok(registry.canonicalSlots.includes(slot), `${family.id} required slot ${slot} is not canonical`);
  }

  assert.ok(family.derivativePolicy && typeof family.derivativePolicy === "object", `${family.id}.derivativePolicy is required`);
  assert.equal(typeof family.derivativePolicy.mayCreateClothing, "boolean", `${family.id}.derivativePolicy.mayCreateClothing must be boolean`);
  assert.equal(typeof family.derivativePolicy.mayCreateHairstyles, "boolean", `${family.id}.derivativePolicy.mayCreateHairstyles must be boolean`);
  assertArray(family.derivativePolicy.mustPreserveIdentityNotes, `${family.id}.derivativePolicy.mustPreserveIdentityNotes`);
  assertArray(family.productionNeeds, `${family.id}.productionNeeds`);
  assertArray(family.targetGames, `${family.id}.targetGames`);
}

for (const requiredFamily of ["buddy-core", "prismtek-player", "female-blue-hoodie-player"]) {
  assert.ok(familyIds.has(requiredFamily), `Missing required family ${requiredFamily}`);
}

const buddy = registry.templateFamilies.find((family) => family.id === "buddy-core");
assert.equal(buddy.derivativePolicy.mayCreateNewBuddys, true, "Buddy template must allow new Buddy derivatives");
assert.equal(buddy.derivativePolicy.mayCreateClothing, true, "Buddy template must allow clothing variants");
assert.equal(buddy.derivativePolicy.mayCreateHairstyles, true, "Buddy template must allow hairstyle variants");

assertArray(registry.clothingSlots, "clothingSlots");
const clothingSlotIds = new Set(registry.clothingSlots.map((slot) => slot.id));
for (const requiredSlot of ["head", "hair", "torso", "legs", "feet"]) {
  assert.ok(clothingSlotIds.has(requiredSlot), `Missing clothing slot ${requiredSlot}`);
}

assertArray(registry.factoryOutputs, "factoryOutputs");
for (const output of registry.factoryOutputs) {
  assertString(output.type, "factoryOutputs[].type");
  assertString(output.pathPattern, `${output.type}.pathPattern`);
  assert.ok(output.pathPattern.includes("{characterId}"), `${output.type}.pathPattern must include {characterId}`);
}

assertArray(registry.readinessRules, "readinessRules");
assert.ok(registry.readinessRules.some((rule) => rule.includes("not game-ready")), "readinessRules must make source-vs-game-ready distinction explicit");

console.log(`Prismcade character template registry passed: ${registry.templateFamilies.length} template families, ${registry.clothingSlots.length} clothing slots.`);
