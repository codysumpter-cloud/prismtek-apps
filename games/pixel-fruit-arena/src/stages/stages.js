import { SKY_RUINS } from "./skyRuins.js";
import { TRAINING_ARENA } from "./trainingArena.js";

export const STAGES = {
  [SKY_RUINS.id]: SKY_RUINS,
  [TRAINING_ARENA.id]: TRAINING_ARENA
};

export function stageFor(id) {
  return STAGES[id] || SKY_RUINS;
}
