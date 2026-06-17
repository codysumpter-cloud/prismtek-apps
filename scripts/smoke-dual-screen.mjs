#!/usr/bin/env node
// smoke-dual-screen.mjs
// Quick smoke test: verifies that DS homebrew source directories exist for
// core games. Does not validate the full source receipt (use dual-screen:validate
// for the thorough check).

import assert from "node:assert/strict";
import { existsSync } from "node:fs";
import path from "node:path";

const root = path.resolve(import.meta.dirname, "..");

const coreGames = [
  "games/pixel-fruit-arena",
  "games/spin-street-showdown",
  "games/tamernet-battle-sandbox",
];

console.log("Dual-screen smoke test...\n");

for (const game of coreGames) {
  const dsDir = path.join(root, game, "ds-homebrew");
  assert.ok(existsSync(dsDir), `${game}: missing ds-homebrew/ directory`);

  const source = path.join(dsDir, "source");
  assert.ok(existsSync(source), `${game}: missing ds-homebrew/source/`);

  const makefile = path.join(dsDir, "Makefile");
  assert.ok(existsSync(makefile), `${game}: missing ds-homebrew/Makefile`);

  console.log(`  ✓ ${game}`);
}

console.log("\nDual-screen smoke test passed.");
