import { GENERATED_ASSET_CATALOG } from "./generatedAssetCatalog.js";

export const ASSET_CATALOG = GENERATED_ASSET_CATALOG;

export function catalogEntries(category) {
  return ASSET_CATALOG.categories?.[category] || [];
}

export function usableCatalogEntries(category) {
  return catalogEntries(category).filter((entry) => entry.usable !== false);
}

export function catalogIds(category) {
  return usableCatalogEntries(category).map((entry) => entry.id);
}

export function entriesForSlot(slot) {
  const results = [];
  for (const entries of Object.values(ASSET_CATALOG.categories || {})) {
    for (const entry of entries) {
      if (entry.slot === slot && entry.usable !== false) results.push(entry);
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
  return usableCatalogEntries("vfx").filter((entry) => entry.family === family || entry.tags?.includes(family));
}

export function stageBackgrounds() {
  return usableCatalogEntries("stageBackgrounds");
}

export function assetCatalogSummary() {
  return Object.fromEntries(Object.entries(ASSET_CATALOG.categories || {}).map(([category, entries]) => [category, entries.length]));
}
