import assert from "node:assert/strict";
import { existsSync, readdirSync } from "node:fs";
import { readFile } from "node:fs/promises";
import path from "node:path";
import { fileURLToPath } from "node:url";

import { createCharacter } from "../src/characters/characterCreator.js";
import { applyAttack, checkRingOut } from "../src/combat/combatSystem.js";
import { FRUITS } from "../src/fruits/fruits.js";
import { createMatch } from "../src/systems/matchSystem.js";
import { SKY_RUINS } from "../src/stages/skyRuins.js";

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");

const fruitData = JSON.parse(await readFile(path.join(root, "data/fruits/fruits.json"), "utf8"));
assert.equal(fruitData.length, 6, "six fruits are required");
for (const fruit of fruitData) {
  assert.equal(fruit.abilities.length, 3, `${fruit.id} must have three abilities`);
  assert.ok(fruit.awakening, `${fruit.id} needs awakening`);
  assert.ok(FRUITS[fruit.id], `${fruit.id} must have a runtime fruit definition`);
}

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
  "assets/characters/tiny-hero/pink/idle_4.png",
  "assets/characters/tiny-hero/pink/run_6.png",
  "assets/characters/tiny-hero/owlet/attack1_4.png",
  "assets/characters/tiny-hero/dude/hurt_4.png",
  "assets/stages/four-seasons/four-seasons-tileset.png",
  "assets/licenses/craftpix-tiny-hero-license.txt",
  "assets/licenses/rottingpixels-four-seasons.txt"
]) {
  assert.ok(existsSync(path.join(root, asset)), `missing runtime asset: ${asset}`);
}
const referenceFiles = readdirSync(path.join(root, "assets/reference/onepiece-test"), { recursive: true }).filter((name) => !String(name).endsWith(".gitkeep"));
if (process.env.NODE_ENV === "production") {
  assert.equal(referenceFiles.length, 0, "reference test assets cannot be present in production validation");
}

const html = await readFile(path.join(root, "index.html"), "utf8");
assert.match(html, /rel="manifest"/, "index must link a web app manifest");
assert.match(html, /deviceStatus/, "index must expose device status UI");

const manifest = JSON.parse(await readFile(path.join(root, "app.webmanifest"), "utf8"));
assert.equal(manifest.name, "Pixel Fruit Arena");
assert.ok(manifest.start_url, "manifest needs start_url");
assert.ok(manifest.display, "manifest needs display mode");

const serviceWorker = await readFile(path.join(root, "sw.js"), "utf8");
assert.match(serviceWorker, /CACHE_NAME/, "service worker needs a named cache");
assert.match(serviceWorker, /fetch/, "service worker needs fetch handling");

for (const fruitId of Object.keys(FRUITS)) {
  const attacker = createTestFighter(0, fruitId, 300, 230);
  const defender = createTestFighter(1, "flame", 340, 230);
  attacker.invulnerable = 0;
  defender.invulnerable = 0;
  for (const ability of FRUITS[fruitId].abilities) {
    defender.damage = 0;
    defender.hitstun = 0;
    defender.x = attacker.x + 40;
    defender.y = attacker.y;
    attacker.cooldowns = {};
    const events = [];
    applyAttack(attacker, [defender], ability, events);
    assert.ok(events.some((event) => event.type === "attack"), `${fruitId}/${ability.id} must emit attack event`);
    assert.ok(defender.damage > 0, `${fruitId}/${ability.id} must damage a nearby target`);
  }
}

const match = createMatch({
  stage: SKY_RUINS,
  fruits: FRUITS,
  players: [
    { slot: 0, character: createCharacter({ name: "P1", ownedFruits: Object.keys(FRUITS), equippedFruit: "flame" }), fruitId: "flame" },
    { slot: 1, character: createCharacter({ name: "P2", ownedFruits: Object.keys(FRUITS), equippedFruit: "volt" }), fruitId: "volt" }
  ]
});

let snapshot = match.snapshot();
assert.equal(snapshot.fighters.length, 2, "2P match should create two fighters");
snapshot.fighters[0].invulnerable = 0;
snapshot.fighters[1].invulnerable = 0;
snapshot.fighters[0].x = 300;
snapshot.fighters[0].y = 230;
snapshot.fighters[1].x = 340;
snapshot.fighters[1].y = 230;
match.update(0.016, [{ slot: 0, type: "attack", index: 0 }]);
snapshot = match.snapshot();
assert.ok(snapshot.events.some((event) => event.type === "attack"), "match update should emit attack events");
assert.ok(snapshot.fighters[1].damage > 0, "match attack should damage opponent");

const ringout = snapshot.fighters[1];
ringout.x = SKY_RUINS.bounds.right + 1;
ringout.y = 230;
assert.equal(checkRingOut(ringout, SKY_RUINS), true, "fighter outside bounds should ring out");
assert.equal(ringout.stocks, 2, "ring-out should remove one stock");

snapshot.fighters[1].stocks = 0;
assert.equal(match.isComplete(), true, "match should complete when one fighter remains");

console.log("Tests passed: fruits, stage, character manifest, PWA shell, service worker, runtime fruit attacks, match combat, ring-outs, completion, release guard.");

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
    jumps: 2,
    grounded: false,
    hitstun: 0,
    invulnerable: 0,
    awakening: 0,
    awakened: 0,
    cooldowns: {},
    animTime: 0,
    attackFlash: 0,
    attackKind: "attack",
    state: "idle",
    spriteKey: "pink",
    ai: false
  };
}
