export async function loadFruits() {
  const response = await fetch('./data/fruits/core-fruits.json');
  if (!response.ok) throw new Error(`Could not load fruits: ${response.status}`);
  return response.json();
}

export function fruitById(fruits, id) {
  return fruits.find((fruit) => fruit.id === id) ?? fruits[0];
}

export function createMasteryMap(fruits, existing = {}) {
  return Object.fromEntries(fruits.map((fruit) => [fruit.id, Number(existing[fruit.id] ?? fruit.mastery ?? 0)]));
}

export function addMastery(profile, fruitId, amount) {
  profile.mastery[fruitId] = Math.max(0, Math.round((profile.mastery[fruitId] ?? 0) + amount));
}
