import assert from "node:assert/strict";
import { existsSync } from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

import { ASSET_CATALOG, approvedCatalogEntries, bodyIds, catalogEntries, clothingStyleIds, hairStyleIds, runtimeCatalogEntries } from "../src/assets/assetCatalog.js";

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");

assert.ok(ASSET_CATALOG.schemaVersion >= 1);
assert.ok(bodyIds(["male_basic", "female_basic"]).includes("male_basic"));
assert.ok(bodyIds(["male_basic", "female_basic"]).includes("female_basic"));
assert.ok(hairStyleIds(["crest", "bob", "spikes", "cap", "long", "ponytail", "mohawk", "hood"]).length >= 8);
assert.ok(clothingStyleIds(["runner", "jacket", "hoodie", "armor", "robe", "skirt", "gi", "coat"]).length >= 8);
assert.ok(catalogEntries("bodies").length >= approvedCatalogEntries("bodies").length);
assert.ok(catalogEntries("vfx").length >= runtimeCatalogEntries("vfx").length);

for (const category of ["bodies", "vfx", "tilesets", "stageBackgrounds", "weapons", "items", "props", "ui"]) {
  for (const entry of catalogEntries(category)) {
    assert.ok(entry.status === "approved" || entry.status === "discovered", `${category}/${entry.id} needs a review status`);
    if (entry.status !== "approved") {
      assert.equal(entry.runtimeReady, false, `${category}/${entry.id} must not be runtime-ready before approval`);
      assert.equal(entry.usable, false, `${category}/${entry.id} must not be usable before approval`);
    }
    if (entry.status === "approved") {
      assert.equal(entry.runtimeReady, true, `${category}/${entry.id} approved assets must be runtime-ready`);
      assert.notEqual(entry.usable, false, `${category}/${entry.id} approved assets must be usable`);
    }
    if (entry.path) assert.ok(existsSync(path.join(root, entry.path)), `catalog entry missing file: ${category}/${entry.id} -> ${entry.path}`);
  }
}

console.log("Asset catalog validation passed with curated runtime gating.");
