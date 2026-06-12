export async function loadStage() {
  const response = await fetch('./data/stages/sky-ruins-arena.json');
  if (!response.ok) throw new Error(`Could not load stage: ${response.status}`);
  return response.json();
}

export function rectsOverlap(a, b) {
  return a.x < b.x + b.width && a.x + a.width > b.x && a.y < b.y + b.height && a.y + a.height > b.y;
}
