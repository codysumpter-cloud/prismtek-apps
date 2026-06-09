import type { LegendsId } from "./content";
import type { InventoryState } from "./inventory";
import type { PartyState } from "./party";
import type { WorldPosition } from "./world";

export interface PlayerProfile {
  id: LegendsId;
  displayName: string;
  createdAt: string;
  updatedAt: string;
  party: PartyState;
  inventory: InventoryState;
  position: WorldPosition;
  flags: Record<string, boolean>;
  counters: Record<string, number>;
}

export function createPlayerProfile(input: {
  id: LegendsId;
  displayName: string;
  position: WorldPosition;
  party?: PartyState;
  inventory?: InventoryState;
  now?: string;
}): PlayerProfile {
  const now = input.now ?? new Date().toISOString();
  return {
    id: input.id,
    displayName: input.displayName,
    createdAt: now,
    updatedAt: now,
    party: input.party ?? { activeSlot: 0, members: [] },
    inventory: input.inventory ?? { currency: 0, stacks: [] },
    position: input.position,
    flags: {},
    counters: {},
  };
}

export function touchPlayer(profile: PlayerProfile, now = new Date().toISOString()): PlayerProfile {
  return { ...profile, updatedAt: now };
}
