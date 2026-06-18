/**
 * Prismcade Asset Row Registry Runtime
 *
 * This module loads the data-only asset row files created for the Prismcade
 * creator library and provides small query helpers for games and UI screens.
 */

export type PrismcadeAssetFamily =
  | "characters"
  | "vfx"
  | "worlds"
  | "items"
  | "ui"
  | "audio";

export type PrismcadeAssetStatus =
  | "candidate"
  | "reference_only"
  | "template_ready"
  | "playtest_ready"
  | "game_ready"
  | "needs_manifest"
  | "needs_cleanup"
  | string;

export type PrismcadeAssetLicenseStatus =
  | "first_party"
  | "first_party_generated"
  | "mixed_needs_per_pack_review"
  | "user_provided_needs_review"
  | "external_reference_only"
  | "unknown_do_not_ship"
  | string;

export interface PrismcadeAssetRow {
  id: string;
  name?: string;
  displayName?: string;
  sourcePath: string;
  type?: string;
  kind?: string;
  size?: string;
  views?: string[];
  viewModes?: string[];
  roles?: string[];
  tags?: string[];
  licenseStatus?: PrismcadeAssetLicenseStatus;
  status?: PrismcadeAssetStatus;
  prismcadeStatus?: PrismcadeAssetStatus;
  [key: string]: unknown;
}

export interface PrismcadeAssetRowFile {
  schemaVersion: string;
  sourceInventory?: string;
  sourceInventories?: string[];
  summary?: Record<string, unknown>;
  defaultLicenseStatus?: PrismcadeAssetLicenseStatus;
  entries?: PrismcadeAssetRow[];
  priorityRows?: PrismcadeAssetRow[];
  categories?: PrismcadeAssetRow[];
}

export interface LoadedPrismcadeAssetRow extends PrismcadeAssetRow {
  family: PrismcadeAssetFamily;
  registryPath: string;
  effectiveStatus: PrismcadeAssetStatus;
  effectiveLicenseStatus: PrismcadeAssetLicenseStatus;
  effectiveViews: string[];
  effectiveDisplayName: string;
}

export interface PrismcadeAssetRegistry {
  rows: LoadedPrismcadeAssetRow[];
  files: Partial<Record<PrismcadeAssetFamily, PrismcadeAssetRowFile>>;
}

export interface LoadPrismcadeAssetRowsOptions {
  baseUrl?: string;
  fetchImpl?: typeof fetch;
  registryPaths?: Partial<Record<PrismcadeAssetFamily, string>>;
}

const DEFAULT_REGISTRY_PATHS: Record<PrismcadeAssetFamily, string> = {
  characters: "data/prismcade/asset-rows/character-assets.json",
  vfx: "data/prismcade/asset-rows/vfx-assets.json",
  worlds: "data/prismcade/asset-rows/world-assets.json",
  items: "data/prismcade/asset-rows/item-assets.json",
  ui: "data/prismcade/asset-rows/ui-assets.json",
  audio: "data/prismcade/asset-rows/audio-assets.json",
};

function trimSlashes(value: string): string {
  return value.replace(/^\/+|\/+$/g, "");
}

function joinUrl(...parts: string[]): string {
  return parts
    .filter(Boolean)
    .map((part, index) => index === 0 ? part.replace(/\/+$/g, "") : trimSlashes(part))
    .join("/");
}

async function fetchJson<T>(fetchImpl: typeof fetch, url: string): Promise<T> {
  const response = await fetchImpl(url);
  if (!response.ok) {
    throw new Error(`Failed to fetch ${url}: ${response.status} ${response.statusText}`);
  }
  return response.json() as Promise<T>;
}

function rowsFromFile(file: PrismcadeAssetRowFile): PrismcadeAssetRow[] {
  return [
    ...(file.entries ?? []),
    ...(file.priorityRows ?? []),
    ...(file.categories ?? []),
  ];
}

