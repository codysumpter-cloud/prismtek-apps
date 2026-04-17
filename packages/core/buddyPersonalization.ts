export type BuddyRenderMode = 'ascii' | 'pixel';
export type BuddyPerformancePreset = 'balanced' | 'fast' | 'deliberate' | 'expressive' | 'quiet';
export type BuddyAnimationTrigger = 'idle' | 'tap' | 'chat' | 'thinking' | 'working' | 'celebrate' | 'sleep';

export interface BuddyAppearancePalette {
  primary: string;
  secondary: string;
  accent: string;
  outline?: string;
  background?: string;
}

export interface BuddyAppearanceProfile {
  displayName: string;
  renderMode: BuddyRenderMode;
  archetype: string;
  bodyStyle: string;
  faceStyle: string;
  eyeStyle?: string;
  accessoryStyle?: string;
  palette: BuddyAppearancePalette;
  scale: 'compact' | 'standard' | 'large';
  pixelGrid?: {
    width: number;
    height: number;
    frameCount: number;
  };
  asciiLayout?: {
    width: number;
    height: number;
    frameCount: number;
  };
}

export interface BuddyBehaviorProfile {
  preset: BuddyPerformancePreset;
  responseStyle: 'concise' | 'balanced' | 'detailed';
  initiative: number;
  strictness: number;
  warmth: number;
  speedBias: number;
  creativityBias: number;
  verificationBias: number;
  animationIntensity: number;
}

export interface BuddyAsciiFrame {
  type: 'ascii';
  trigger: BuddyAnimationTrigger;
  frameIndex: number;
  content: string;
}

export interface BuddyPixelCell {
  x: number;
  y: number;
  color: string;
}

export interface BuddyPixelFrame {
  type: 'pixel';
  trigger: BuddyAnimationTrigger;
  frameIndex: number;
  width: number;
  height: number;
  cells: BuddyPixelCell[];
}

export type BuddyAnimationFrame = BuddyAsciiFrame | BuddyPixelFrame;

export interface BuddyAnimationPack {
  renderMode: BuddyRenderMode;
  fps: number;
  loopTriggers: BuddyAnimationTrigger[];
  frames: BuddyAnimationFrame[];
}

export interface BuddyGuidedPromptStep {
  id: string;
  title: string;
  prompt: string;
  helpText?: string;
  required: boolean;
}

export interface BuddyGuidedPromptFlow {
  flowId: string;
  renderMode: BuddyRenderMode;
  steps: BuddyGuidedPromptStep[];
}

export interface BuddyGenerationRequest {
  renderMode: BuddyRenderMode;
  guidedPromptAnswers: Record<string, string>;
  appearance: BuddyAppearanceProfile;
  behavior: BuddyBehaviorProfile;
}

export interface BuddyGenerationResult {
  appearance: BuddyAppearanceProfile;
  behavior: BuddyBehaviorProfile;
  animationPack: BuddyAnimationPack;
  generationNotes: string[];
  warnings: string[];
}

export interface BuddyPersonalizationRecord {
  buddyId: string;
  appearance: BuddyAppearanceProfile;
  behavior: BuddyBehaviorProfile;
  animationPack?: BuddyAnimationPack;
  updatedAt: string;
}
