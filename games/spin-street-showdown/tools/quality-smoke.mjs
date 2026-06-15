import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const root = path.resolve(__dirname, "..");
const game = readFileSync(path.join(root, "game.js"), "utf8");
const css = readFileSync(path.join(root, "style.css"), "utf8");
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

for (const token of [
  "radial-gradient",
  "box-shadow",
  "border-radius",
  "filter: saturate",
  "text-shadow",
  "backdrop",
  "scan"
]) {
  assert.match(css, new RegExp(token, "i"), `style.css must include presentation polish token: ${token}`);
}

assert.match(readme, /physics/i, "README should describe upgraded physics");
assert.match(readme, /graphics/i, "README should describe upgraded graphics");
assert.match(readme, /Spirit Surge/i, "README should document Spirit Surge mechanics");
assert.match(readme, /visual quality target/i, "README should document the visual quality target");

console.log("Spin Street quality smoke passed.");
