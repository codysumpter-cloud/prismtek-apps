import {
  BuddyAnimationPack,
  BuddyAnimationTrigger,
  BuddyAppearancePalette,
  BuddyAppearanceProfile,
  BuddyBehaviorProfile,
  BuddyGenerationRequest,
  BuddyGenerationResult,
  BuddyGuidedPromptFlow,
  BuddyPixelCell,
} from './buddyPersonalization';

const DEFAULT_PALETTE: BuddyAppearancePalette = {
  primary: '#7BE0AD',
  secondary: '#214B43',
  accent: '#F8E16C',
  outline: '#0B1F1A',
  background: '#08120F',
};

export const buddyGuidedPromptFlows: Record<'ascii' | 'pixel', BuddyGuidedPromptFlow> = {
  ascii: {
    flowId: 'buddy-guided-ascii-v1',
    renderMode: 'ascii',
    steps: [
      { id: 'role', title: 'Role', prompt: 'What should this Buddy help with?', required: true },
      { id: 'mood', title: 'Mood', prompt: 'What emotional vibe should the Buddy give off?', required: true },
      { id: 'shape', title: 'Shape', prompt: 'Should the Buddy feel round, sharp, tiny, tall, cozy, or chaotic?', required: true },
      { id: 'accessory', title: 'Accessory', prompt: 'Any hat, tool, antenna, scarf, or icon?', required: false },
      { id: 'style', title: 'Speech style', prompt: 'Should it feel calm, playful, strict, fast, or warm?', required: true },
    ],
  },
  pixel: {
    flowId: 'buddy-guided-pixel-v1',
    renderMode: 'pixel',
    steps: [
      { id: 'role', title: 'Role', prompt: 'What is this Buddy for?', required: true },
      { id: 'palette', title: 'Palette', prompt: 'Choose a palette mood: forest, candy, cyber, sunset, ocean, mono.', required: true },
      { id: 'body', title: 'Body style', prompt: 'Should the Buddy be blob, cat, bot, slime, ghost, or mascot?', required: true },
      { id: 'accessory', title: 'Accessory', prompt: 'Pick an accessory or leave blank.', required: false },
      { id: 'energy', title: 'Energy', prompt: 'Should the animation feel subtle, lively, or dramatic?', required: true },
    ],
  },
};

export function defaultBuddyAppearance(renderMode: 'ascii' | 'pixel'): BuddyAppearanceProfile {
  return {
    displayName: 'Buddy',
    renderMode,
    archetype: renderMode === 'ascii' ? 'companion-terminal' : 'pixel-mascot',
    bodyStyle: renderMode === 'ascii' ? 'round' : 'blob',
    faceStyle: 'friendly',
    eyeStyle: 'bright',
    accessoryStyle: 'none',
    palette: DEFAULT_PALETTE,
    scale: 'standard',
    asciiLayout: renderMode === 'ascii' ? { width: 14, height: 6, frameCount: 2 } : undefined,
    pixelGrid: renderMode === 'pixel' ? { width: 12, height: 12, frameCount: 2 } : undefined,
  };
}

export function defaultBuddyBehavior(preset: BuddyBehaviorProfile['preset'] = 'balanced'): BuddyBehaviorProfile {
  const base: Record<BuddyBehaviorProfile['preset'], BuddyBehaviorProfile> = {
    balanced: { preset: 'balanced', responseStyle: 'balanced', initiative: 50, strictness: 50, warmth: 60, speedBias: 50, creativityBias: 50, verificationBias: 60, animationIntensity: 50 },
    fast: { preset: 'fast', responseStyle: 'concise', initiative: 75, strictness: 45, warmth: 50, speedBias: 80, creativityBias: 40, verificationBias: 45, animationIntensity: 65 },
    deliberate: { preset: 'deliberate', responseStyle: 'detailed', initiative: 40, strictness: 70, warmth: 55, speedBias: 25, creativityBias: 35, verificationBias: 85, animationIntensity: 30 },
    expressive: { preset: 'expressive', responseStyle: 'balanced', initiative: 65, strictness: 35, warmth: 80, speedBias: 55, creativityBias: 80, verificationBias: 35, animationIntensity: 85 },
    quiet: { preset: 'quiet', responseStyle: 'concise', initiative: 30, strictness: 55, warmth: 45, speedBias: 35, creativityBias: 40, verificationBias: 70, animationIntensity: 20 },
  };
  return { ...base[preset] };
}

export function materializeBuddyGeneration(request: BuddyGenerationRequest): BuddyGenerationResult {
  const appearance = normalizeAppearance(request.appearance);
  const behavior = clampBehavior(request.behavior);
  const animationPack = appearance.renderMode === 'ascii'
    ? createAsciiAnimationPack(appearance, behavior)
    : createPixelAnimationPack(appearance, behavior);

  const warnings: string[] = [];
  if (appearance.renderMode === 'pixel' && (appearance.pixelGrid?.width ?? 0) > 16) {
    warnings.push('Large pixel grids may animate slowly on older devices.');
  }
  if (behavior.animationIntensity > 80) {
    warnings.push('High animation intensity may trade battery life for personality.');
  }

  return {
    appearance,
    behavior,
    animationPack,
    generationNotes: [
      `Generated ${appearance.renderMode} Buddy preview for ${appearance.displayName}.`,
      `Behavior preset: ${behavior.preset}.`,
      `Animation triggers: ${animationPack.loopTriggers.join(', ')}.`,
    ],
    warnings,
  };
}

