#!/usr/bin/env node
import assert from "node:assert/strict";
import { existsSync, readFileSync } from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

import { CHARACTER_SPRITES } from "../src/assets/assetManifest.js";
import { COSMETICS, createCharacter } from "../src/characters/characterCreator.js";
import { PRISMCADE_PLAYABLE_ROSTER, PRISMCADE_SPRITE_KEYS } from "../src/characters/prismcadeRoster.js";
import { FRUITS } from "../src/fruits/fruits.js";

const gameRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const repoRoot = path.resolve(gameRoot, "../..");
const rosterPath = path.join(gameRoot, "data/characters/prismcade_playable_roster.json");
const pixellabRegistryPath = path.join(repoRoot, "data/integrations/pixellab-character-export-registry.json");
const templateRegistryPath = path.join(repoRoot, "data/prismcade/character-template-registry.json");
const engineAdaptersPath = path.join(repoRoot, "data/integrations/game-engine-adapters.json");

const requiredRuntimeAnimations = ["idle", "walk", "run", "jump", "fall", "attack", "special", "hurt", "knockout", "victory"];
const requiredRosterIds = [
  "buddy",
  "prismtek",
  "prismtek-jones",
  "female-blue-hoodie",
  "ponytail-guy",
  "prismtek-pixel-god",
  "prismbot-pixel-god"
];

function readJson(file) {
  return JSON.parse(readFileSync(file, "utf8"));
}

function assertRepoRelative(value, label) {
  assert.equal(typeof value, "string", `${label} must be a string`);
  assert.ok(!path.isAbsolute(value), `${label} must be repo-relative`);
  assert.ok(!value.includes(".."), `${label} must not contain ..`);
}

assert.ok(existsSync(rosterPath), "Prismcade playable roster JSON is required");
assert.ok(existsSync(pixellabRegistryPath), "PixelLab character registry is required");
assert.ok(existsSync(templateRegistryPath), "Prismcade character template registry is required");
assert.ok(existsSync(engineAdaptersPath), "Game engine adapter registry is required");

const roster = readJson(rosterPath);
const pixellabRegistry = readJson(pixellabRegistryPath);
const templateRegistry = readJson(templateRegistryPath);
const engineAdapters = readJson(engineAdaptersPath);

assert.equal(roster.schemaVersion, "pixel-fruit-arena-prismcade-playable-roster-v0");
assert.deepEqual(roster.requiredRuntimeAnimations, requiredRuntimeAnimations, "runtime animation contract must stay explicit");
assert.equal(roster.engineAdapterDecision.liveRuntime, "pixel-fruit-arena-browser-canvas", "Pixel Fruit Arena should not silently switch engines");
assert.equal(roster.engineAdapterDecision.openbor, "reference-only-contract", "OpenBOR must remain reference-only until an adapter output exists");
assert.match(roster.engineAdapterDecision.mugen, /do not import third-party content packs/, "MUGEN content-pack guardrail is required");
assert.equal(roster.engineAdapterDecision.ikemen, "reference-only-contract", "Ikemen must remain reference-only until an adapter output exists");

for (const registryPath of Object.values(roster.sourceRegistries)) assertRepoRelative(registryPath, "sourceRegistries path");

const adapterIds = new Set(engineAdapters.adapters.map((adapter) => adapter.id));
assert.ok(adapterIds.has("openbor-brawler-adapter"), "OpenBOR adapter contract must exist");
assert.ok(adapterIds.has("ikemen-go-fighter-adapter"), "Ikemen adapter contract must exist");
assert.ok(engineAdapters.adapters.find((adapter) => adapter.id === "openbor-brawler-adapter").status === "contract-only", "OpenBOR cannot be runtime-ready here");
assert.ok(engineAdapters.adapters.find((adapter) => adapter.id === "ikemen-go-fighter-adapter").status === "contract-only", "Ikemen cannot be runtime-ready here");

const sourceVariantIds = new Set((pixellabRegistry.characters || []).map((character) => character.variantId));
for (const group of pixellabRegistry.fourDirectionSourceGroups || []) sourceVariantIds.add(group.variantId);

const templateFamilyIds = new Set(templateRegistry.templateFamilies.map((family) => family.id));
const dataById = new Map(roster.characters.map((character) => [character.id, character]));
const runtimeById = new Map(PRISMCADE_PLAYABLE_ROSTER.map((character) => [character.id, character]));

for (const requiredId of requiredRosterIds) {
  assert.ok(dataById.has(requiredId), `roster JSON missing ${requiredId}`);
  assert.ok(runtimeById.has(requiredId), `runtime roster missing ${requiredId}`);
}

