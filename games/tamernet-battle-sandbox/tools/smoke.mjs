import assert from "node:assert/strict";
import { existsSync, readFileSync } from "node:fs";
import path from "node:path";

const root = path.resolve(path.dirname(new URL(import.meta.url).pathname), "..");
const indexPath = path.join(root, "index.html");
const packagePath = path.join(root, "package.json");
const mainPath = path.join(root, "src", "main.js");
const stylesPath = path.join(root, "styles.css");

assert.ok(existsSync(indexPath), "missing index.html");
assert.ok(existsSync(packagePath), "missing package.json");
assert.ok(existsSync(mainPath), "missing src/main.js");
assert.ok(existsSync(stylesPath), "missing styles.css");

const html = readFileSync(indexPath, "utf8");
const main = readFileSync(mainPath, "utf8");
const pkg = JSON.parse(readFileSync(packagePath, "utf8"));

assert.match(html, /<canvas[^>]+id="game"/, "index.html must expose the game canvas");
assert.match(html, /type="module"[^>]+src="\.\/src\/main\.js"/, "index.html must load src/main.js as an ES module");
assert.match(html, /Combat Log|Controls|Alpha mode/, "index.html must expose player-facing controls and battle notes");
assert.match(main, /requestAnimationFrame/, "runtime must drive a browser game loop");
assert.match(main, /addEventListener\(["']keydown/, "runtime must handle keyboard input");
assert.match(main, /capture/i, "runtime must keep the capture mechanic wired");
assert.match(main, /alpha/i, "runtime must keep alpha encounter support wired");
assert.ok(pkg.scripts?.dev, "package.json must define dev");
assert.ok(pkg.scripts?.test, "package.json must define test");
assert.ok(pkg.scripts?.["package:zip"], "package.json must define package:zip");

console.log("TamerNet browser smoke passed.");
