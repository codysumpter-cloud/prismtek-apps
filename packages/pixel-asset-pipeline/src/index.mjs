export const DEFAULT_FRAME_SIZE = 64;
export const SUPPORTED_FRAME_SIZES = [16, 32, 48, 64, 96, 128];

export const CANONICAL_ANIMATION_SLOTS = Object.freeze([
  'idle', 'blink', 'breathe', 'walk', 'run', 'jump', 'fall', 'land', 'hurt', 'ko',
  'emote_happy', 'emote_angry', 'emote_shocked', 'thinking', 'charge',
  'melee_slash', 'melee_thrust', 'melee_spin', 'cast', 'projectile', 'impact',
  'buff', 'debuff', 'victory', 'defeat'
]);

export const PIXELLAB_STANDARD_DIRECTIONS = Object.freeze([
  'south', 'east', 'north', 'west', 'south-east', 'north-east', 'north-west', 'south-west'
]);

export const PIXELLAB_CARDINAL_DIRECTIONS = Object.freeze([
  'south', 'east', 'north', 'west'
]);

export const PIXELLAB_CORE_TEMPLATE_ANIMATIONS = Object.freeze([
  { slot: 'idle', templateAnimationId: 'breathing-idle', frameCount: 4, loop: true, purpose: 'Default standing/living idle loop.' },
  { slot: 'walk', templateAnimationId: 'walking-8-frames', frameCount: 8, loop: true, purpose: 'Readable locomotion for RPG and arcade movement.' },
  { slot: 'run', templateAnimationId: 'running-8-frames', frameCount: 8, loop: true, purpose: 'Fast locomotion for dash, chase, and action games.' },
  { slot: 'hurt', templateAnimationId: 'taking-punch', frameCount: 6, loop: false, purpose: 'Reusable hit reaction.' },
  { slot: 'jump', templateAnimationId: 'jumping-1', frameCount: 6, loop: false, purpose: 'Reusable hop/jump action.' },
  { slot: 'melee_thrust', templateAnimationId: 'lead-jab', frameCount: 6, loop: false, purpose: 'Short-range attack starter.' },
  { slot: 'melee_spin', templateAnimationId: 'hurricane-kick', frameCount: 8, loop: false, purpose: 'Spinning melee flourish.' },
  { slot: 'projectile', templateAnimationId: 'fireball', frameCount: 6, loop: false, purpose: 'Projectile/casting attack starter.' }
]);

const ANIMATION_ALIASES = new Map([
  ['faint', 'ko'], ['knockout', 'ko'], ['happy', 'emote_happy'], ['angry', 'emote_angry'],
  ['shocked', 'emote_shocked'], ['magic_cast', 'cast'], ['projectile_launch', 'projectile'],
  ['status_effect', 'buff'], ['melee_jab', 'melee_thrust']
]);

export function normalizeAnimationName(value) {
  const normalized = sanitizeIdentifier(value, '_');
  if (!normalized) return 'idle';
  return ANIMATION_ALIASES.get(normalized) ?? normalized;
}

export function normalizeVariantId(value) {
  const normalized = sanitizeIdentifier(value, '-');
  return (normalized || 'unnamed-asset').slice(0, 64);
}

export function validateSpriteSheetGrid(input = {}) {
  const imageWidth = toInteger(input.imageWidth, 0);
  const imageHeight = toInteger(input.imageHeight, 0);
  const frameWidth = toInteger(input.frameWidth, DEFAULT_FRAME_SIZE);
  const frameHeight = toInteger(input.frameHeight, DEFAULT_FRAME_SIZE);
  const margin = toInteger(input.margin, 0);
  const spacing = toInteger(input.spacing, 0);
  const errors = [];
  const warnings = [];

  if (imageWidth <= 0) errors.push('imageWidth must be a positive integer.');
  if (imageHeight <= 0) errors.push('imageHeight must be a positive integer.');
  if (frameWidth <= 0) errors.push('frameWidth must be a positive integer.');
  if (frameHeight <= 0) errors.push('frameHeight must be a positive integer.');
  if (margin < 0) errors.push('margin cannot be negative.');
  if (spacing < 0) errors.push('spacing cannot be negative.');
  if (!SUPPORTED_FRAME_SIZES.includes(frameWidth) || !SUPPORTED_FRAME_SIZES.includes(frameHeight)) {
    warnings.push(`Frame size ${frameWidth}x${frameHeight} is allowed, but Prismtek runtime sprites should prefer 64x64; use 128x128 only for source/master sheets.`);
  }

  const usableWidth = imageWidth - margin * 2;
  const usableHeight = imageHeight - margin * 2;
  if (usableWidth <= 0 || usableHeight <= 0) errors.push('Margins leave no usable image area.');

  const columns = usableWidth > 0 ? Math.floor((usableWidth + spacing) / (frameWidth + spacing)) : 0;
  const rows = usableHeight > 0 ? Math.floor((usableHeight + spacing) / (frameHeight + spacing)) : 0;
  const consumedWidth = columns > 0 ? columns * frameWidth + Math.max(0, columns - 1) * spacing : 0;
  const consumedHeight = rows > 0 ? rows * frameHeight + Math.max(0, rows - 1) * spacing : 0;
  const leftoverX = usableWidth - consumedWidth;
  const leftoverY = usableHeight - consumedHeight;

  if (columns <= 0) errors.push('No complete columns fit the selected frame width.');
  if (rows <= 0) errors.push('No complete rows fit the selected frame height.');
  if (leftoverX !== 0) warnings.push(`${leftoverX}px remain horizontally after slicing; check frame width, margin, or spacing.`);
  if (leftoverY !== 0) warnings.push(`${leftoverY}px remain vertically after slicing; check frame height, margin, or spacing.`);

  return { ok: errors.length === 0, imageWidth, imageHeight, frameWidth, frameHeight, margin, spacing, columns, rows, frameCount: Math.max(0, columns * rows), leftoverX, leftoverY, errors, warnings };
}

