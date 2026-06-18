import type {
  LoadedPrismcadeAssetRow,
  PrismcadeAssetFamily,
  PrismcadeAssetRegistry,
} from "./assetRegistry";

export type PrismcadeAssetBrowserSort = "family" | "name" | "status" | "sourcePath";

export interface PrismcadeAssetBrowserFilters {
  family?: PrismcadeAssetFamily | "all";
  viewMode?: string | "all";
  status?: string | "all";
  role?: string | "all";
  search?: string;
  usableOnly?: boolean;
  includeLocked?: boolean;
  sortBy?: PrismcadeAssetBrowserSort;
}

export interface PrismcadeAssetBrowserCard {
  id: string;
  family: PrismcadeAssetFamily;
  displayName: string;
  sourcePath: string;
  status: string;
  licenseStatus: string;
  views: string[];
  roles: string[];
  tags: string[];
  type?: string;
  size?: string;
  locked: boolean;
  lockReason?: string;
  sourceRow: LoadedPrismcadeAssetRow;
}

export interface PrismcadeAssetBrowserTab {
  id: PrismcadeAssetFamily;
  label: string;
  count: number;
  usableCount: number;
  lockedCount: number;
}

export interface PrismcadeAssetBrowserModel {
  tabs: PrismcadeAssetBrowserTab[];
  cards: PrismcadeAssetBrowserCard[];
  totalCount: number;
  visibleCount: number;
  usableCount: number;
  lockedCount: number;
  filters: Required<Omit<PrismcadeAssetBrowserFilters, "search">> & { search: string };
}

const FAMILY_ORDER: PrismcadeAssetFamily[] = ["characters", "vfx", "worlds", "items", "ui", "audio"];
const FAMILY_LABELS: Record<PrismcadeAssetFamily, string> = {
  characters: "Characters",
  vfx: "VFX",
  worlds: "Worlds",
  items: "Items",
  ui: "UI",
  audio: "Audio",
};
const USABLE_STATUSES = new Set(["template_ready", "playtest_ready", "game_ready"]);
const LOCKED_STATUSES = new Set(["reference_only", "blocked_license", "partial_download_do_not_ship"]);
const LOCKED_LICENSES = new Set(["unknown_do_not_ship", "external_reference_only"]);

function unique(values: Array<string | undefined>): string[] {
  return [...new Set(values.filter(Boolean) as string[])].sort();
}

function isUsable(row: LoadedPrismcadeAssetRow): boolean {
  return USABLE_STATUSES.has(row.effectiveStatus) && !LOCKED_LICENSES.has(row.effectiveLicenseStatus);
}

function lockReason(row: LoadedPrismcadeAssetRow): string | undefined {
  if (LOCKED_STATUSES.has(row.effectiveStatus)) return `Status is ${row.effectiveStatus}.`;
  if (LOCKED_LICENSES.has(row.effectiveLicenseStatus)) return `License status is ${row.effectiveLicenseStatus}.`;
  if (!USABLE_STATUSES.has(row.effectiveStatus)) return `Needs promotion from ${row.effectiveStatus}.`;
  return undefined;
}

function toCard(row: LoadedPrismcadeAssetRow): PrismcadeAssetBrowserCard {
  const reason = lockReason(row);
  return {
    id: row.id,
    family: row.family,
    displayName: row.effectiveDisplayName,
    sourcePath: row.sourcePath,
    status: row.effectiveStatus,
    licenseStatus: row.effectiveLicenseStatus,
    views: row.effectiveViews,
    roles: row.roles ?? [],
    tags: row.tags ?? [],
    type: row.type ?? row.kind,
    size: row.size,
    locked: Boolean(reason),
    lockReason: reason,
    sourceRow: row,
  };
}

function normalizeFilters(filters: PrismcadeAssetBrowserFilters = {}): PrismcadeAssetBrowserModel["filters"] {
  return {
    family: filters.family ?? "all",
    viewMode: filters.viewMode ?? "all",
    status: filters.status ?? "all",
    role: filters.role ?? "all",
    search: filters.search?.trim() ?? "",
    usableOnly: filters.usableOnly ?? false,
    includeLocked: filters.includeLocked ?? true,
    sortBy: filters.sortBy ?? "family",
  };
}

function matchesSearch(card: PrismcadeAssetBrowserCard, search: string): boolean {
  if (!search) return true;
  const haystack = [card.id, card.displayName, card.family, card.sourcePath, card.status, card.licenseStatus, card.type, ...card.views, ...card.roles, ...card.tags]
    .join(" ")
    .toLowerCase();
  return haystack.includes(search.toLowerCase());
}

function sortCards(cards: PrismcadeAssetBrowserCard[], sortBy: PrismcadeAssetBrowserSort): PrismcadeAssetBrowserCard[] {
  return [...cards].sort((left, right) => {
    if (sortBy === "family") {
      const familyDelta = FAMILY_ORDER.indexOf(left.family) - FAMILY_ORDER.indexOf(right.family);
      if (familyDelta !== 0) return familyDelta;
      return left.displayName.localeCompare(right.displayName);
    }
    return String(left[sortBy]).localeCompare(String(right[sortBy]));
  });
}

export function buildPrismcadeAssetBrowser(
  registry: PrismcadeAssetRegistry,
  filters: PrismcadeAssetBrowserFilters = {},
): PrismcadeAssetBrowserModel {
  const normalized = normalizeFilters(filters);
  const allCards = registry.rows.map(toCard);
  const cards = sortCards(allCards.filter((card) => {
    if (normalized.family !== "all" && card.family !== normalized.family) return false;
    if (normalized.viewMode !== "all" && card.views.length > 0 && !card.views.includes(normalized.viewMode)) return false;
    if (normalized.status !== "all" && card.status !== normalized.status) return false;
    if (normalized.role !== "all" && !card.roles.includes(normalized.role)) return false;
    if (normalized.usableOnly && !isUsable(card.sourceRow)) return false;
    if (!normalized.includeLocked && card.locked) return false;
    return matchesSearch(card, normalized.search);
  }), normalized.sortBy);

  const tabs = FAMILY_ORDER.map((family) => {
    const familyCards = allCards.filter((card) => card.family === family);
    return {
      id: family,
      label: FAMILY_LABELS[family],
      count: familyCards.length,
      usableCount: familyCards.filter((card) => isUsable(card.sourceRow)).length,
      lockedCount: familyCards.filter((card) => card.locked).length,
    };
  });

  return {
    tabs,
    cards,
    totalCount: allCards.length,
    visibleCount: cards.length,
    usableCount: allCards.filter((card) => isUsable(card.sourceRow)).length,
    lockedCount: allCards.filter((card) => card.locked).length,
    filters: normalized,
  };
}

export function getAssetBrowserFilterOptions(registry: PrismcadeAssetRegistry) {
  return {
    families: FAMILY_ORDER.filter((family) => registry.rows.some((row) => row.family === family)),
    viewModes: unique(registry.rows.flatMap((row) => row.effectiveViews)),
    statuses: unique(registry.rows.map((row) => row.effectiveStatus)),
    roles: unique(registry.rows.flatMap((row) => row.roles ?? [])),
  };
}
