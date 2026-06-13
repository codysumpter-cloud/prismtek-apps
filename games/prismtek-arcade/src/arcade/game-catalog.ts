import { ACTIVE_ARCADE_GAMES, ACTIVE_ARCADE_GAME_ORDER, type GameId } from "./shared";

export { ACTIVE_ARCADE_GAMES, ACTIVE_ARCADE_GAME_ORDER };

export const GAME_SOURCE_COMPONENTS: Record<GameId, string> = {
  "flappy-pixel": "src/arcade/games/FlappyPixelGame.ts",
  "crossy-pixel": "src/arcade/games/CrossyPixelGame.ts",
  "pixel-snake": "src/arcade/games/PixelSnakeGame.ts",
  "neon-brick-breaker": "src/arcade/games/NeonBrickBreakerGame.ts",
  "pixel-stacker": "src/arcade/games/PixelStackerGame.ts"
};