export function sliceSpriteSheetGrid(input = {}) {
  const validation = validateSpriteSheetGrid(input);
  const frames = [];
  if (!validation.ok) return { ...validation, frames };
  for (let row = 0; row < validation.rows; row += 1) {
    for (let column = 0; column < validation.columns; column += 1) {
      const index = row * validation.columns + column;
      frames.push({ index, row, column, x: validation.margin + column * (validation.frameWidth + validation.spacing), y: validation.margin + row * (validation.frameHeight + validation.spacing), width: validation.frameWidth, height: validation.frameHeight });
    }
  }
  return { ...validation, frames };
}

export function buildAnimationManifest(input = {}) {
  const variantId = normalizeVariantId(input.variantId);
  const grid = sliceSpriteSheetGrid(input);
  if (!grid.ok) return { ok: false, errors: grid.errors, warnings: grid.warnings, manifest: null };

  const animations = Array.isArray(input.animations) && input.animations.length > 0
    ? input.animations
    : [{ id: 'idle', fps: 8, loop: true, frameIndexes: grid.frames.slice(0, Math.min(grid.frames.length, 4)).map((frame) => frame.index) }];
  const normalizedAnimations = animations.map((animation) => normalizeAnimation(animation, grid));
  const errors = normalizedAnimations.flatMap((animation) => animation.errors);
  const warnings = [...grid.warnings, ...normalizedAnimations.flatMap((animation) => animation.warnings)];

  const manifest = {
    schemaVersion: 'prismtek-pixel-asset-manifest-v1',
    variantId,
    displayName: String(input.displayName || variantId),
    target: input.target || 'prismtek-runtime',
    frame: {
      width: grid.frameWidth,
      height: grid.frameHeight,
      baselineY: toInteger(input.baselineY, Math.max(0, grid.frameHeight - 10)),
      pivotX: toInteger(input.pivotX, Math.floor(grid.frameWidth / 2)),
      pivotY: toInteger(input.pivotY, Math.max(0, grid.frameHeight - 16))
    },
    sheet: {
      path: String(input.sheetPath || `${variantId}.png`),
      imageWidth: grid.imageWidth,
      imageHeight: grid.imageHeight,
      columns: grid.columns,
      rows: grid.rows,
      transparentBackground: input.transparentBackground !== false
    },
    animations: normalizedAnimations.map(({ value }) => value),
    provenance: normalizeProvenance(input.provenance)
  };
  return { ok: errors.length === 0, errors, warnings, manifest };
}

export function validateAnimationManifest(manifest) {
  const errors = [];
  const warnings = [];
  if (!manifest || typeof manifest !== 'object') return { ok: false, errors: ['manifest must be an object.'], warnings };
  if (manifest.schemaVersion !== 'prismtek-pixel-asset-manifest-v1') errors.push('schemaVersion must be prismtek-pixel-asset-manifest-v1.');
  if (!manifest.variantId) errors.push('variantId is required.');
  if (!manifest.frame || manifest.frame.width <= 0 || manifest.frame.height <= 0) errors.push('frame width/height are required.');
  if (manifest.frame && (manifest.frame.width !== 64 || manifest.frame.height !== 64)) warnings.push('64x64 is the default Prismtek game-ready target. Use other sizes only with explicit target notes.');
  if (!manifest.sheet?.path) errors.push('sheet.path is required.');
  if (!Array.isArray(manifest.animations) || manifest.animations.length === 0) errors.push('at least one animation is required.');
  if (!manifest.provenance?.rights) errors.push('provenance.rights is required.');
  return { ok: errors.length === 0, errors, warnings };
}

