import type { BattleMoveCommand, BattleState } from "../battle";
import type { LegendsId } from "../content";
import type { PlayerProfile } from "../player";
import type { Direction, WorldPosition } from "../world";

export type ClientMessage =
  | { type: "client/hello"; playerId: LegendsId; protocolVersion: 1 }
  | { type: "client/move"; playerId: LegendsId; direction: Direction; seq: number }
  | { type: "client/battle-move"; playerId: LegendsId; battleId: LegendsId; command: BattleMoveCommand; seq: number };

export type ServerMessage =
  | { type: "server/welcome"; player: PlayerProfile; protocolVersion: 1 }
  | { type: "server/world-position"; playerId: LegendsId; position: WorldPosition; tick: number }
  | { type: "server/battle-state"; battle: BattleState }
  | { type: "server/error"; code: string; message: string };

export interface SyncEnvelope<TMessage extends ClientMessage | ServerMessage> {
  id: LegendsId;
  sentAt: string;
  message: TMessage;
}

export function createEnvelope<TMessage extends ClientMessage | ServerMessage>(id: LegendsId, message: TMessage, now = new Date().toISOString()): SyncEnvelope<TMessage> {
  return { id, sentAt: now, message };
}
