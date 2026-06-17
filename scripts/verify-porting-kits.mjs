#!/usr/bin/env node
// verify-porting-kits.mjs
// Verifies that porting kit dependencies are present under tools/porting-kits/.
// When PORTING_KITS entries are added to download-porting-kits.mjs, mirror them here.

import assert from "node:assert/strict";
import { existsSync } from "node:fs";
import path from "node:path";

const root = path.resolve(import.meta.dirname, "..");
const kitDir = path.join(root, "tools", "porting-kits");

// Mirror entries from download-porting-kits.mjs.
// Each entry: { id, requiredPaths: [...relative paths inside kitDir] }
const PORTING_KITS = [
  // Example:
  // { id: "libnds", requiredPaths: ["libnds/include/nds.h"] },
];

assert.ok(existsSync(kitDir), `tools/porting-kits/ directory is missing — run porting-kits:download first`);
console.log(`  ✓ tools/porting-kits/ directory exists`);

if (PORTING_KITS.length === 0) {
  console.log("porting-kits:verify — no kits configured yet, nothing to verify.");
} else {
  for (const kit of PORTING_KITS) {
    for (const rel of kit.requiredPaths) {
      const full = path.join(kitDir, rel);
      assert.ok(existsSync(full), `${kit.id}: missing ${rel} — run porting-kits:download`);
    }
    console.log(`  ✓ ${kit.id}`);
  }
}

console.log("Porting kits verified.");