function normalizeRow(
  family: PrismcadeAssetFamily,
  registryPath: string,
  file: PrismcadeAssetRowFile,
  row: PrismcadeAssetRow,
): LoadedPrismcadeAssetRow {
  const effectiveStatus = row.prismcadeStatus ?? row.status ?? "candidate";
  const effectiveLicenseStatus = row.licenseStatus ?? file.defaultLicenseStatus ?? "mixed_needs_per_pack_review";
  const effectiveViews = row.viewModes ?? row.views ?? [];
  const effectiveDisplayName = row.displayName ?? row.name ?? row.id;

  return {
    ...row,
    family,
    registryPath,
    effectiveStatus,
    effectiveLicenseStatus,
    effectiveViews,
    effectiveDisplayName,
  };
}

export async function loadPrismcadeAssetRows(
  options: LoadPrismcadeAssetRowsOptions = {},
): Promise<PrismcadeAssetRegistry> {
  const fetchImpl = options.fetchImpl ?? fetch;
  const baseUrl = options.baseUrl ?? "";
  const registryPaths = { ...DEFAULT_REGISTRY_PATHS, ...(options.registryPaths ?? {}) };
  const files: Partial<Record<PrismcadeAssetFamily, PrismcadeAssetRowFile>> = {};
  const rows: LoadedPrismcadeAssetRow[] = [];

  for (const family of Object.keys(registryPaths) as PrismcadeAssetFamily[]) {
    const registryPath = registryPaths[family];
    const file = await fetchJson<PrismcadeAssetRowFile>(fetchImpl, joinUrl(baseUrl, registryPath));
    files[family] = file;

    for (const row of rowsFromFile(file)) {
      rows.push(normalizeRow(family, registryPath, file, row));
    }
  }

  return { rows, files };
}

export function getAssetsByFamily(
  registry: PrismcadeAssetRegistry,
  family: PrismcadeAssetFamily,
): LoadedPrismcadeAssetRow[] {
  return registry.rows.filter((row) => row.family === family);
}

export function getAssetsByViewMode(
  registry: PrismcadeAssetRegistry,
  viewMode: string,
): LoadedPrismcadeAssetRow[] {
  return registry.rows.filter((row) => row.effectiveViews.includes(viewMode));
}

export function getAssetsByStatus(
  registry: PrismcadeAssetRegistry,
  status: PrismcadeAssetStatus,
): LoadedPrismcadeAssetRow[] {
  return registry.rows.filter((row) => row.effectiveStatus === status);
}

export function getAssetsByRole(
  registry: PrismcadeAssetRegistry,
  role: string,
): LoadedPrismcadeAssetRow[] {
  return registry.rows.filter((row) => row.roles?.includes(role));
}

export function getUsableCreatorAssets(registry: PrismcadeAssetRegistry): LoadedPrismcadeAssetRow[] {
  const usableStatuses = new Set(["template_ready", "playtest_ready", "game_ready"]);
  const blockedLicenseStatuses = new Set(["unknown_do_not_ship", "external_reference_only"]);

  return registry.rows.filter((row) => (
    usableStatuses.has(row.effectiveStatus) && !blockedLicenseStatuses.has(row.effectiveLicenseStatus)
  ));
}

export function getCandidateAssetsForGame(
  registry: PrismcadeAssetRegistry,
  options: { viewMode?: string; family?: PrismcadeAssetFamily; role?: string } = {},
): LoadedPrismcadeAssetRow[] {
  return registry.rows.filter((row) => {
    if (options.family && row.family !== options.family) return false;
    if (options.viewMode && row.effectiveViews.length > 0 && !row.effectiveViews.includes(options.viewMode)) return false;
    if (options.role && !row.roles?.includes(options.role)) return false;
    return row.effectiveStatus !== "reference_only" && row.effectiveLicenseStatus !== "unknown_do_not_ship";
  });
}
