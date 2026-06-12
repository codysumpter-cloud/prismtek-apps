import { readFile } from "node:fs/promises";
import assert from "node:assert/strict";
import path from "node:path";
import { fileURLToPath } from "node:url";

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");

const fruits = JSON.parse(await readFile(path.join(root, "data/fruits/fruits.json"), "utf8"));
assert.equal(fruits.length, 6, "six fruits are required");
for (const fruit of fruits) {
  assert.equal(fruit.abilities.length, 3, `${fruit.id} must have three abilities`);
  assert.ok(fruit.awakening, `${fruit.id} needs awakening`);
}

const stage = JSON.parse(await readFile(path.join(root, "data/stages/sky_ruins.json"), "utf8"));
assert.ok(stage.platforms.length >= 3, "stage needs multiple platforms");
assert.ok(stage.respawns.length >= 4, "stage needs four respawn points");

const character = JSON.parse(await readFile(path.join(root, "assets/characters/prismtek_placeholder_character.json"), "utf8"));
assert.equal(character.sprite_width, 64);
assert.equal(character.sprite_height, 64);
assert.equal(character.animations.length, 10);
assert.equal(process.env.USE_REFERENCE_TEST_ASSETS === "true" && process.env.NODE_ENV === "production", false, "reference assets cannot be used in production");

const html = await readFile(path.join(root, "index.html"), "utf8");
assert.match(html, /rel="manifest"/, "index must link a web app manifest");
assert.match(html, /deviceStatus/, "index must expose device status UI");

const manifest = JSON.parse(await readFile(path.join(root, "manifest.json"), "utf8"));
assert.equal(manifest.name, "Pixel Fruit Arena");
assert.ok(manifest.start_url, "manifest needs start_url");
assert.ok(manifest.display, "manifest needs display mode");

const serviceWorker = await readFile(path.join(root, "sw.js"), "utf8");
assert.match(serviceWorker, /CACHE_NAME/, "service worker needs a named cache");
assert.match(serviceWorker, /fetch/, "service worker needs fetch handling");

console.log("Tests passed: fruits, stage, character manifest, PWA shell, service worker, release guard.");
