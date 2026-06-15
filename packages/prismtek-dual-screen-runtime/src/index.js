export const layouts = ['single', 'stacked-ds', 'foldable-ds', 'external-display', 'rgds-dual'];

export function resolveDualScreenLayout(config = {}, environment = {}) {
  const preferred = config.preferredLayout || 'single';
  const layout = layouts.includes(preferred) ? preferred : 'single';
  const width = Number(environment.width || 960);
  const height = Number(environment.height || 540);
  const split = layout === 'single' ? null : Math.floor(height / 2);
  return {
    layout,
    primary: { x: 0, y: 0, width, height: split || height },
    secondary: split ? { x: 0, y: split, width, height: height - split } : null,
    touch: config.touch || 'primary',
    notes: config.notes || []
  };
}

export function validateDualScreenGameConfig(config) {
  const errors = [];
  if (!config || typeof config !== 'object') errors.push('config must be an object');
  if (!config.gameId) errors.push('gameId is required');
  if (!config.displayName) errors.push('displayName is required');
  if (config.preferredLayout && !layouts.includes(config.preferredLayout)) {
    errors.push(`preferredLayout must be one of: ${layouts.join(', ')}`);
  }
  return { ok: errors.length === 0, errors };
}