export function buildGenerationPrompt(input = {}) {
  const subject = String(input.subject || 'Prismtek Buddy creature');
  const frameWidth = toInteger(input.frameWidth, DEFAULT_FRAME_SIZE);
  const frameHeight = toInteger(input.frameHeight, DEFAULT_FRAME_SIZE);
  const slots = Array.isArray(input.animationSlots) && input.animationSlots.length > 0
    ? input.animationSlots.map(normalizeAnimationName)
    : ['idle', 'walk', 'hurt', 'melee_slash', 'cast', 'projectile'];
  const style = String(input.style || 'hard-edged readable pixel art, crisp silhouette, no blur, no antialiasing');
  const palette = String(input.palette || 'limited coherent palette with strong outline contrast');
  const constraints = [
    `Create original Prismtek-owned pixel art for: ${subject}.`,
    `Frame size: ${frameWidth}x${frameHeight}px. Use transparent background.`,
    `Style: ${style}.`,
    `Palette: ${palette}.`,
    `Required animation slots: ${slots.join(', ')}.`,
    'Keep feet/pivot aligned across frames unless a lunge/jump intentionally moves the body.',
    'Do not copy franchise characters, copyrighted sprites, logos, UI, or recognizable third-party designs.',
    'Return a sprite sheet plus a JSON manifest using prismtek-pixel-asset-manifest-v1.'
  ];
  if (input.referenceNotes) constraints.push(`Reference notes: ${String(input.referenceNotes)}`);
  return constraints.join('\n');
}

export function buildProviderJob(input = {}) {
  const provider = String(input.provider || 'manual');
  const prompt = input.prompt || buildGenerationPrompt(input);
  return {
    schemaVersion: 'prismtek-pixel-provider-job-v1',
    provider,
    mode: input.mode || 'prompt-to-sprite-sheet',
    prompt,
    negativePrompt: input.negativePrompt || 'blur, antialiasing, soft painterly shading, copyrighted character, logo, text watermark, mixed sprite sizes',
    output: { frameWidth: toInteger(input.frameWidth, DEFAULT_FRAME_SIZE), frameHeight: toInteger(input.frameHeight, DEFAULT_FRAME_SIZE), transparentBackground: input.transparentBackground !== false, manifestRequired: true },
    safety: { requireOriginalityPass: true, forbidThirdPartyAssetCopying: true, requireProvenance: true, noSecrets: true }
  };
}

export function listPixelLabAnimationTemplates(input = {}) {
  const requestedSlots = Array.isArray(input.slots) && input.slots.length > 0
    ? new Set(input.slots.map(normalizeAnimationName))
    : null;
  return PIXELLAB_CORE_TEMPLATE_ANIMATIONS
    .filter((template) => !requestedSlots || requestedSlots.has(template.slot))
    .map((template) => ({ ...template, provider: 'pixellab.ai', mode: 'template' }));
}

export function buildPixelLabCharacterExportDescriptor(input = {}) {
  const characterId = String(input.characterId || input.id || '').trim();
  const displayName = String(input.displayName || input.name || characterId || 'PixelLab Character');
  const directions = normalizeDirections(input.directions);
  const completedAnimations = normalizeCompletedAnimations(input.completedAnimations || input.animations);
  const pendingJobs = normalizeJobList(input.pendingJobs);
  const failedJobs = normalizeJobList(input.failedJobs);
  const templatePack = {
    schemaVersion: 'prismtek-pixellab-animation-template-pack-v1',
    provider: 'pixellab.ai',
    directions,
    templates: listPixelLabAnimationTemplates({ slots: input.templateSlots })
  };
  const coveragePlan = buildPixelLabAnimationJobPlan({
    characters: [{ characterId, displayName, completedAnimations }],
    directions,
    templates: templatePack.templates
  });
  const size = normalizePixelLabSize(input);

  return {
    schemaVersion: 'prismtek-pixellab-character-export-v1',
    variantId: normalizeVariantId(input.variantId || displayName),
    displayName,
    provider: {
      name: 'pixellab.ai',
      source: 'pixellab-mcp',
      characterId
    },
    status: String(input.status || 'completed'),
    directions,
    directionMode: `${directions.length}dir`,
    size,
    download: {
      url: String(input.downloadUrl || buildPixelLabCharacterDownloadUrl(characterId)),
      lockedUntilJobsComplete: Boolean(input.downloadLockedUntilJobsComplete || pendingJobs.length > 0)
    },
    completedAnimations,
    pendingJobs,
    failedJobs,
    templatePack,
    animationCoverage: {
      requiredTemplateCount: templatePack.templates.length,
      missingJobCount: coveragePlan.jobs.length,
      exportReady: pendingJobs.length === 0 && failedJobs.length === 0,
      fullyTemplateCovered: coveragePlan.jobs.length === 0
    },
    missingAnimationJobs: coveragePlan.jobs,
    provenance: normalizeProvenance({
      source: 'pixellab-character-export-packet',
      rights: input.rights || 'user-owned-pixellab-export; verify project/license before shipping',
      createdBy: input.createdBy || 'pixellab.ai',
      generatedWith: 'pixellab-mcp',
      notes: input.notes || 'Download the export packet, validate it with Pixel Forge, then commit only reviewed game-ready outputs.'
    })
  };
}