for (const character of roster.characters) {
  const runtimeCharacter = runtimeById.get(character.id);
  assert.ok(runtimeCharacter, `${character.id} missing from runtime module`);
  assert.equal(runtimeCharacter.spriteKey, character.spriteKey, `${character.id} spriteKey mismatch`);
  assert.equal(runtimeCharacter.sourceVariantId, character.sourceVariantId, `${character.id} sourceVariantId mismatch`);
  assert.equal(runtimeCharacter.defaultFighter.fruitId, character.defaultFighter.fruitId, `${character.id} fruitId mismatch`);
  assert.equal(runtimeCharacter.defaultFighter.combatStyle, character.defaultFighter.combatStyle, `${character.id} combatStyle mismatch`);

  assert.ok(sourceVariantIds.has(character.sourceVariantId), `${character.id} source variant is not in PixelLab registry`);
  assert.ok(templateFamilyIds.has(character.templateFamilyId), `${character.id} template family is not in Prismcade registry`);
  assert.ok(PRISMCADE_SPRITE_KEYS.includes(character.spriteKey), `${character.id} sprite key missing from runtime key list`);
  assert.ok(COSMETICS.spriteKeys.includes(character.spriteKey), `${character.id} sprite key missing from character creator choices`);
  assert.ok(FRUITS[character.defaultFighter.fruitId], `${character.id} fruit is not available at runtime`);
  assert.ok(COSMETICS.combatStyles.includes(character.defaultFighter.combatStyle), `${character.id} combat style is not available`);

  const sprite = CHARACTER_SPRITES[character.spriteKey];
  assert.ok(sprite, `${character.id} has no CHARACTER_SPRITES entry`);
  assert.equal(sprite.frameWidth, 64, `${character.id} frameWidth must be 64`);
  assert.equal(sprite.frameHeight, 64, `${character.id} frameHeight must be 64`);
  assert.equal(sprite.scale, 1, `${character.id} scale must be 1 for 64x64 sheets`);
  assert.equal(sprite.source.sourceVariantId, character.sourceVariantId, `${character.id} asset manifest source mismatch`);

  assertRepoRelative(character.runtimeManifest, `${character.id}.runtimeManifest`);
  const manifestPath = path.join(repoRoot, character.runtimeManifest);
  assert.ok(existsSync(manifestPath), `${character.id} generated manifest missing`);
  const manifest = readJson(manifestPath);
  assert.equal(manifest.sourceVariantId, character.sourceVariantId, `${character.id} generated manifest source mismatch`);
  assert.equal(manifest.outputFrameSize.width, 64, `${character.id} generated width must be 64`);
  assert.equal(manifest.outputFrameSize.height, 64, `${character.id} generated height must be 64`);
  assert.equal(manifest.animationFidelity, character.animationFidelity, `${character.id} animation fidelity mismatch`);

  for (const animationName of requiredRuntimeAnimations) {
    const animation = sprite.animations[animationName];
    assert.ok(animation, `${character.id} missing ${animationName} runtime animation`);
    assert.equal(animation.frames, 4, `${character.id}/${animationName} should use four frame strips`);
    assert.ok(existsSync(path.join(gameRoot, animation.src)), `${character.id}/${animationName} sheet missing: ${animation.src}`);
    assert.ok(manifest.animations[animationName], `${character.id} manifest missing ${animationName}`);
    assert.equal(manifest.animations[animationName].src, animation.src, `${character.id}/${animationName} manifest src mismatch`);
  }

  const created = createCharacter({
    name: character.defaultFighter.name,
    spriteKey: character.spriteKey,
    combatStyle: character.defaultFighter.combatStyle,
    ownedFruits: Object.keys(FRUITS),
    equippedFruit: character.defaultFighter.fruitId,
    appearance: character.defaultFighter.appearance
  });
  assert.equal(created.sprite_key, character.spriteKey, `${character.id} createCharacter sprite mismatch`);
  assert.equal(created.equipped_fruit, character.defaultFighter.fruitId, `${character.id} createCharacter fruit mismatch`);
}

const heldBackBmo = roster.sourceGroupsHeldBack.find((entry) => entry.sourceVariantId === "bmo-4dir-source-group");
assert.ok(heldBackBmo, "BMO 4-direction source group decision must be explicit");
assert.match(heldBackBmo.reason, /4-direction/, "BMO held-back note must preserve the 4-direction constraint");

console.log(`Prismcade Pixel Fruit Arena roster passed: ${roster.characters.length} playable entries, ${requiredRuntimeAnimations.length} animations each.`);
