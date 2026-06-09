import type { CreatureSpecies, MoveDefinition, StatBlock } from "./content";

export interface BattleCreature {
  instanceId: string;
  species: CreatureSpecies;
  level: number;
  currentHp: number;
  stats: StatBlock;
  knownMoveIds: string[];
}

export interface BattleSide {
  trainerId: string;
  active: BattleCreature;
  bench: BattleCreature[];
}

export interface BattleState {
  id: string;
  turn: number;
  sideA: BattleSide;
  sideB: BattleSide;
  log: BattleLogEntry[];
  status: "active" | "sideA-won" | "sideB-won" | "draw";
}

export interface BattleLogEntry {
  turn: number;
  message: string;
}

export interface BattleMoveCommand {
  side: "A" | "B";
  moveId: string;
}

export function createBattleCreature(instanceId: string, species: CreatureSpecies, level: number, knownMoveIds: string[]): BattleCreature {
  const stats = scaleStats(species.baseStats, level);
  return { instanceId, species, level, currentHp: stats.hp, stats, knownMoveIds };
}

export function scaleStats(base: StatBlock, level: number): StatBlock {
  const multiplier = 1 + Math.max(1, level) / 50;
  return {
    hp: Math.round(base.hp * multiplier),
    attack: Math.round(base.attack * multiplier),
    defense: Math.round(base.defense * multiplier),
    spirit: Math.round(base.spirit * multiplier),
    speed: Math.round(base.speed * multiplier),
  };
}

export function applyTurn(state: BattleState, moves: Map<string, MoveDefinition>, commandA: BattleMoveCommand, commandB: BattleMoveCommand): BattleState {
  if (state.status !== "active") return state;

  const next: BattleState = { ...state, turn: state.turn + 1, log: [...state.log] };
  const first = state.sideA.active.stats.speed >= state.sideB.active.stats.speed ? commandA : commandB;
  const second = first === commandA ? commandB : commandA;

  applyMove(next, moves, first);
  if (next.status === "active") applyMove(next, moves, second);
  resolveBattleStatus(next);
  return next;
}

function applyMove(state: BattleState, moves: Map<string, MoveDefinition>, command: BattleMoveCommand) {
  const move = moves.get(command.moveId);
  if (!move) {
    state.log.push({ turn: state.turn, message: `Unknown move ${command.moveId}.` });
    return;
  }

  const attacker = command.side === "A" ? state.sideA.active : state.sideB.active;
  const defender = command.side === "A" ? state.sideB.active : state.sideA.active;

  if (!attacker.knownMoveIds.includes(move.id)) {
    state.log.push({ turn: state.turn, message: `${attacker.species.name} does not know ${move.name}.` });
    return;
  }

  if (move.kind === "status" || move.power === 0) {
    state.log.push({ turn: state.turn, message: `${attacker.species.name} used ${move.name}.` });
    return;
  }

  const attackStat = move.kind === "spirit" ? attacker.stats.spirit : attacker.stats.attack;
  const rawDamage = Math.max(1, Math.round((move.power + attackStat - defender.stats.defense / 2) * (attacker.level / 50)));
  defender.currentHp = Math.max(0, defender.currentHp - rawDamage);
  state.log.push({ turn: state.turn, message: `${attacker.species.name} used ${move.name} for ${rawDamage} damage.` });
}

function resolveBattleStatus(state: BattleState) {
  const aDown = state.sideA.active.currentHp <= 0;
  const bDown = state.sideB.active.currentHp <= 0;
  if (aDown && bDown) state.status = "draw";
  else if (aDown) state.status = "sideB-won";
  else if (bDown) state.status = "sideA-won";
}