export function buildPixelLabAnimationJobPlan(input = {}) {
  const directions = normalizeDirections(input.directions);
  const templates = normalizeTemplateSelection(input);
  const characters = Array.isArray(input.characters) ? input.characters : [];
  const jobs = [];

  for (const character of characters) {
    const characterId = String(character.characterId || character.id || '').trim();
    const displayName = String(character.displayName || character.name || characterId || 'PixelLab Character');
    const completedAnimations = normalizeCompletedAnimations(character.completedAnimations || character.animations);
    for (const template of templates) {
      const missingDirections = directions.filter((direction) => !hasCompletedTemplate(completedAnimations, template.templateAnimationId, direction));
      if (missingDirections.length === 0) continue;
      jobs.push({
        characterId,
        variantId: normalizeVariantId(character.variantId || displayName),
        displayName,
        slot: template.slot,
        templateAnimationId: template.templateAnimationId,
        mode: 'template',
        frameCount: template.frameCount,
        loop: template.loop,
        directions: missingDirections
      });
    }
  }

  const commands = jobs.map((job) => `animate_character(character_id="${escapeCommandString(job.characterId)}", template_animation_id="${escapeCommandString(job.templateAnimationId)}", mode="template", directions=${JSON.stringify(job.directions)})`);
  return {
    schemaVersion: 'prismtek-pixellab-animation-job-plan-v1',
    provider: 'pixellab.ai',
    directions,
    templates,
    jobs,
    commands,
    safety: {
      requiresGenerationBudgetConfirmation: true,
      doNotCommitSecrets: true,
      pollWithGetCharacterBeforeDownload: true
    }
  };
}

function normalizeAnimation(animation = {}, grid) {
  const id = normalizeAnimationName(animation.id);
  const frameIndexes = Array.isArray(animation.frameIndexes)
    ? animation.frameIndexes
    : Array.isArray(animation.frames)
      ? animation.frames.map((frame) => typeof frame === 'number' ? frame : frame.index).filter(Number.isInteger)
      : [];
  const errors = [];
  const warnings = [];
  if (!CANONICAL_ANIMATION_SLOTS.includes(id)) warnings.push(`Animation '${id}' is not in the canonical Buddy slot list yet.`);
  if (frameIndexes.length === 0) errors.push(`Animation '${id}' has no frames.`);
  const frames = frameIndexes.map((index, order) => {
    const safeIndex = toInteger(index, -1);
    const sourceFrame = grid.frames.find((frame) => frame.index === safeIndex);
    if (!sourceFrame) {
      errors.push(`Animation '${id}' references missing frame index ${safeIndex}.`);
      return null;
    }
    return { index: safeIndex, order, row: sourceFrame.row, column: sourceFrame.column, x: sourceFrame.x, y: sourceFrame.y, durationMs: toInteger(animation.durationMs, Math.round(1000 / toInteger(animation.fps, 8))) };
  }).filter(Boolean);
  return { errors, warnings, value: { id, fps: clamp(toInteger(animation.fps, 8), 1, 30), loop: animation.loop !== false, frames, tags: Array.isArray(animation.tags) ? animation.tags.map(String) : [] } };
}

function normalizeProvenance(input = {}) {
  return {
    source: String(input.source || 'original-prismtek-or-user-provided'),
    rights: String(input.rights || 'must-be-original-or-explicitly-licensed-before-shipping'),
    createdBy: String(input.createdBy || 'prismtek-pixel-forge'),
    generatedWith: input.generatedWith ? String(input.generatedWith) : undefined,
    notes: input.notes ? String(input.notes) : 'No third-party assets may be shipped without review.'
  };
}

