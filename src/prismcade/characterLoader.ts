/**
 * Prismcade Character Loader Contract
 *
 * Games should consume portable character packs through this contract instead
 * of hardcoding one character's sprite sheet layout. A pack provides a root
 * manifest plus one runtime manifest per supported sprite size.
 */

export type PrismcadeCharacterId = string;
export type PrismcadeAnimationSlot = string;
export type PrismcadeSpriteSize = 32 | 48 | 64 | 96 | 128 | 192 | 256;

export type PrismcadeCharacterView =
  | "side"
  | "top_down"
  | "low_top_down"
  | "isometric"
  | "profile"
  | "lobby";

export type PrismcadeViewMode =
  | "side"
  | "top_down"
  | "low_top_down"
  | "isometric"
  | "arena_2_5d"
  | "profile_lobby";

export interface PrismcadeVec2 {
  x: number;
  y: number;
}

export interface PrismcadeFrameRect {
  x: number;
  y: number;
  w: number;
  h: number;
}

export interface PrismcadeAtlasFrame extends PrismcadeFrameRect {
  frame: number;
  durationMs: number;
  pivot: PrismcadeVec2;
  containsProp?: boolean;
}

export interface PrismcadeAnimationClip {
  slot: PrismcadeAnimationSlot;
  frameCount: number;
  durationMs: number;
  containsProp?: boolean;
  frames: PrismcadeAtlasFrame[];
  framesDir?: string;
  strip?: string;
  gif?: string;
}

export interface PrismcadeRuntimeManifest {
  frameSize: [number, number];
  slots: Record<PrismcadeAnimationSlot, {
    frameCount: number;
    durationMs: number;
    containsProp?: boolean;
    framesDir?: string;
    strip?: string;
    gif?: string;
  }>;
  atlas: {
    image: string;
    frames: Record<PrismcadeAnimationSlot, PrismcadeAtlasFrame[]>;
  };
}

export interface PrismcadeCharacterViewVariant {
  status: "playtest" | "available" | "fallback" | "missing" | string;
  runtimeRoot?: string;
  runtimeSizes?: number[];
  defaultSize?: number;
  requiredSlotsReady?: boolean;
  sourceView?: PrismcadeCharacterView;
  fallbackSlot?: PrismcadeAnimationSlot;
  notes?: string;
}

export interface PrismcadeCharacterManifest {
  schemaVersion: "prismcade-game-ready-animation-pack-v0" | string;
  characterId: PrismcadeCharacterId;
  displayName: string;
  defaultFrameSize: [number, number];
  allowedSizes: [number, number][];
  contentPackagePath?: string;
  recommendedRuntime?: {
    frameSize: [number, number];
    atlas: string;
    manifest: string;
  };
  portableAvatarRole?: string[];
  compatibleGameViews?: string[];
  needsFutureVariants?: string[];
  viewVariants?: Partial<Record<PrismcadeCharacterView, PrismcadeCharacterViewVariant>>;
  slots: Record<PrismcadeAnimationSlot, {
    frameCount: number;
    durationMs: number;
    containsProp?: boolean;
    defaultStrip?: string;
    defaultGif?: string;
    defaultFramesDir?: string;
  }>;
  notes?: string[];
}

export interface LoadedPrismcadeCharacter {
  baseUrl: string;
  manifest: PrismcadeCharacterManifest;
  size: PrismcadeSpriteSize;
  runtime: PrismcadeRuntimeManifest;
  atlasUrl: string;
  clips: Record<PrismcadeAnimationSlot, PrismcadeAnimationClip>;
}

export interface LoadedPrismcadeCharacterForView extends LoadedPrismcadeCharacter {
  requestedViewMode: PrismcadeViewMode;
  selectedView: PrismcadeCharacterView;
  selectedVariant: PrismcadeCharacterViewVariant;
  fallbackUsed: boolean;
  fallbackReason?: string;
}

export interface LoadPrismcadeCharacterOptions {
  /** Preferred sprite size. Defaults to the manifest's default size, usually 64. */
  size?: PrismcadeSpriteSize;
  /** Use this fallback size if the preferred size is unavailable. Defaults to 64. */
  fallbackSize?: PrismcadeSpriteSize;
  /** Optional custom fetch implementation for tests or non-browser runtimes. */
  fetchImpl?: typeof fetch;
}

export interface LoadPrismcadeCharacterForViewOptions extends LoadPrismcadeCharacterOptions {
  viewMode: PrismcadeViewMode;
  /** Optional override for the view preference chain. */
  viewPreference?: PrismcadeCharacterView[];
}

