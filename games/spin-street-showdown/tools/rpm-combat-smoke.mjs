import assert from "node:assert/strict";
import { execFileSync } from "node:child_process";
import { readFileSync } from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const root = path.resolve(__dirname, "..");
const html = readFileSync(path.join(root, "index.html"), "utf8");
const upgradePath = path.join(root, "physics-first-upgrade.js");
const upgrade = readFileSync(upgradePath, "utf8");
const readme = readFileSync(path.join(root, "README.md"), "utf8");

execFileSync(process.execPath, ["--check", upgradePath], { stdio: "inherit" });

for (const token of ["rpm", "timer", "physics-first-upgrade.js", "Spirit Surge"]) {
  assert.ok(html.includes(token), `index.html should include ${token}`);
}

for (const token of ["ROUND_SECONDS", "RPM_MAX", "drainRPM", "resolveTimedRound", "createSlashArc", "drawRPMMeter", "drawRoundClock"]) {
  assert.ok(upgrade.includes(token), `physics-first-upgrade.js should include ${token}`);
}

for (const token of ["applyDomePitchPhysics", "domeKinematics", "radialSpeed", "tangentialSpeed", "UPHILL_DRAG", "DOWNHILL_BOOST", "applyDriverPatternControl", "playerIntentVector"]) {
  assert.ok(upgrade.includes(token), `physics-first-upgrade.js should include dome or pattern token ${token}`);
}

for (const token of ["BIT_BEASTS", "applyArchetypeMultipliers", "buildStyleProfile", "defenseStyle", "staminaStyle", "applyBitBeastPassive", "applyBitBeastActive", "installPvpDiversityLoadouts"]) {
  assert.ok(upgrade.includes(token), `physics-first-upgrade.js should include build diversity token ${token}`);
}

for (const token of ["RPM", "40-second", "timeout", "slash", "pitch", "driver tip", "Defense", "Stamina", "Bit Beast", "passive", "usable ability"]) {
  assert.match(readme, new RegExp(token, "i"), `README should document ${token}`);
}

console.log("Spin Street RPM combat smoke passed.");
