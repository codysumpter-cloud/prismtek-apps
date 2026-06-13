import assert from "node:assert/strict";
import { existsSync, readdirSync } from "node:fs";
import { readFile } from "node:fs/promises";
import path from "node:path";
import { fileURLToPath } from "node:url";

import { CHARACTER_SPRITES } from "../src/assets/assetManifest.js";
import { COSMETICS, createCharacter } from "../src/characters/characterCreator.js";
import { applyAttack, checkRingOut, variantFor, awakenedAbilityFor } from "../src/combat/combatSystem.js";
import { FRUITS } from "../src/fruits/fruits.js";
import { PRISMTEK_FRUIT_ENCYCLOPEDIA } from "../src/fruits/prismtekFruitEncyclopedia.js";
import { createMatch } from "../src/systems/matchSystem.js";
import { SKY_RUINS } from "../src/stages/skyRuins.js";

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");

const fruitData = JSON.parse(await readFile(path.join(root, "data/fruits/fruits.json"), "utf8"));
assert.equal(fruitData.length, 6, "six starter fruits are required");
assert.ok(PRISMTEK_FRUIT_ENCYCLOPEDIA.length >= 75, "playable encyclopedia needs broad coverage");
assert.ok(Object.keys(FRUITS).length >= 80, "runtime must include starter fruits plus encyclopedia fruits");
for (const fruit of fruitData) {
  assert.equal(fruit.abilities.length, 3, `${fruit.id} must have three abilities`);
  assert.ok(fruit.awakening, `${fruit.id} needs awakening`);
  assert.ok(FRUITS[fruit.id], `${fruit.id} must have a runtime fruit definition`);
}
for (const fruit of Object.values(FRUITS)) {
  assert.ok(fruit.color && fruit.icon && fruit.awakening, `${fruit.id} needs existing fruit-style color, icon, and awakening`);
  assert.equal(fruit.abilities.length, 3, `${fruit.id} must have three runtime abilities`);
}

assert.ok(COSMETICS.spriteKeys.includes("male_basic"), "male body must be selectable");
assert.ok(COSMETICS.spriteKeys.includes("female_basic"), "female body must be selectable");
assert.ok(COSMETICS.hairStyles.length >= 8, "hair customization needs imported-style options");
assert.ok(COSMETICS.clothingStyles.length >= 8, "clothing customization needs imported-style options");
assert.ok(CHARACTER_SPRITES.male_basic?.customizable, "male sprite must be marked customizable");
assert.ok(CHARACTER_SPRITES.female_basic?.customizable, "female sprite must be marked customizable");
for (const key of ["male_basic", "female_basic"]) {
  const sprite = CHARACTER_SPRITES[key];
  assert.equal(sprite.frameWidth, 32, `${key} should match current tiny-hero frame width`);
  assert.equal(sprite.frameHeight, 32, `${key} should match current tiny-hero frame height`);
  for (const animation of ["idle", "walk", "run", "jump", "fall", "attack", "special", "hurt", "knockout", "victory"]) {
    assert.ok(sprite.animations[animation], `${key} missing ${animation} animation`);
    assert.ok(existsSync(path.join(root, sprite.animations[animation].src)), `missing ${key}/${animation} sprite sheet`);
  }
}
const male = createCharacter({ spriteKey: "male_basic", appearance: { hairStyle: "mohawk", clothingStyle: "armor" } });
const female = createCharacter({ spriteKey: "female_basic", appearance: { hairStyle: "ponytail", clothingStyle: "skirt" } });
assert.equal(male.sprite_key, "male_basic");
assert.equal(female.sprite_key, "female_basic");
assert.equal(male.appearance.clothingStyle, "armor");
assert.equal(female.appearance.clothingStyle, "skirt");

const stageData = JSON.parse(await readFile(path.join(root, "data/stages/sky_ruins.json"), "utf8"));
assert.ok(stageData.platforms.length >= 3, "stage needs multiple platforms");
assert.ok(stageData.respawns.length >= 4, "stage needs four respawn points");
assert.equal(SKY_RUINS.respawns.length, 4, "runtime stage needs four respawn points");
assert.ok(SKY_RUINS.bounds, "runtime stage needs ring-out bounds");