const DEFAULT_FALLBACK_SIZE: PrismcadeSpriteSize = 64;

const VIEW_MODE_TO_CHARACTER_VIEW_PRIORITY: Record<PrismcadeViewMode, PrismcadeCharacterView[]> = {
  side: ["side", "profile", "lobby"],
  arena_2_5d: ["side", "profile", "lobby"],
  top_down: ["top_down", "low_top_down", "profile", "lobby"],
  low_top_down: ["low_top_down", "top_down", "profile", "lobby"],
  isometric: ["isometric", "low_top_down", "profile", "lobby"],
  profile_lobby: ["profile", "lobby", "side", "low_top_down", "top_down", "isometric"],
};

function trimTrailingSlash(value: string): string {
  return value.replace(/\/+$/, "");
}

function joinUrl(...parts: string[]): string {
  return parts
    .filter(Boolean)
    .map((part, index) => index === 0 ? trimTrailingSlash(part) : part.replace(/^\/+|\/+$/g, ""))
    .join("/");
}

function manifestSupportsSize(manifest: PrismcadeCharacterManifest, size: number): boolean {
  return manifest.allowedSizes.some(([width, height]) => width === size && height === size);
}

function resolveRequestedSize(
  manifest: PrismcadeCharacterManifest,
  requested?: PrismcadeSpriteSize,
  fallback: PrismcadeSpriteSize = DEFAULT_FALLBACK_SIZE,
  selectedVariant?: PrismcadeCharacterViewVariant,
): PrismcadeSpriteSize {
  const variantDefault = selectedVariant?.defaultSize as PrismcadeSpriteSize | undefined;
  const manifestDefault = manifest.defaultFrameSize[0] as PrismcadeSpriteSize;
  const candidates = [requested, variantDefault, manifestDefault, fallback, DEFAULT_FALLBACK_SIZE].filter(Boolean) as PrismcadeSpriteSize[];

  for (const candidate of candidates) {
    const variantAllowsSize = !selectedVariant?.runtimeSizes || selectedVariant.runtimeSizes.includes(candidate);
    if (variantAllowsSize && manifestSupportsSize(manifest, candidate)) return candidate;
  }

  const firstVariantSize = selectedVariant?.runtimeSizes?.find((size) => manifestSupportsSize(manifest, size));
  if (firstVariantSize) return firstVariantSize as PrismcadeSpriteSize;

  const first = manifest.allowedSizes[0]?.[0];
  if (!first) {
    throw new Error(`Character ${manifest.characterId} does not declare any allowed sizes.`);
  }
  return first as PrismcadeSpriteSize;
}

async function fetchJson<T>(fetchImpl: typeof fetch, url: string): Promise<T> {
  const response = await fetchImpl(url);
  if (!response.ok) {
    throw new Error(`Failed to fetch ${url}: ${response.status} ${response.statusText}`);
  }
  return response.json() as Promise<T>;
}

function buildClips(runtime: PrismcadeRuntimeManifest): Record<PrismcadeAnimationSlot, PrismcadeAnimationClip> {
  const clips: Record<PrismcadeAnimationSlot, PrismcadeAnimationClip> = {};

  for (const [slot, slotMeta] of Object.entries(runtime.slots)) {
    clips[slot] = {
      slot,
      frameCount: slotMeta.frameCount,
      durationMs: slotMeta.durationMs,
      containsProp: slotMeta.containsProp,
      framesDir: slotMeta.framesDir,
      strip: slotMeta.strip,
      gif: slotMeta.gif,
      frames: runtime.atlas.frames[slot] ?? [],
    };
  }

  return clips;
}

