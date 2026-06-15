export type PrismtekDisplayMode =
  | 'single'
  | 'stacked-ds'
  | 'foldable-ds'
  | 'external-display'
  | 'rgds-dual';

export interface PrismtekRect {
  x: number;
  y: number;
  width: number;
  height: number;
}

export interface PrismtekDualScreenLayout {
  mode: PrismtekDisplayMode;
  top: PrismtekRect;
  bottom: PrismtekRect | null;
  hinge: PrismtekRect | null;
  orientation: 'portrait' | 'landscape';
  reason: string;
}

export interface PrismtekDualScreenRuntimeInput {
  width?: number;
  height?: number;
  preferredMode?: PrismtekDisplayMode;
  segments?: PrismtekRect[];
  windowSegments?: PrismtekRect[];
  hinge?: PrismtekRect;
  nativeDisplay?: {
    mode?: PrismtekDisplayMode;
    top: PrismtekRect;
    bottom: PrismtekRect;
    hinge?: PrismtekRect;
    source?: string;
  };
  display?: {
    mode?: PrismtekDisplayMode;
    top: PrismtekRect;
    bottom: PrismtekRect;
    hinge?: PrismtekRect;
    source?: string;
  };
}

export interface PrismtekDualScreenOptions {
  preferredMode?: PrismtekDisplayMode;
  breakpoints?: {
    minStackedHeight?: number;
    minStackedAspect?: number;
    minPaneHeight?: number;
    topRatio?: number;
  };
}

export interface PrismtekDualScreenGameConfig {
  gameId: string;
  displayName: string;
  androidPackage: string;
  entrypoint: string;
  displayModes: PrismtekDisplayMode[];
  screens: {
    top: { role: string; selectors?: string[]; notes?: string[] };
    bottom: { role: string; selectors?: string[]; notes?: string[] };
  };
  controls?: Record<string, unknown>;
  verification: {
    requiredReceipts: string[];
  };
}

export declare const DISPLAY_MODES: Readonly<{
  SINGLE: 'single';
  STACKED_DS: 'stacked-ds';
  FOLDABLE_DS: 'foldable-ds';
  EXTERNAL_DISPLAY: 'external-display';
  RGDS_DUAL: 'rgds-dual';
}>;

export declare const DEFAULT_BREAKPOINTS: Readonly<{
  minStackedHeight: number;
  minStackedAspect: number;
  minPaneHeight: number;
  topRatio: number;
}>;

export declare function computeDualScreenLayout(
  runtime?: PrismtekDualScreenRuntimeInput,
  options?: PrismtekDualScreenOptions
): PrismtekDualScreenLayout;

export declare function layoutToCssVariables(layout: PrismtekDualScreenLayout): Record<string, string>;

export declare function applyDualScreenLayout(root: HTMLElement | null, layout: PrismtekDualScreenLayout): PrismtekDualScreenLayout;

export declare function createDualScreenRuntime(options?: {
  root?: HTMLElement | null;
  preferredMode?: PrismtekDisplayMode;
  breakpoints?: PrismtekDualScreenOptions['breakpoints'];
}): {
  modes: typeof DISPLAY_MODES;
  update(runtime?: PrismtekDualScreenRuntimeInput): PrismtekDualScreenLayout;
  readonly current: PrismtekDualScreenLayout;
};

export declare function validateDualScreenGameConfig(config: PrismtekDualScreenGameConfig): {
  ok: boolean;
  errors: string[];
};
