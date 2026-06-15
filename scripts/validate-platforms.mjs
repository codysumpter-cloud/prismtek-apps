#!/usr/bin/env node
// validate-platforms.mjs
// Checks that key platform build targets are configured correctly.

import assert from "node:assert/strict";
import { existsSync } from "node:fs";
import path from "node:path";

const root = path.resolve(import.meta.dirname, "..");

function check(label, ...paths) {
  for (const p of paths) {
    const full = path.join(root, p);
    assert.ok(existsSync(full), `${label}: missing ${p}`);
  }
  console.log(`  ✓ ${label}`);
}

console.log("Validating platform build targets...\n");

// Web app (Vite)
check(
  "Web app (apps/web)",
  "apps/web/package.json",
  "apps/web/vite.config.ts",
  "apps/web/src"
);

// macOS app (Vite + Express gateway)
check(
  "macOS app (apps/bemore-macos)",
  "apps/bemore-macos/package.json",
  "apps/bemore-macos/vite.config.ts",
  "apps/bemore-macos/src"
);

// iOS native (Xcode project)
check(
  "iOS native (apps/bemore-ios-native)",
  "apps/bemore-ios-native/BeMoreAgent.xcodeproj"
);

// PrismDS OS (Nintendo DS / RGDS configs)
check(
  "PrismDS OS (apps/prismds-os)",
  "apps/prismds-os/README.md",
  "apps/prismds-os/configs"
);

// Core game web builds
const coreGames = [
  "games/pixel-fruit-arena",
  "games/spin-street-showdown",
  "games/tamernet-battle-sandbox",
];
for (const game of coreGames) {
  check(`Core game web build (${game})`, `${game}/package.json`, `${game}/README.md`);
}

// Shared arcade library
check(
  "Shared arcade library (games/_shared/prismtek-arcade)",
  "games/_shared/prismtek-arcade"
);

console.log("\nAll platform targets validated.");