function selectCharacterViewVariant(
  manifest: PrismcadeCharacterManifest,
  viewMode: PrismcadeViewMode,
  viewPreference?: PrismcadeCharacterView[],
): { selectedView: PrismcadeCharacterView; selectedVariant: PrismcadeCharacterViewVariant; fallbackUsed: boolean; fallbackReason?: string } {
  const variants = manifest.viewVariants ?? {};
  const priority = viewPreference ?? VIEW_MODE_TO_CHARACTER_VIEW_PRIORITY[viewMode];

  for (let index = 0; index < priority.length; index += 1) {
    const candidate = priority[index];
    const variant = variants[candidate];
    if (!variant) continue;
    if (variant.status === "missing") continue;

    return {
      selectedView: candidate,
      selectedVariant: variant,
      fallbackUsed: index > 0,
      fallbackReason: index > 0 ? `No usable ${priority[0]} variant; selected ${candidate}.` : undefined,
    };
  }

  const compatibleSide = manifest.compatibleGameViews?.includes("side") || manifest.compatibleGameViews?.includes("profile/lobby");
  if (compatibleSide) {
    return {
      selectedView: "side",
      selectedVariant: { status: "fallback", defaultSize: manifest.defaultFrameSize[0], fallbackSlot: "idle" },
      fallbackUsed: true,
      fallbackReason: "No structured viewVariants were available; fell back to legacy side/profile compatibility.",
    };
  }

  throw new Error(`Character ${manifest.characterId} has no usable variant for view mode ${viewMode}.`);
}

async function loadRuntime(
  baseUrl: string,
  manifest: PrismcadeCharacterManifest,
  size: PrismcadeSpriteSize,
  fetchImpl: typeof fetch,
  selectedVariant?: PrismcadeCharacterViewVariant,
): Promise<Pick<LoadedPrismcadeCharacter, "runtime" | "atlasUrl" | "clips">> {
  const runtimeRoot = selectedVariant?.runtimeRoot ?? "runtime";
  const runtimeBaseUrl = joinUrl(baseUrl, runtimeRoot, String(size));
  const runtime = await fetchJson<PrismcadeRuntimeManifest>(fetchImpl, joinUrl(runtimeBaseUrl, "manifest.json"));

  return {
    runtime,
    atlasUrl: joinUrl(runtimeBaseUrl, runtime.atlas.image),
    clips: buildClips(runtime),
  };
}

/**
 * Load a Prismcade portable character pack from a base URL.
 */
export async function loadPrismcadeCharacter(
  baseUrl: string,
  options: LoadPrismcadeCharacterOptions = {},
): Promise<LoadedPrismcadeCharacter> {
  const fetchImpl = options.fetchImpl ?? fetch;
  const cleanBaseUrl = trimTrailingSlash(baseUrl);
  const manifest = await fetchJson<PrismcadeCharacterManifest>(
    fetchImpl,
    joinUrl(cleanBaseUrl, "manifest.prismcade-character.json"),
  );

  const size = resolveRequestedSize(manifest, options.size, options.fallbackSize);
  const runtimeData = await loadRuntime(cleanBaseUrl, manifest, size, fetchImpl);

  return {
    baseUrl: cleanBaseUrl,
    manifest,
    size,
    ...runtimeData,
  };
}

/**
 * Load a Prismcade character while respecting the game's camera/view mode.
 */
export async function loadPrismcadeCharacterForView(
  baseUrl: string,
  options: LoadPrismcadeCharacterForViewOptions,
): Promise<LoadedPrismcadeCharacterForView> {
  const fetchImpl = options.fetchImpl ?? fetch;
  const cleanBaseUrl = trimTrailingSlash(baseUrl);
  const manifest = await fetchJson<PrismcadeCharacterManifest>(
    fetchImpl,
    joinUrl(cleanBaseUrl, "manifest.prismcade-character.json"),
  );
  const selection = selectCharacterViewVariant(manifest, options.viewMode, options.viewPreference);
  const size = resolveRequestedSize(manifest, options.size, options.fallbackSize, selection.selectedVariant);
  const runtimeData = await loadRuntime(cleanBaseUrl, manifest, size, fetchImpl, selection.selectedVariant);

  return {
    baseUrl: cleanBaseUrl,
    manifest,
    size,
    requestedViewMode: options.viewMode,
    selectedView: selection.selectedView,
    selectedVariant: selection.selectedVariant,
    fallbackUsed: selection.fallbackUsed,
    fallbackReason: selection.fallbackReason,
    ...runtimeData,
  };
}

/**
 * Resolve a clip from a loaded character with a safe fallback chain.
 */
export function getPrismcadeClip(
  character: LoadedPrismcadeCharacter,
  slot: PrismcadeAnimationSlot,
  fallbacks: PrismcadeAnimationSlot[] = ["idle"],
): PrismcadeAnimationClip {
  const direct = character.clips[slot];
  if (direct) return direct;

  for (const fallback of fallbacks) {
    const clip = character.clips[fallback];
    if (clip) return clip;
  }

  const firstClip = Object.values(character.clips)[0];
  if (!firstClip) {
    throw new Error(`Character ${character.manifest.characterId} has no animation clips.`);
  }
  return firstClip;
}
