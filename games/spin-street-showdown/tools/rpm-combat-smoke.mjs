import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import path from "node:path";

const root = path.resolve(path.dirname(new URL(import.meta.url).pathname), "..");
const html = readFileSync(path.join(root, "index.html"), "utf8");
const upgrade = readFileSync(path.join(root, "physics-first-upgrade.js"), "utf8");
const readme = readFileSync(path.join(root, "README.md"), "utf8");

for (const token of ["rpm", "timer", "physics-first-upgrade.js", "Spirit Surge"]) {
  assert.ok(html.includes(token), `index.html should include ${token}`);
}

for (const token of ["ROUND_SECONDS", "RPM_MAX", "drainRPM", "resolveTimedRound", "createSlashArc", "drawRPMMeter", "drawRoundClock"]) {
  assert.ok(upgrade.includes(token), `physics-first-upgrade.js should include ${token}`);
}

for (const token of ["RPM", "40-second", "timeout", "slash"]) {
  assert.match(readme, new RegExp(token, "i"), `README should document ${token}`);
}

console.log("Spin Street RPM combat smoke passed.");
