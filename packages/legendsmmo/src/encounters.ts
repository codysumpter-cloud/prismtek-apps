import type { CreatureSpecies, LegendsId } from "./content";
import type { WorldPosition } from "./world";

export interface EncounterTableEntry {
  speciesId: LegendsId;
  minLevel: number;
  maxLevel: number;
  weight: number;
}

export interface EncounterTable {
  id: LegendsId;
  mapId: LegendsId;
  entries: EncounterTableEntry[];
  stepChance: number;
}

export interface EncounterResult {
  species: CreatureSpecies;
  level: number;
}

export type RandomSource = () => number;

export function maybeRollEncounter(input: {
  position: WorldPosition;
  table: EncounterTable;
  species: Map<LegendsId, CreatureSpecies>;
  random?: RandomSource;
}): EncounterResult | undefined {
  if (input.position.mapId !== input.table.mapId) return undefined;
  const random = input.random ?? Math.random;
  if (random() > input.table.stepChance) return undefined;

  const totalWeight = input.table.entries.reduce((sum, entry) => sum + entry.weight, 0);
  let roll = random() * totalWeight;
  for (const entry of input.table.entries) {
    roll -= entry.weight;
    if (roll <= 0) {
      const species = input.species.get(entry.speciesId);
      if (!species) throw new Error(`Encounter references missing species ${entry.speciesId}.`);
      const level = entry.minLevel + Math.floor(random() * (entry.maxLevel - entry.minLevel + 1));
      return { species, level };
    }
  }
  return undefined;
}