const characterManifest = JSON.parse(await readFile(path.join(root, "assets/characters/prismtek_placeholder_character.json"), "utf8"));
assert.equal(characterManifest.sprite_width, 64);
assert.equal(characterManifest.sprite_height, 64);
assert.equal(characterManifest.animations.length, 10);
assert.equal(process.env.USE_REFERENCE_TEST_ASSETS === "true" && process.env.NODE_ENV === "production", false, "reference assets cannot be used in production");
for (const asset of [
  "assets/characters/prismtek-custom/male-basic.svg",
  "assets/characters/prismtek-custom/female-basic.svg",
  "assets/characters/tiny-hero/pink/idle_4.png",
  "assets/characters/tiny-hero/pink/run_6.png",
  "assets/characters/tiny-hero/owlet/attack1_4.png",
  "assets/characters/tiny-hero/dude/hurt_4.png",
  "assets/stages/four-seasons/four-seasons-tileset.png",
  "assets/licenses/craftpix-tiny-hero-license.txt",
  "assets/licenses/rottingpixels-four-seasons.txt",
  "assets/effects/elemental-vfx/firebolt.png",
  "assets/effects/elemental-vfx/ice-hit.png",
  "assets/effects/elemental-vfx/thunder-beam.png",
  "assets/effects/elemental-vfx/dark-column.png",
  "assets/effects/elemental-vfx/earth-impact.png",
  "assets/effects/elemental-vfx/hit-spark.png"
]) {
  assert.ok(existsSync(path.join(root, asset)), `missing runtime asset: ${asset}`);
}
const referenceFiles = readdirSync(path.join(root, "assets/reference/onepiece-test"), { recursive: true }).filter((name) => !String(name).endsWith(".gitkeep"));
if (process.env.NODE_ENV === "production") assert.equal(referenceFiles.length, 0, "reference test assets cannot be present in production validation");

const html = await readFile(path.join(root, "index.html"), "utf8");
assert.match(html, /rel="manifest"/, "index must link a web app manifest");
assert.match(html, /deviceStatus/, "index must expose device status UI");

const manifest = JSON.parse(await readFile(path.join(root, "app.webmanifest"), "utf8"));
assert.equal(manifest.name, "Pixel Fruit Arena");
assert.ok(manifest.start_url, "manifest needs start_url");
assert.ok(manifest.display, "manifest needs display mode");

const serviceWorker = await readFile(path.join(root, "sw.js"), "utf8");
assert.match(serviceWorker, /CACHE_NAME/, "service worker needs a named cache");
assert.match(serviceWorker, /prismtekFruitEncyclopedia/, "service worker must cache encyclopedia runtime modules");
assert.match(serviceWorker, /male-basic\.svg/, "service worker must cache male character sheet");
assert.match(serviceWorker, /female-basic\.svg/, "service worker must cache female character sheet");
assert.match(serviceWorker, /fetch/, "service worker needs fetch handling");

for (const fruitId of Object.keys(FRUITS)) {
  const attacker = createTestFighter(0, fruitId, 300, 230);
  const defender = createTestFighter(1, "flame", 340, 230);
  attacker.invulnerable = 0;
  defender.invulnerable = 0;
  for (const ability of FRUITS[fruitId].abilities) {
    defender.damage = 0;
    defender.health = defender.maxHealth;
    defender.hitstun = 0;
    defender.x = attacker.x + 40;
    defender.y = attacker.y;
    attacker.cooldowns = {};
    const events = [];
    applyAttack(attacker, [defender], ability, events);
    assert.ok(events.some((event) => event.type === "attack"), `${fruitId}/${ability.id} must emit attack event`);
    assert.ok(defender.damage > 0, `${fruitId}/${ability.id} must damage a nearby target`);
    assert.ok(defender.health < defender.maxHealth, `${fruitId}/${ability.id} must reduce health bar value`);
  }
}

