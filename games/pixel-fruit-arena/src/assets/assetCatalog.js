import { GENERATED_ASSET_CATALOG } from "./generatedAssetCatalog.js";

export const ASSET_CATALOG = GENERATED_ASSET_CATALOG;

export function catalogEntries(category) {
  return ASSET_CATALOG.categories?.[category] || [];
}

export function approvedCatalogEntries(category) {
  return catalogEntries(category).filter((entry) => entry.status === "approved" && entry.runtimeReady === true && entry.usable !== false);
}

export function discoveredCatalogEntries(category) {
  return catalogEntries(category).filter((entry) => entry.status !== "approved");
}

export function runtimeCatalogEntries(category) {
  return approvedCatalogEntries(category);
}

export function catalogIds(category) {
  return runtimeCatalogEntries(category).map((entry) => entry.id);
}

export function entriesForSlot(slot) {
  const results = [];
  for (const entries of Object.values(ASSET_CATALOG.categories || {})) {
    for (const entry of entries) {
      if (entry.slot === slot && entry.status === "approved" && entry.runtimeReady === true && entry.usable !== false) results.push(entry);
    }
  }
  return results;
}

export function bodyIds(fallback = []) {
  const ids = catalogIds("bodies");
  return ids.length ? ids : fallback;
}

export function hairStyleIds(fallback = []) {
  const ids = catalogIds("hair");
  return ids.length ? ids : fallback;
}

export function clothingStyleIds(fallback = []) {
  const ids = catalogIds("clothing");
  return ids.length ? ids : fallback;
}

export function vfxByFamily(family) {
  return runtimeCatalogEntries("vfx").filter((entry) => entry.family === family || entry.tags?.includes(family));
}

export function stageBackgrounds() {
  return runtimeCatalogEntries("stageBackgrounds");
}

export function assetCatalogSummary() {
  return Object.fromEntries(Object.entries(ASSET_CATALOG.categories || {}).map(([category, entries]) => [category, entries.length]));
}

export function approvalSummary() {
  const rows = Object.entries(ASSET_CATALOG.categories || {}).map(([category, entries]) => {
    const approved = entries.filter((entry) => entry.status === "approved" && entry.runtimeReady === true && entry.usable !== false).length;
    return [category, { discovered: entries.length, approved }];
  });
  return Object.fromEntries(rows);
}
