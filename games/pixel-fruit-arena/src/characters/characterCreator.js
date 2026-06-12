import { createMasteryMap } from '../fruits/fruitRegistry.js';

export async function loadDefaultProfile(fruits) {
  const response = await fetch('./data/characters/default-profile.json');
  if (!response.ok) throw new Error(`Could not load profile: ${response.status}`);
  const profile = await response.json();
  profile.mastery = createMasteryMap(fruits, profile.mastery);
  return profile;
}

export function updateAppearance(profile, patch) {
  profile.appearance = { ...profile.appearance, ...patch };
}

export function unlockFruit(profile, fruitId) {
  if (!profile.owned_fruits.includes(fruitId)) profile.owned_fruits.push(fruitId);
  profile.mastery[fruitId] ??= 0;
}

export function equipFruit(profile, fruitId) {
  unlockFruit(profile, fruitId);
  profile.equipped_fruit = fruitId;
}
