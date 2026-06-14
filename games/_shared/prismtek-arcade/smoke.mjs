import assert from "node:assert/strict";
import { existsSync, readFileSync } from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const gameDir = process.argv[2] ? path.resolve(process.argv[2]) : process.cwd();
const indexPath = path.join(gameDir, "index.html");
const packagePath = path.join(gameDir, "package.json");

assert.ok(existsSync(indexPath), `missing index.html in ${gameDir}`);
assert.ok(existsSync(packagePath), `missing package.json in ${gameDir}`);

const html = readFileSync(indexPath, "utf8");
assert.match(html, /id="game-root"/, "index.html must include game-root mount point");
assert.match(html, /arcade-core\.js/, "index.html must import the shared arcade runtime");
assert.match(html, /createArcadeGame/, "index.html must boot a playable game");

const pkg = JSON.parse(readFileSync(packagePath, "utf8"));
assert.ok(pkg.scripts?.dev, "package.json must define dev script");
assert.ok(pkg.scripts?.test, "package.json must define test script");

console.log(`Arcade smoke passed: ${path.basename(gameDir)}`);
