#!/usr/bin/env node
// download-porting-kits.mjs
// Downloads third-party porting kit dependencies into tools/porting-kits/.
// Currently a no-op stub — porting kit sources are not yet configured.
// When kits are ready, add download entries to PORTING_KITS below.

import { mkdirSync } from "node:fs";
import path from "node:path";

const root = path.resolve(import.meta.dirname, "..");
const kitDir = path.join(root, "tools", "porting-kits");

// Registry of porting kits to download.
// Each entry: { id, description, url }
// Leave empty until kits are sourced.
const PORTING_KITS = [
  // Example:
  // { id: "libnds", description: "devkitPro libnds headers", url: "https://..." },
];

mkdirSync(kitDir, { recursive: true });

if (PORTING_KITS.length === 0) {
  console.log("porting-kits:download — no kits configured yet.");
  console.log(`Kit directory: ${kitDir}`);
  console.log("Add entries to PORTING_KITS in scripts/download-porting-kits.mjs when ready.");
} else {
  for (const kit of PORTING_KITS) {
    console.log(`Downloading ${kit.id}: ${kit.description}`);
    // TODO: implement fetch + unpack for each kit
  }
}

console.log("Done.");
