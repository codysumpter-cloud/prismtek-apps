export const CODEX_PET_ATLAS_PROFILE = {
  columns: 8,
  rows: 9,
  cellWidth: 192,
  cellHeight: 208,
  states: [
    { id: 'idle', label: 'Idle', row: 0, frames: 6, fps: 5 },
    { id: 'running-right', label: 'Run right', row: 1, frames: 8, fps: 10 },
    { id: 'running-left', label: 'Run left', row: 2, frames: 8, fps: 10 },
    { id: 'waving', label: 'Wave', row: 3, frames: 4, fps: 7 },
    { id: 'jumping', label: 'Jump', row: 4, frames: 5, fps: 8 },
    { id: 'failed', label: 'Failed', row: 5, frames: 8, fps: 6 },
    { id: 'waiting', label: 'Waiting', row: 6, frames: 6, fps: 5 },
    { id: 'running', label: 'Working', row: 7, frames: 6, fps: 8 },
    { id: 'review', label: 'Review', row: 8, frames: 6, fps: 5 }
  ]
};

export const BITBUD_DEFAULT_PET = {
  id: 'bitbud',
  displayName: 'Bitbud',
  description: 'A tiny original BUAP companion for Cody: playful, practical, brave, warm, and game-like.',
  spritesheetPath: 'spritesheet.webp'
};

export function normalisePetManifest(manifest) {
  if (!manifest || typeof manifest !== 'object') {
    return BITBUD_DEFAULT_PET;
  }

  return {
    id: String(manifest.id || BITBUD_DEFAULT_PET.id),
    displayName: String(manifest.displayName || manifest.name || BITBUD_DEFAULT_PET.displayName),
    description: String(manifest.description || BITBUD_DEFAULT_PET.description),
    spritesheetPath: String(manifest.spritesheetPath || manifest.spriteSheetPath || manifest.spritesheet || BITBUD_DEFAULT_PET.spritesheetPath)
  };
}

export async function readJsonFile(file) {
  const text = await file.text();
  return JSON.parse(text);
}

export function createObjectUrl(file) {
  return URL.createObjectURL(file);
}

export function getStateById(stateId) {
  return CODEX_PET_ATLAS_PROFILE.states.find((state) => state.id === stateId) || CODEX_PET_ATLAS_PROFILE.states[0];
}
