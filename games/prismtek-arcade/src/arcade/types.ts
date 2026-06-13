import type { GameId, GameStatsMap } from "./shared";

export type ArcadeSoundEffect = "blip" | "coin" | "impact" | "pause" | "success" | "boost";

export interface ArcadeSettings {
  muted: boolean;
  effectsVolume: number;
  reducedMotion: boolean;
  touchControls: boolean;
}

export interface GameRoundResult<G extends GameId = GameId> {
  gameId: G;
  runId: string;
  score: number;
  stats: GameStatsMap[G];
  endedAt: string;
  challengeId?: string;
  mode?: string;
  summary: string;
  highlight: string;
}

export interface ArcadeGameComponentProps<G extends GameId = GameId> {
  challengeId: string;
  challengeSeed: string;
  settings: ArcadeSettings;
  personalBest: number | null;
  restartToken: number;
  onComplete: (result: GameRoundResult<G>) => void;
  playEffect: (effect: ArcadeSoundEffect) => void;
}
