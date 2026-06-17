export function createSeededRandom(seedSource: string) {
  let seed = 1;
  for (const char of seedSource) {
    seed = (seed * 33 + char.charCodeAt(0)) % 2147483647;
  }

  return function nextRandom() {
    seed = (seed * 48271) % 2147483647;
    return seed / 2147483647;
  };
}
