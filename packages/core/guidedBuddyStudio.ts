export type GuidedBuddySpecies = 'trex';
export type GuidedBuddyStage = 'egg' | 'baby';
export type GuidedBuddyRenderMode = 'ascii' | 'pixel' | 'both';
export type GuidedBuddyRepairActionId =
  | 'make-more-readable'
  | 'simplify-silhouette'
  | 'bigger-head'
  | 'smaller-details'
  | 're-center-sprite'
  | 'reduce-palette'
  | 'rebuild-idle-frames'
  | 'rebuild-hatch-frames'
  | 'normalize-asset';

export interface GuidedBuddyStudioDraft {
  species: GuidedBuddySpecies;
  stage: GuidedBuddyStage;
  renderMode: GuidedBuddyRenderMode;
  personalityTags: string[];
  paletteId: 'mono-dino-v1' | 'soft-pastel-v1' | 'arcade-bright-v1';
  stylePackIds: {
    ascii?: 'ascii-trex-chibi-v1';
    pixel?: 'pixel-tamagotchi-v1';
  };
}

export interface GuidedBuddyValidationIssue {
  level: 'error' | 'warning';
  code: string;
  message: string;
}

export interface GuidedBuddyQualityScore {
  readability: number;
  silhouette: number;
  animation: number;
  charm: number;
  styleCompliance: number;
  overall: number;
}

export interface GuidedBuddyStudioPreviewContract {
  draft: GuidedBuddyStudioDraft;
  validationIssues: GuidedBuddyValidationIssue[];
  qualityScore: GuidedBuddyQualityScore;
  repairActions: GuidedBuddyRepairActionId[];
  canPreview: boolean;
  canSave: boolean;
  saveGateReason: string;
}

export const GUIDED_BUDDY_STUDIO_STEPS = [
  'choose Buddy type',
  'choose render mode',
  'choose stage',
  'choose personality tags',
  'choose palette/style options',
  'generate preview',
  'run validation',
  'show quality score',
  'offer one-tap repairs',
  'save only compiled valid assets',
] as const;

export const GUIDED_BUDDY_REPAIR_ACTION_LABELS: Record<GuidedBuddyRepairActionId, string> = {
  'make-more-readable': 'Make more readable',
  'simplify-silhouette': 'Simplify silhouette',
  'bigger-head': 'Bigger head',
  'smaller-details': 'Smaller details',
  're-center-sprite': 'Re-center sprite',
  'reduce-palette': 'Reduce palette',
  'rebuild-idle-frames': 'Rebuild idle frames',
  'rebuild-hatch-frames': 'Rebuild hatch frames',
  'normalize-asset': 'Normalize asset',
};

export const DEFAULT_GUIDED_BUDDY_STUDIO_DRAFT: GuidedBuddyStudioDraft = {
  species: 'trex',
  stage: 'baby',
  renderMode: 'both',
  personalityTags: ['curious', 'brave'],
  paletteId: 'mono-dino-v1',
  stylePackIds: {
    ascii: 'ascii-trex-chibi-v1',
    pixel: 'pixel-tamagotchi-v1',
  },
};

function clampScore(value: number): number {
  return Math.max(0, Math.min(1, Number(value.toFixed(3))));
}

function average(values: number[]): number {
  return clampScore(values.reduce((sum, value) => sum + value, 0) / values.length);
}

export function buildGuidedBuddyStudioPreviewContract(
  draft: GuidedBuddyStudioDraft,
): GuidedBuddyStudioPreviewContract {
  const validationIssues: GuidedBuddyValidationIssue[] = [];
  const wantsAscii = draft.renderMode === 'ascii' || draft.renderMode === 'both';
  const wantsPixel = draft.renderMode === 'pixel' || draft.renderMode === 'both';

  if (draft.species !== 'trex') {
    validationIssues.push({
      level: 'error',
      code: 'unsupported_species',
      message: 'Guided Builder V1 only supports T-Rex buddies.',
    });
  }

  if (draft.stage !== 'egg' && draft.stage !== 'baby') {
    validationIssues.push({
      level: 'error',
      code: 'unsupported_stage',
      message: 'Guided Builder V1 only supports egg and baby stages.',
    });
  }

  if (wantsAscii && draft.stylePackIds.ascii !== 'ascii-trex-chibi-v1') {
    validationIssues.push({
      level: 'error',
      code: 'missing_ascii_style_pack',
      message: 'ASCII preview must use ascii-trex-chibi-v1 for this wedge.',
    });
  }

  if (wantsPixel && draft.stylePackIds.pixel !== 'pixel-tamagotchi-v1') {
    validationIssues.push({
      level: 'error',
      code: 'missing_pixel_style_pack',
      message: 'Pixel preview must use pixel-tamagotchi-v1 for this wedge.',
    });
  }

  if (!draft.personalityTags.length) {
    validationIssues.push({
      level: 'warning',
      code: 'missing_personality_tags',
      message: 'Add at least one personality tag so repair and evolution prompts stay guided.',
    });
  }

  const errorCount = validationIssues.filter((issue) => issue.level === 'error').length;
  const warningCount = validationIssues.filter((issue) => issue.level === 'warning').length;
  const stageCharmBoost = draft.stage === 'baby' ? 0.04 : 0.02;
  const dualModeBoost = draft.renderMode === 'both' ? 0.03 : 0;

  const qualityScore: GuidedBuddyQualityScore = {
    readability: clampScore(0.86 - errorCount * 0.2),
    silhouette: clampScore(0.88 - errorCount * 0.2),
    animation: clampScore(0.74 + dualModeBoost - warningCount * 0.05),
    charm: clampScore(0.82 + stageCharmBoost + Math.min(draft.personalityTags.length, 3) * 0.02),
    styleCompliance: clampScore(0.92 - errorCount * 0.25 - warningCount * 0.05),
    overall: 0,
  };
  qualityScore.overall = average([
    qualityScore.readability,
    qualityScore.silhouette,
    qualityScore.animation,
    qualityScore.charm,
    qualityScore.styleCompliance,
  ]);

  const repairActions: GuidedBuddyRepairActionId[] = [
    'make-more-readable',
    'simplify-silhouette',
    'bigger-head',
    'smaller-details',
    're-center-sprite',
    'reduce-palette',
    'rebuild-idle-frames',
    'rebuild-hatch-frames',
    'normalize-asset',
  ];

  return {
    draft,
    validationIssues,
    qualityScore,
    repairActions,
    canPreview: errorCount === 0,
    canSave: false,
    saveGateReason: 'Saving remains disabled until generated candidates pass normalization, validation, scoring, and compilation.',
  };
}
