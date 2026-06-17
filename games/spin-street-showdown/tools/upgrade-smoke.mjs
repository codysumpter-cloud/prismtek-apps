import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import path from "node:path";

const root = path.resolve(path.dirname(new URL(import.meta.url).pathname), "..");
const index = readFileSync(path.join(root, "index.html"), "utf8");
const runtime = readFileSync(path.join(root, "bit-beast-upgrades.js"), "utf8");

assert.match(index, /physics-first-upgrade\.js/);
assert.match(index, /bit-beast-upgrades\.js/);
assert.match(runtime, /Bit Beast/);
assert.match(runtime, /Astral Lynx/);
assert.match(runtime, /Chrome Wyvern/);
assert.match(runtime, /drawBeast/);
assert.match(runtime, /summonSpiritSurge/);
assert.match(runtime, /resolveTopCollision/);

console.log("Spin Street Bit Beast upgrade smoke passed.");
