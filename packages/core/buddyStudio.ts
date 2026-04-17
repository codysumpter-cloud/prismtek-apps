export const BUDDY_VISUAL_STATES = [
  'idle',
  'happy',
  'thinking',
  'working',
  'sleepy',
  'needs-attention',
] as const;

export type BuddyVisualState = (typeof BUDDY_VISUAL_STATES)[number];
export type BuddyAppearanceOutputMode = 'ascii' | 'pixel' | 'both';
export type BuddyGenerationProvider = 'local-ascii' | 'local-preview' | 'pixellab-api' | 'pixellab-mcp';
export type BuddyApprovalMode = 'suggest' | 'auto_edit' | 'full_auto';

export interface BuddyAsciiFrame {
  id: string;
  content: string;
}

export interface BuddyAsciiFrames {
  width: number;
  height: number;
  fps: number;
  states: Record<BuddyVisualState, BuddyAsciiFrame[]>;
}

export interface BuddyPixelFrameCell {
  x: number;
  y: number;
  color: string;
}

export interface BuddyPixelFrame {
  id: string;
  width: number;
  height: number;
  cells: BuddyPixelFrameCell[];
}

export interface BuddyPixelAssetSet {
  provider: BuddyGenerationProvider;
  width: number;
  height: number;
  transparentBackground: boolean;
  states: Partial<Record<BuddyVisualState, BuddyPixelFrame[]>>;
  warnings?: string[];
}

export interface BuddyAnimationMappingEntry {
  loop: boolean;
  fps: number;
  asciiFrameIds?: string[];
  pixelFrameIds?: string[];
}

export interface BuddyAnimationMapping {
  states: Record<BuddyVisualState, BuddyAnimationMappingEntry>;
}

export interface BuddyVisualStateSet {
  outputMode: BuddyAppearanceOutputMode;
  ascii?: BuddyAsciiFrames;
  pixel?: BuddyPixelAssetSet;
  animation: BuddyAnimationMapping;
}

export interface BuddyAppearancePalette {
  primary: string;
  secondary: string;
  accent: string;
  outline?: string;
  background?: string;
}

export interface BuddyGenerationProviderConfig {
  provider: 'pixellab';
  mode: 'disabled' | 'api' | 'mcp';
  enabled: boolean;
  apiBaseUrl?: string;
  apiKeyEnvVar?: string;
  mcpServerUrl?: string;
  note?: string;
}

export interface BuddyAppearanceProfile {
  id: string;
  buddyId: string;
  displayName: string;
  archetype: string;
  vibe: string;
  paletteName: string;
  palette: BuddyAppearancePalette;
  silhouette: string;
  face: string;
  eyes: string;
  expression: string;
  accessories: string[];
  animationPersonality: string;
  outputMode: BuddyAppearanceOutputMode;
  isDefault: boolean;
  visualStateSet: BuddyVisualStateSet;
  providerConfig?: BuddyGenerationProviderConfig;
  source: {
    generator: BuddyGenerationProvider;
    sourceOfTruth: 'prismtek-apps';
    reusedFrom?: string[];
  };
  createdAt: string;
  updatedAt: string;
}

export interface BuddyAppearanceStudioDraft {
  buddyId: string;
  displayName: string;
  archetype: string;
  vibe: string;
  paletteName: string;
  silhouette: string;
  face: string;
  eyes: string;
  expression: string;
  accessories: string[];
  animationPersonality: string;
  outputMode: BuddyAppearanceOutputMode;
  notes?: string;
}

export interface BuddyAppearanceGenerationResult {
  profile: BuddyAppearanceProfile;
  warnings: string[];
  generationNotes: string[];
}

export interface BmoStackCouncilSeat {
  name: string;
  kind: string;
  status: string;
  surface: string;
  sourceFile: string;
  defaultTrigger?: string;
}

export interface BmoStackFounderRole {
  id: string;
  name: string;
  operatingRole: string;
  objective: string;
  councilMapping: string[];
  memoryFile: string;
  tools: string[];
}

export interface BmoStackModeDefinition {
  id: 'companion' | 'operator';
  label: string;
  summary: string;
  sourceFiles: string[];
}

export interface BmoStackSkillSummary {
  id: string;
  triggers: string[];
  actions: string[];
  defaultAction: string;
}

export interface BmoStackAdapterSnapshot {
  runtimeBase: {
    name: string;
    summary: string;
    sourceFiles: string[];
  };
  modes: BmoStackModeDefinition[];
  council: BmoStackCouncilSeat[];
  founderRoles: BmoStackFounderRole[];
  skills: BmoStackSkillSummary[];
  postureSourceFiles: string[];
}

export interface CodexRunRequest {
  repoPath: string;
  taskBrief: string;
  approvalMode: BuddyApprovalMode;
  targetBranch?: string;
  model?: string;
}

export interface CodexRunSummary {
  runId: string;
  status: string;
  repoPath: string;
  worktreePath: string;
  targetBranch: string | null;
  approvalMode: BuddyApprovalMode;
  model: string | null;
  startedAt: string;
  finishedAt: string | null;
  exitCode: number | null;
  finalAgentMessage: string | null;
  stdoutTail?: string;
  stderrTail?: string;
  nextSteps?: string[];
}

export interface CodexRunResult extends CodexRunSummary {
  brief: string;
  usage?: unknown;
}

export interface BuddyAsciiValidationIssue {
  state: BuddyVisualState;
  frameId: string;
  message: string;
}

export interface BuddyAsciiValidationResult {
  ok: boolean;
  width: number;
  height: number;
  issues: BuddyAsciiValidationIssue[];
}

export const BUDDY_ASCII_MAX_WIDTH = 24;
export const BUDDY_ASCII_MAX_HEIGHT = 8;

export function validateBuddyAsciiFrames(ascii: BuddyAsciiFrames): BuddyAsciiValidationResult {
  const issues: BuddyAsciiValidationIssue[] = [];
  let width = 0;
  let height = 0;

  for (const state of BUDDY_VISUAL_STATES) {
    const frames = ascii.states[state];
    if (!frames?.length) {
      issues.push({ state, frameId: `${state}:missing`, message: 'State must include at least one frame.' });
      continue;
    }

    for (const frame of frames) {
      const lines = frame.content.split('\n');
      const frameWidth = lines.reduce((current, line) => Math.max(current, line.length), 0);
      width = Math.max(width, frameWidth);
      height = Math.max(height, lines.length);

      if (frameWidth > BUDDY_ASCII_MAX_WIDTH) {
        issues.push({
          state,
          frameId: frame.id,
          message: `Frame width ${frameWidth} exceeds ${BUDDY_ASCII_MAX_WIDTH}.`,
        });
      }

      if (lines.length > BUDDY_ASCII_MAX_HEIGHT) {
        issues.push({
          state,
          frameId: frame.id,
          message: `Frame height ${lines.length} exceeds ${BUDDY_ASCII_MAX_HEIGHT}.`,
        });
      }
    }
  }

  return {
    ok: issues.length === 0,
    width,
    height,
    issues,
  };
}

export function defaultPixelLabProviderConfig(): BuddyGenerationProviderConfig {
  return {
    provider: 'pixellab',
    mode: 'disabled',
    enabled: false,
    apiBaseUrl: 'https://api.pixellab.ai',
    apiKeyEnvVar: 'PIXELLAB_API_KEY',
    mcpServerUrl: 'https://api.pixellab.ai/mcp',
    note: 'Optional upgrade path for higher-quality pixel art and sprite generation.',
  };
}
