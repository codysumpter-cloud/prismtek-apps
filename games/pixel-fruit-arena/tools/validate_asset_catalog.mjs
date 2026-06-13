import assert from "node:assert/strict";
import { existsSync } from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

import { ASSET_CATALOG, bodyIds, clothingStyleIds, hairStyleIds, usableCatalogEntries } from "../src/assets/assetCatalog.js";

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");

assert.equal(ASSET_CATALOG.schemaVersion, 1);
assert.ok(bodyIds().includes("male_basic"));
assert.ok(bodyIds().includes("female_basic"));
assert.ok(hairStyleIds().length >= 8);
assert.ok(clothingStyleIds().length >= 8);
assert.ok(usableCatalogEntries("vfx").length >= 8);
assert.ok(usableCatalogEntries("tilesets").length >= 1);

for (const category of ["bodies", "vfx", "tilesets"]) {
  for (const entry of usableCatalogEntries(category)) {
    if (!entry.path) continue;
    assert.ok(existsSync(path.join(root, entry.path)), `catalog entry missing file: ${category}/${entry.id} -> ${entry.path}`);
  }
}

console.log("Asset catalog validation passed.");