function sanitizeIdentifier(value, separator) {
  const source = String(value ?? '').trim().toLowerCase();
  let output = '';
  let pendingSeparator = false;
  for (const character of source) {
    const code = character.charCodeAt(0);
    const isDigit = code >= 48 && code <= 57;
    const isLower = code >= 97 && code <= 122;
    if (isDigit || isLower) {
      if (pendingSeparator && output.length > 0) output += separator;
      output += character;
      pendingSeparator = false;
    } else {
      pendingSeparator = output.length > 0;
    }
  }
  return output;
}

function normalizeDirections(input) {
  const mode = String(input ?? '').trim().toLowerCase();
  if (input === 4 || mode === '4' || mode === '4dir' || mode === '4-direction') return [...PIXELLAB_CARDINAL_DIRECTIONS];
  if (input === 8 || mode === '8' || mode === '8dir' || mode === '8-direction') return [...PIXELLAB_STANDARD_DIRECTIONS];
  const directions = Array.isArray(input) && input.length > 0 ? input : PIXELLAB_STANDARD_DIRECTIONS;
  const seen = new Set();
  return directions
    .map((direction) => String(direction || '').trim().toLowerCase())
    .filter((direction) => PIXELLAB_STANDARD_DIRECTIONS.includes(direction))
    .filter((direction) => {
      if (seen.has(direction)) return false;
      seen.add(direction);
      return true;
    });
}

function normalizePixelLabSize(input) {
  const size = input.size && typeof input.size === 'object' ? input.size : {};
  return {
    width: toInteger(size.width ?? input.width, DEFAULT_FRAME_SIZE),
    height: toInteger(size.height ?? input.height, DEFAULT_FRAME_SIZE)
  };
}

function buildPixelLabCharacterDownloadUrl(characterId) {
  return characterId ? `https://api.pixellab.ai/mcp/characters/${encodeURIComponent(characterId)}/download` : '';
}

function normalizeTemplateSelection(input = {}) {
  if (Array.isArray(input.templates) && input.templates.length > 0) {
    return input.templates.map(normalizePixelLabTemplate).filter(Boolean);
  }
  return listPixelLabAnimationTemplates({ slots: input.templateSlots });
}

function normalizePixelLabTemplate(template = {}) {
  const templateAnimationId = String(template.templateAnimationId || template.id || '').trim();
  if (!templateAnimationId) return null;
  return {
    slot: normalizeAnimationName(template.slot || templateAnimationId),
    templateAnimationId,
    frameCount: toInteger(template.frameCount, 8),
    loop: template.loop !== false,
    purpose: template.purpose ? String(template.purpose) : undefined,
    provider: 'pixellab.ai',
    mode: 'template'
  };
}

function normalizeCompletedAnimations(input) {
  if (!Array.isArray(input)) return [];
  return input.map((animation) => {
    if (typeof animation === 'string') {
      return { templateAnimationId: animation.trim(), direction: undefined, frameCount: undefined };
    }
    const templateAnimationId = String(animation.templateAnimationId || animation.id || animation.name || '').trim();
    const direction = animation.direction ? String(animation.direction).trim().toLowerCase() : undefined;
    const directions = Array.isArray(animation.directions)
      ? normalizeDirections(animation.directions)
      : direction
        ? [direction]
        : [];
    return {
      templateAnimationId,
      slot: animation.slot ? normalizeAnimationName(animation.slot) : undefined,
      direction,
      directions,
      frameCount: animation.frameCount === undefined ? undefined : toInteger(animation.frameCount, 0),
      source: animation.source ? String(animation.source) : undefined
    };
  }).filter((animation) => animation.templateAnimationId);
}

function normalizeJobList(input) {
  if (!Array.isArray(input)) return [];
  return input.map((job) => typeof job === 'string' ? { description: job } : { ...job });
}

function hasCompletedTemplate(completedAnimations, templateAnimationId, direction) {
  return completedAnimations.some((animation) => {
    if (animation.templateAnimationId !== templateAnimationId) return false;
    if (animation.direction === direction) return true;
    if (animation.directions?.includes(direction)) return true;
    return !animation.direction && (!animation.directions || animation.directions.length === 0);
  });
}

function escapeCommandString(value) {
  return String(value).replaceAll('\\', '\\\\').replaceAll('"', '\\"');
}

function toInteger(value, fallback) {
  const parsed = Number.parseInt(String(value ?? ''), 10);
  return Number.isFinite(parsed) ? parsed : fallback;
}

function clamp(value, min, max) {
  return Math.max(min, Math.min(max, value));
}
