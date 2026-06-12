export const BUILD_FLAGS = Object.freeze({
  // Dev-only. Release builds must force this false. The game never commits reference GIFs.
  USE_REFERENCE_TEST_ASSETS: import.meta?.env?.DEV && import.meta?.env?.VITE_USE_REFERENCE_TEST_ASSETS === 'true',
  RELEASE_REFERENCE_ASSETS_ALLOWED: false,
});

export const GAME = Object.freeze({
  width: 960,
  height: 540,
  gravity: 0.72,
  groundFriction: 0.82,
  airFriction: 0.96,
  maxPlayers: 4,
  stockCount: 3,
  matchSeconds: 180,
});