const variantAttacker = createTestFighter(0, "flame", 300, 230);
variantAttacker.heldMove = 1;
assert.equal(variantFor(variantAttacker).id, "forward", "forward modifier required");
variantAttacker.heldMove = -1;
assert.equal(variantFor(variantAttacker).id, "back", "back modifier required");
variantAttacker.heldMove = 0;
variantAttacker.heldAim = -1;
assert.equal(variantFor(variantAttacker).id, "up", "up modifier required");
variantAttacker.heldAim = 1;
assert.equal(variantFor(variantAttacker).id, "down", "down modifier required");
const awakenedFireball = awakenedAbilityFor(FRUITS.flame.abilities[0], FRUITS.flame, variantFor(variantAttacker));
assert.ok(awakenedFireball.damage > FRUITS.flame.abilities[0].damage, "awakened ability should upgrade damage");
assert.ok(awakenedFireball.cooldown < FRUITS.flame.abilities[0].cooldown, "awakened ability should improve cooldown");

const hakiAttacker = createTestFighter(0, "flame", 300, 230);
const hakiDefender = createTestFighter(1, "frost", 340, 230);
hakiAttacker.haki = 80;
hakiDefender.hakiGuard = 0.55;
applyAttack(hakiAttacker, [hakiDefender], FRUITS.flame.abilities[0], []);
assert.ok(hakiAttacker.haki < 80, "haki attacks should spend haki");
assert.ok(hakiDefender.damage > 0, "guarded target should still take reduced damage");

const match = createMatch({
  stage: SKY_RUINS,
  fruits: FRUITS,
  players: [
    { slot: 0, character: createCharacter({ name: "P1", spriteKey: "male_basic", ownedFruits: Object.keys(FRUITS), equippedFruit: "flame" }), fruitId: "flame" },
    { slot: 1, character: createCharacter({ name: "P2", spriteKey: "female_basic", ownedFruits: Object.keys(FRUITS), equippedFruit: "volt" }), fruitId: "volt" }
  ]
});

let snapshot = match.snapshot();
assert.equal(snapshot.fighters.length, 2, "2P match should create two fighters");
assert.equal(snapshot.fighters[0].spriteKey, "male_basic", "male fighter should be playable");
assert.equal(snapshot.fighters[1].spriteKey, "female_basic", "female fighter should be playable");
snapshot.fighters[0].invulnerable = 0;
snapshot.fighters[1].invulnerable = 0;
snapshot.fighters[0].x = 300;
snapshot.fighters[0].y = 230;
snapshot.fighters[1].x = 340;
snapshot.fighters[1].y = 230;
match.update(0.016, [{ slot: 0, type: "haki" }, { slot: 0, type: "attack", index: 0 }]);
snapshot = match.snapshot();
assert.ok(snapshot.events.some((event) => event.type === "attack"), "match update should emit attack events");
assert.ok(snapshot.fighters[1].damage > 0, "match attack should damage opponent");
assert.ok(snapshot.fighters[0].haki < 35, "match haki action should spend haki");

const ringout = snapshot.fighters[1];
ringout.x = SKY_RUINS.bounds.right + 1;
ringout.y = 230;
assert.equal(checkRingOut(ringout, SKY_RUINS), true, "fighter outside bounds should ring out");
assert.equal(ringout.stocks, 2, "ring-out should remove one stock");
assert.equal(ringout.health, ringout.maxHealth, "ring-out should reset health");

snapshot.fighters[1].stocks = 0;
assert.equal(match.isComplete(), true, "match should complete when one fighter remains");

console.log("Tests passed: character customization, encyclopedia fruits, awakened moves, haki, health HUD data, directional modifiers, match combat, ring-outs, completion, release guard.");

function createTestFighter(slot, fruitId, x, y) {
  return {
    id: `p${slot + 1}`,
    slot,
    character: createCharacter({ name: `P${slot + 1}`, ownedFruits: Object.keys(FRUITS), equippedFruit: fruitId }),
    fruitId,
    fruit: FRUITS[fruitId],
    x,
    y,
    vx: 0,
    vy: 0,
    facing: 1,
    w: 34,
    h: 52,
    stocks: 3,
    damage: 0,
    health: 100,
    maxHealth: 100,
    jumps: 2,
    grounded: false,
    hitstun: 0,
    invulnerable: 0,
    awakening: 0,
    awakened: 0,
    haki: 35,
    hakiActive: 0,
    hakiGuard: 0,
    hakiFlash: 0,
    cooldowns: {},
    animTime: 0,
    attackFlash: 0,
    attackKind: "attack",
    state: "idle",
    spriteKey: "male_basic",
    ai: false
  };
}
