import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

import {
  appearanceFromPrismcadeRecipe,
  createPixelFruitArenaCharacterFromPrismcadeManifest
} from "../../games/pixel-fruit-arena/src/characters/prismcadeCreatorAdapter.js";

const repoRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "../..");
const registryPath = path.join(repoRoot, "data/prismcade/character-creator-packs.json");
const sampleRecipePath = path.join(repoRoot, "data/prismcade/character-recipes/starter-avatar.recipe.json");
const sampleManifestPath = path.join(repoRoot, "data/prismcade/character-manifests/starter-avatar.manifest.json");
const registry = JSON.parse(readFileSync(registryPath, "utf8"));
const sampleRecipe = JSON.parse(readFileSync(sampleRecipePath, "utf8"));
const sampleManifest = JSON.parse(readFileSync(sampleManifestPath, "utf8"));

assert.equal(registry.schemaVersion, "prismcade-character-creator-packs-v0");
assert.deepEqual(registry.frameSize, [64, 64], "Prismcade character creator currently expects 64x64 frames");
assert.equal(registry.safeExportPolicy?.starterOutfitRequired, true, "starter outfit must be required");
assert.equal(registry.safeExportPolicy?.bodyOnlyExport, "blocked", "body-only export must stay blocked");
assert.ok(Array.isArray(registry.renderLayerOrder) && registry.renderLayerOrder.length >= 6, "render layer order is required");
assert.ok(registry.atlasContracts?.default64, "default 64x64 atlas contract is required");
assert.deepEqual(registry.atlasContracts.default64.frameSize, [64, 64], "default atlas contract must use 64x64 frames");
assert.ok(registry.exportContracts?.recipe?.repoPathPattern, "recipe export contract path is required");
assert.ok(registry.exportContracts?.manifest?.pixelFruitArenaAdapter, "manifest export must name the Pixel Fruit Arena adapter");
assert.ok(Array.isArray(registry.sourcePacks) && registry.sourcePacks.length >= 2, "female and male source packs are required");
assert.ok(registry.sourcePacks.some((pack) => pack.bodyFamily === "female"), "female source pack is required");
assert.ok(registry.sourcePacks.some((pack) => pack.bodyFamily === "male"), "male source pack is required");
assert.ok(registry.sourcePacks.some((pack) => pack.status === "creator_ready_beta"), "a beta-ready creator source pack is required");
assert.ok(registry.sourcePacks.some((pack) => pack.status === "creator_ready_alpha"), "an alpha-ready creator source pack is required");

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
assert.ok(
  registry.slots.outfit.some((entry) => entry.id === "construction-body-only" && entry.safeForExport === false),
  "body-only construction option must exist and must not be public-export safe"
);

for (const [slot, entries] of Object.entries(registry.slots)) {
  for (const entry of entries) {
    assert.match(entry.id, /^[a-z0-9][a-z0-9-]*$/, `${slot} option id must be slug-like: ${entry.id}`);
    assert.ok("proceduralFallback" in entry, `${slot}/${entry.id} must declare a proceduralFallback (null is allowed)`);
  }
}

for (const pack of registry.sourcePacks) {
  assert.match(pack.id, /^[a-z0-9][a-z0-9-]*$/, `pack id must be slug-like: ${pack.id}`);
  assert.ok(pack.displayName, `pack ${pack.id} needs displayName`);
  assert.ok(pack.status, `pack ${pack.id} needs status`);
  assert.ok(pack.atlasStatus, `pack ${pack.id} needs atlasStatus`);
  assert.ok(registry.atlasContracts[pack.atlasContract], `pack ${pack.id} references unknown atlasContract ${pack.atlasContract}`);
  assert.ok(pack.coverage && typeof pack.coverage === "object", `pack ${pack.id} needs coverage`);
  assert.ok(Array.isArray(pack.missingBeforePublicCreator), `pack ${pack.id} needs missingBeforePublicCreator list`);
  for (const file of pack.sourceFiles || []) {
    assert.ok(file.fileName, `pack ${pack.id} source file needs fileName`);
    assert.ok(file.recommendedRepoPath, `pack ${pack.id} source file needs recommendedRepoPath`);
    assert.match(file.recommendedRepoPath, /^[^/]+\//, `recommended path must be repo-relative: ${file.recommendedRepoPath}`);
    if (file.localSourcePath) {
      assert.match(file.localSourcePath, /^\/Users\/prismtek\//, `local source path must stay user-local and explicit: ${file.localSourcePath}`);
    }
  }
}

assert.equal(sampleRecipe.schemaVersion, registry.exportContracts.recipe.schemaVersion, "sample recipe schema mismatch");
assert.equal(sampleManifest.schemaVersion, registry.exportContracts.manifest.schemaVersion, "sample manifest schema mismatch");
assert.equal(sampleRecipe.id, registry.defaultRecipe.id, "sample recipe should mirror the default recipe id");
assert.equal(sampleManifest.recipe, "data/prismcade/character-recipes/starter-avatar.recipe.json", "sample manifest recipe path must be repo-relative");
assert.equal(sampleManifest.pixelFruitArena.adapter, registry.exportContracts.manifest.pixelFruitArenaAdapter, "sample manifest adapter path mismatch");
assert.equal(sampleManifest.publicPlayable, true, "sample manifest must be public playable because it uses a safe starter outfit");
assert.equal(sampleRecipe.exportPolicy.exportable, true, "sample recipe must be exportable");

const sampleAppearance = appearanceFromPrismcadeRecipe(sampleRecipe);
assert.equal(sampleAppearance.clothingStyle, "blue_hoodie", "sample recipe should adapt outfit to Pixel Fruit Arena clothing style");
assert.equal(sampleAppearance.skinTone, "#e7ae78", "sample recipe should adapt skin tone");

const sampleCharacter = createPixelFruitArenaCharacterFromPrismcadeManifest(sampleManifest, sampleRecipe);
assert.equal(sampleCharacter.name, "Starter Avatar", "sample adapter must preserve display name");
assert.equal(sampleCharacter.sprite_key, sampleManifest.pixelFruitArena.spriteKey, "sample adapter must use manifest sprite key");
assert.equal(sampleCharacter.equipped_fruit, sampleManifest.pixelFruitArena.starterFruit, "sample adapter must use manifest starter fruit");
assert.equal(sampleCharacter.prismcade_creator.recipe_id, sampleRecipe.id, "sample adapter must preserve creator recipe id");

console.log(`Validated ${registry.sourcePacks.length} Prismcade character creator source packs.`);
