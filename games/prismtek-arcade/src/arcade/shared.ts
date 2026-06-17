export const APP_CLIENT_VERSION = "arcade-react-v1";

export const ACTIVE_ARCADE_GAME_IDS = [
  "flappy-pixel",
  "crossy-pixel",
  "pixel-snake",
  "neon-brick-breaker",
  "pixel-stacker"
] as const;

export type GameId = (typeof ACTIVE_ARCADE_GAME_IDS)[number];

export type GameDefinition = {
  id: GameId;
  slug: string;
  name: string;
  shortPitch: string;
  longPitch: string;
  accent: string;
  controls: string[];
};

export const ACTIVE_ARCADE_GAMES: Record<GameId, GameDefinition> = {
  "flappy-pixel": {
    id: "flappy-pixel",
    slug: "flappy-pixel",
    name: "Flappy Pixel",
    shortPitch: "Snap through the skyline, chase medals, and race your best ghost.",
    longPitch: "A crisp one-button flyer with fair hitboxes, better pacing, medal tiers, and a replay loop.",
    accent: "#75ffbb",
    controls: ["Tap, click, or press Space to flap", "P pauses instantly"]
  },
  "crossy-pixel": {
    id: "crossy-pixel",
    slug: "crossy-pixel",
    name: "Crossy Pixel",
    shortPitch: "Climb a chaotic castle tower room by room.",
    longPitch: "A vertical room-based climber with moving hazards, coins, doors, and score pressure.",
    accent: "#ffd166",
    controls: ["Move with Arrow keys or touch buttons", "Jump with Space or tap jump"]
  },
  "pixel-snake": {
    id: "pixel-snake",
    slug: "pixel-snake",
    name: "Pixel Snake",
    shortPitch: "Snake arena with readable pixel movement and score chasing.",
    longPitch: "A local snake arena port used as the browser baseline before live services and native ports.",
    accent: "#ff7b7b",
    controls: ["Move with Arrow keys or WASD", "Collect food and avoid walls or yourself"]
  },
  "neon-brick-breaker": {
    id: "neon-brick-breaker",
    slug: "neon-brick-breaker",
    name: "Neon Brick Breaker",
    shortPitch: "Fast paddle control, clean waves, and modifier spikes.",
    longPitch: "A short-session brick breaker with responsive paddle reads and wave clears.",
    accent: "#7ce2ff",
    controls: ["Move with pointer, touch, or Arrow keys", "Tap, click, or press Space to launch"]
  },
  "pixel-stacker": {
    id: "pixel-stacker",
    slug: "pixel-stacker",
    name: "Pixel Stacker",
    shortPitch: "Snap moving slabs into a wobbling tower and hold your nerve.",
    longPitch: "A replay-heavy timing game where perfect drops keep width and misses trim the tower.",
    accent: "#c9a4ff",
    controls: ["Tap, click, or press Space to lock each layer", "Perfect drops keep your width"]
  }
};

export const ACTIVE_ARCADE_GAME_ORDER = ACTIVE_ARCADE_GAME_IDS.map((id) => ACTIVE_ARCADE_GAMES[id]);

export type GameStatsMap = Record<GameId, Record<string, number | string | boolean | undefined>>;

export function computeCanonicalScore(gameId: GameId, stats: Record<string, number | string | boolean | undefined>) {
  const numeric = Object.values(stats).reduce((sum, value) => (typeof value === "number" ? sum + value : sum), 0);
  const multiplier = gameId === "pixel-snake" ? 7 : gameId === "neon-brick-breaker" ? 5 : 4;
  return Math.max(0, Math.round(numeric * multiplier));
}

export function createRunId() {
  return `run-${Date.now().toString(36)}-${Math.random().toString(36).slice(2, 8)}`;
}
