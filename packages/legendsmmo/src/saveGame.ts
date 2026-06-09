import type { ContentPackManifest } from "./content";
import type { PlayerProfile } from "./player";
import type { WorldState } from "./world";

export interface SaveGameSnapshot {
  schemaVersion: 1;
  savedAt: string;
  contentPack: ContentPackManifest;
  player: PlayerProfile;
  world: WorldState;
}

export function createSaveGameSnapshot(input: {
  contentPack: ContentPackManifest;
  player: PlayerProfile;
  world: WorldState;
  now?: string;
}): SaveGameSnapshot {
  return {
    schemaVersion: 1,
    savedAt: input.now ?? new Date().toISOString(),
    contentPack: input.contentPack,
    player: input.player,
    world: input.world,
  };
}

export function parseSaveGameSnapshot(json: string): SaveGameSnapshot {
  const parsed = JSON.parse(json) as SaveGameSnapshot;
  if (parsed.schemaVersion !== 1) throw new Error(`Unsupported save schema ${parsed.schemaVersion}.`);
  return parsed;
}

export function stringifySaveGameSnapshot(snapshot: SaveGameSnapshot): string {
  return JSON.stringify(snapshot, null, 2);
}