export function createAsciiAnimationPack(appearance: BuddyAppearanceProfile, behavior: BuddyBehaviorProfile): BuddyAnimationPack {
  const name = appearance.displayName || 'Buddy';
  const accessory = appearance.accessoryStyle && appearance.accessoryStyle !== 'none' ? appearance.accessoryStyle : '';
  const blinkEyes = behavior.warmth >= 60 ? '^  ^' : 'o  o';
  const workEyes = behavior.strictness >= 60 ? '>  <' : 'o  O';
  const frames = [
    {
      type: 'ascii' as const,
      trigger: 'idle' as BuddyAnimationTrigger,
      frameIndex: 0,
      content: [
        `   /\\   ${accessory}`.trimEnd(),
        ` < ${blinkEyes} >`,
        ' /|  v |\\',
        ' /_|____|_\\',
        `   ${name.slice(0, 8)}`,
      ].join('\n'),
    },
    {
      type: 'ascii' as const,
      trigger: 'working' as BuddyAnimationTrigger,
      frameIndex: 1,
      content: [
        `   /\\  ##`,
        ` < ${workEyes} >`,
        ' /| [*]|\\',
        ' /_|____|_\\',
        `   ${name.slice(0, 8)}`,
      ].join('\n'),
    },
    {
      type: 'ascii' as const,
      trigger: 'celebrate' as BuddyAnimationTrigger,
      frameIndex: 2,
      content: [
        ' ** /\\ **',
        ' < ^  ^ >',
        ' /| {*}|\\',
        ' /_|____|_\\',
        `   ${name.slice(0, 8)}`,
      ].join('\n'),
    },
  ];

  return {
    renderMode: 'ascii',
    fps: behavior.animationIntensity >= 70 ? 4 : 2,
    loopTriggers: ['idle', 'working'],
    frames,
  };
}

export function createPixelAnimationPack(appearance: BuddyAppearanceProfile, behavior: BuddyBehaviorProfile): BuddyAnimationPack {
  const width = appearance.pixelGrid?.width ?? 12;
  const height = appearance.pixelGrid?.height ?? 12;
  const primary = appearance.palette.primary;
  const secondary = appearance.palette.secondary;
  const accent = appearance.palette.accent;

  const idleCells = buildPixelBuddyCells(width, height, primary, secondary, accent, 0);
  const bounceCells = buildPixelBuddyCells(width, height, primary, secondary, accent, behavior.animationIntensity >= 60 ? 1 : 0);
  const celebrateCells = buildPixelBuddyCells(width, height, accent, primary, secondary, 0, true);

  return {
    renderMode: 'pixel',
    fps: behavior.animationIntensity >= 70 ? 8 : 4,
    loopTriggers: ['idle', 'thinking', 'working'],
    frames: [
      { type: 'pixel', trigger: 'idle', frameIndex: 0, width, height, cells: idleCells },
      { type: 'pixel', trigger: 'working', frameIndex: 1, width, height, cells: bounceCells },
      { type: 'pixel', trigger: 'celebrate', frameIndex: 2, width, height, cells: celebrateCells },
    ],
  };
}

function buildPixelBuddyCells(width: number, height: number, primary: string, secondary: string, accent: string, yOffset: number, celebrate = false): BuddyPixelCell[] {
  const cells: BuddyPixelCell[] = [];
  const centerX = Math.floor(width / 2);
  const centerY = Math.floor(height / 2) + yOffset;

  for (let y = centerY - 3; y <= centerY + 2; y += 1) {
    for (let x = centerX - 3; x <= centerX + 3; x += 1) {
      const edge = x === centerX - 3 || x === centerX + 3 || y === centerY - 3 || y === centerY + 2;
      cells.push({ x, y, color: edge ? secondary : primary });
    }
  }

  cells.push({ x: centerX - 1, y: centerY - 1, color: '#FFFFFF' });
  cells.push({ x: centerX + 1, y: centerY - 1, color: '#FFFFFF' });
  cells.push({ x: centerX - 1, y: centerY, color: secondary });
  cells.push({ x: centerX + 1, y: centerY, color: secondary });
  cells.push({ x: centerX, y: centerY + 1, color: accent });

  if (celebrate) {
    cells.push({ x: centerX - 4, y: centerY - 4, color: accent });
    cells.push({ x: centerX + 4, y: centerY - 4, color: accent });
    cells.push({ x: centerX, y: centerY - 5, color: accent });
  }

  return cells.filter((cell) => cell.x >= 0 && cell.y >= 0 && cell.x < width && cell.y < height);
}

function normalizeAppearance(appearance: BuddyAppearanceProfile): BuddyAppearanceProfile {
  return {
    ...appearance,
    displayName: appearance.displayName.trim() || 'Buddy',
    accessoryStyle: appearance.accessoryStyle?.trim() || 'none',
    palette: {
      primary: appearance.palette.primary || DEFAULT_PALETTE.primary,
      secondary: appearance.palette.secondary || DEFAULT_PALETTE.secondary,
      accent: appearance.palette.accent || DEFAULT_PALETTE.accent,
      outline: appearance.palette.outline || DEFAULT_PALETTE.outline,
      background: appearance.palette.background || DEFAULT_PALETTE.background,
    },
  };
}

function clampBehavior(behavior: BuddyBehaviorProfile): BuddyBehaviorProfile {
  const clamp = (value: number) => Math.max(0, Math.min(100, Math.round(value)));
  return {
    ...behavior,
    initiative: clamp(behavior.initiative),
    strictness: clamp(behavior.strictness),
    warmth: clamp(behavior.warmth),
    speedBias: clamp(behavior.speedBias),
    creativityBias: clamp(behavior.creativityBias),
    verificationBias: clamp(behavior.verificationBias),
    animationIntensity: clamp(behavior.animationIntensity),
  };
}
