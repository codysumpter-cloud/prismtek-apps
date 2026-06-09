export type LegendsId = string;

export interface StatBlock {
  hp: number;
  attack: number;
  defense: number;
  spirit: number;
  speed: number;
}

export interface CreatureSpecies {
  id: LegendsId;
  name: string;
  description?: string;
  elements: string[];
  baseStats: StatBlock;
  learnset: CreatureMoveLearn[];
}

export interface CreatureMoveLearn {
  moveId: LegendsId;
  level: number;
}

export interface MoveDefinition {
  id: LegendsId;
  name: string;
  element: string;
  power: number;
  accuracy: number;
  energyCost: number;
  kind: "physical" | "spirit" | "status";
}

export interface ItemDefinition {
  id: LegendsId;
  name: string;
  description?: string;
  kind: "key" | "consumable" | "equipment" | "material";
}

export interface MapDefinition {
  id: LegendsId;
  name: string;
  width: number;
  height: number;
  tilesetId: LegendsId;
  layers: MapLayer[];
  spawnPoints: SpawnPoint[];
}

export interface MapLayer {
  id: LegendsId;
  name: string;
  tiles: number[];
  collision?: boolean[];
}

export interface SpawnPoint {
  id: LegendsId;
  x: number;
  y: number;
  facing?: "up" | "down" | "left" | "right";
}

export interface ContentPackManifest {
  id: LegendsId;
  name: string;
  version: string;
  author?: string;
  license?: string;
}

export interface ContentPack {
  manifest: ContentPackManifest;
  creatures: CreatureSpecies[];
  moves: MoveDefinition[];
  items: ItemDefinition[];
  maps: MapDefinition[];
}

export function indexById<T extends { id: LegendsId }>(records: T[]): Map<LegendsId, T> {
  return new Map(records.map((record) => [record.id, record]));
}

export function validateContentPack(pack: ContentPack): string[] {
  const errors: string[] = [];
  const creatureIds = new Set<string>();
  const moveIds = new Set<string>();
  const itemIds = new Set<string>();
  const mapIds = new Set<string>();

  for (const move of pack.moves) {
    if (moveIds.has(move.id)) errors.push(`Duplicate move id: ${move.id}`);
    moveIds.add(move.id);
    if (move.accuracy < 0 || move.accuracy > 100) errors.push(`Move ${move.id} accuracy must be 0-100.`);
    if (move.power < 0) errors.push(`Move ${move.id} power cannot be negative.`);
  }

  for (const creature of pack.creatures) {
    if (creatureIds.has(creature.id)) errors.push(`Duplicate creature id: ${creature.id}`);
    creatureIds.add(creature.id);
    for (const learned of creature.learnset) {
      if (!moveIds.has(learned.moveId)) errors.push(`Creature ${creature.id} references missing move ${learned.moveId}.`);
      if (learned.level < 1) errors.push(`Creature ${creature.id} has invalid learn level for ${learned.moveId}.`);
    }
  }

  for (const item of pack.items) {
    if (itemIds.has(item.id)) errors.push(`Duplicate item id: ${item.id}`);
    itemIds.add(item.id);
  }

  for (const map of pack.maps) {
    if (mapIds.has(map.id)) errors.push(`Duplicate map id: ${map.id}`);
    mapIds.add(map.id);
    const expectedTiles = map.width * map.height;
    for (const layer of map.layers) {
      if (layer.tiles.length !== expectedTiles) errors.push(`Map ${map.id}/${layer.id} expected ${expectedTiles} tiles.`);
      if (layer.collision && layer.collision.length !== expectedTiles) errors.push(`Map ${map.id}/${layer.id} collision length mismatch.`);
    }
  }

  return errors;
}
