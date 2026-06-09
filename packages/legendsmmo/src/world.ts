import type { ContentPack, LegendsId, MapDefinition } from "./content";

export type Direction = "up" | "down" | "left" | "right";

export interface WorldPosition {
  mapId: LegendsId;
  x: number;
  y: number;
  facing: Direction;
}

export interface WorldState {
  activePlayers: Record<LegendsId, WorldPosition>;
  tick: number;
}

export function createWorldState(): WorldState {
  return { activePlayers: {}, tick: 0 };
}

export function movePosition(position: WorldPosition, direction: Direction, map: MapDefinition): WorldPosition {
  const next = { ...position, facing: direction };
  if (direction === "up") next.y -= 1;
  if (direction === "down") next.y += 1;
  if (direction === "left") next.x -= 1;
  if (direction === "right") next.x += 1;

  if (!isWalkable(map, next.x, next.y)) return { ...position, facing: direction };
  return next;
}

export function isWalkable(map: MapDefinition, x: number, y: number): boolean {
  if (x < 0 || y < 0 || x >= map.width || y >= map.height) return false;
  const index = y * map.width + x;
  for (const layer of map.layers) {
    if (layer.collision?.[index]) return false;
  }
  return true;
}

export function findMap(pack: ContentPack, mapId: LegendsId): MapDefinition {
  const map = pack.maps.find((entry) => entry.id === mapId);
  if (!map) throw new Error(`Unknown map ${mapId}.`);
  return map;
}

export function placePlayer(world: WorldState, playerId: LegendsId, position: WorldPosition): WorldState {
  return {
    tick: world.tick + 1,
    activePlayers: { ...world.activePlayers, [playerId]: position },
  };
}
