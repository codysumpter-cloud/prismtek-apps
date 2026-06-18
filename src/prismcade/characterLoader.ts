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

export interface LoadPrismcadeCharacterOptions {
  /** Preferred sprite size. Defaults to the manifest's default size, usually 64. */
  size?: PrismcadeSpriteSize;
  /** Use this fallback size if the preferred size is unavailable. Defaults to 64. */
  fallbackSize?: PrismcadeSpriteSize;
  /** Optional custom fetch implementation for tests or non-browser runtimes. */
  fetchImpl?: typeof fetch;
}

const DEFAULT_FALLBACK_SIZE: PrismcadeSpriteSize = 64;

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
): PrismcadeSpriteSize {
  const manifestDefault = manifest.defaultFrameSize[0] as PrismcadeSpriteSize;
  const candidates = [requested, manifestDefault, fallback, DEFAULT_FALLBACK_SIZE].filter(Boolean) as PrismcadeSpriteSize[];

  for (const candidate of candidates) {
    if (manifestSupportsSize(manifest, candidate)) return candidate;
  }

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

/**
 * Load a Prismcade portable character pack from a base URL.
 *
 * Example:
 *
 * ```ts
 * const character = await loadPrismcadeCharacter(
 *   "/game-assets/characters/prismtek-fixed-hair",
 *   { size: 64 },
 * );
 * const idle = character.clips.idle;
 * ```
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
  const runtimeBaseUrl = joinUrl(cleanBaseUrl, "runtime", String(size));
  const runtime = await fetchJson<PrismcadeRuntimeManifest>(
    fetchImpl,
    joinUrl(runtimeBaseUrl, "manifest.json"),
  );

  return {
    baseUrl: cleanBaseUrl,
    manifest,
    size,
    runtime,
    atlasUrl: joinUrl(runtimeBaseUrl, runtime.atlas.image),
    clips: buildClips(runtime),
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
