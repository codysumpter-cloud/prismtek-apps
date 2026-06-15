import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import path from "node:path";

const root = path.resolve(path.dirname(new URL(import.meta.url).pathname), "..");
const game = readFileSync(path.join(root, "game.js"), "utf8");
const readme = readFileSync(path.join(root, "README.md"), "utf8");

for (const token of [
  "resolveTopCollision",
  "applyDomePhysics",
  "drawPremiumTop",
  "drawShockwave",
  "createImpact",
  "stability",
  "trail",
  "Spirit Surge"
]) {
  assert.match(game, new RegExp(token), `game.js must include ${token}`);
}

assert.match(readme, /physics/i, "README should describe upgraded physics");
assert.match(readme, /graphics/i, "README should describe upgraded graphics");
assert.match(readme, /Spirit Surge/i, "README should document Spirit Surge mechanics");

console.log("Spin Street quality smoke passed.");
