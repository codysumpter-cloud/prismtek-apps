import type { LegendsId, StatBlock } from "./content";

export interface PartyCreature {
  instanceId: LegendsId;
  speciesId: LegendsId;
  nickname?: string;
  level: number;
  currentHp: number;
  stats: StatBlock;
  knownMoveIds: LegendsId[];
  experience: number;
  capturedAt?: string;
}

export interface PartyState {
  activeSlot: number;
  members: PartyCreature[];
}

export const MAX_PARTY_SIZE = 6;

export function addPartyMember(party: PartyState, creature: PartyCreature): PartyState {
  if (party.members.length >= MAX_PARTY_SIZE) {
    throw new Error(`Party is full. Max party size is ${MAX_PARTY_SIZE}.`);
  }
  return { ...party, members: [...party.members, creature] };
}

export function setActiveSlot(party: PartyState, activeSlot: number): PartyState {
  if (activeSlot < 0 || activeSlot >= party.members.length) {
    throw new Error(`Invalid active slot ${activeSlot}.`);
  }
  return { ...party, activeSlot };
}

export function getActivePartyMember(party: PartyState): PartyCreature | undefined {
  return party.members[party.activeSlot];
}

export function healParty(party: PartyState): PartyState {
  return {
    ...party,
    members: party.members.map((member) => ({ ...member, currentHp: member.stats.hp })),
  };
}
