const DEFAULT_BREAKPOINTS = Object.freeze({
  minStackedHeight: 700,
  minStackedAspect: 1.2,
  minPaneHeight: 240,
  topRatio: 0.58
});

const DISPLAY_MODES = Object.freeze({
  SINGLE: 'single',
  STACKED_DS: 'stacked-ds',
  FOLDABLE_DS: 'foldable-ds',
  EXTERNAL_DISPLAY: 'external-display',
  RGDS_DUAL: 'rgds-dual'
});

function numberOr(value, fallback) {
  const number = Number(value);
  return Number.isFinite(number) ? number : fallback;
}

function normalizeRect(rect, fallback = {}) {
  return {
    x: numberOr(rect?.x ?? rect?.left, fallback.x ?? 0),
    y: numberOr(rect?.y ?? rect?.top, fallback.y ?? 0),
    width: numberOr(rect?.width, fallback.width ?? 0),
    height: numberOr(rect?.height, fallback.height ?? 0)
  };
}

function sortTopBottom(rects) {
  return [...rects].sort((a, b) => (a.y - b.y) || (a.x - b.x));
}

function segmentsLookStacked(rects) {
  if (rects.length < 2) return false;
  const [first, second] = sortTopBottom(rects);
  const overlapX = Math.min(first.x + first.width, second.x + second.width) - Math.max(first.x, second.x);
  return overlapX > Math.min(first.width, second.width) * 0.5 && second.y >= first.y + first.height - 4;
}

function getWindowSegmentsFromRuntime(runtime) {
  if (Array.isArray(runtime?.segments)) return runtime.segments.map((segment) => normalizeRect(segment));
  if (Array.isArray(runtime?.windowSegments)) return runtime.windowSegments.map((segment) => normalizeRect(segment));
  if (typeof globalThis !== 'undefined' && typeof globalThis.getWindowSegments === 'function') {
    try {
      return globalThis.getWindowSegments().map((segment) => normalizeRect(segment));
    } catch {
      return [];
    }
  }
  return [];
}

function getNativeDisplay(runtime) {
  const fromArgument = runtime?.nativeDisplay ?? runtime?.display;
  const fromWindow = typeof window !== 'undefined'
    ? window.PrismtekDisplay ?? window.PrismtekAndroidDisplay
    : undefined;
  const display = fromArgument ?? fromWindow;
  if (!display) return null;

  const top = display.top ? normalizeRect(display.top) : null;
  const bottom = display.bottom ? normalizeRect(display.bottom) : null;
  if (!top || !bottom) return null;

  return {
    mode: display.mode || DISPLAY_MODES.RGDS_DUAL,
    top,
    bottom,
    hinge: display.hinge ? normalizeRect(display.hinge) : null,
    source: display.source || 'native-bridge'
  };
}

function viewportFromRuntime(runtime) {
  const width = numberOr(runtime?.width, typeof window !== 'undefined' ? window.innerWidth : 960);
  const height = numberOr(runtime?.height, typeof window !== 'undefined' ? window.innerHeight : 540);
  return { width, height };
}

function createSingleLayout(width, height, reason = 'single-screen-fallback') {
  return {
    mode: DISPLAY_MODES.SINGLE,
    top: { x: 0, y: 0, width, height },
    bottom: null,
    hinge: null,
    orientation: width >= height ? 'landscape' : 'portrait',
    reason
  };
}

function createStackedLayout(width, height, options = {}, reason = 'height-allows-stacked-ds-layout') {
  const topRatio = numberOr(options.topRatio, DEFAULT_BREAKPOINTS.topRatio);
  const topHeight = Math.max(
    numberOr(options.minPaneHeight, DEFAULT_BREAKPOINTS.minPaneHeight),
    Math.floor(height * topRatio)
  );
  const clampedTopHeight = Math.min(topHeight, height - numberOr(options.minPaneHeight, DEFAULT_BREAKPOINTS.minPaneHeight));
  return {
    mode: DISPLAY_MODES.STACKED_DS,
    top: { x: 0, y: 0, width, height: clampedTopHeight },
    bottom: { x: 0, y: clampedTopHeight, width, height: height - clampedTopHeight },
    hinge: null,
    orientation: 'portrait',
    reason
  };
}

export function computeDualScreenLayout(runtime = {}, options = {}) {
  const breakpoints = { ...DEFAULT_BREAKPOINTS, ...options.breakpoints };
  const { width, height } = viewportFromRuntime(runtime);
  const preferredMode = runtime.preferredMode ?? options.preferredMode;
  const nativeDisplay = getNativeDisplay(runtime);

  if (nativeDisplay) {
    return {
      mode: nativeDisplay.mode,
      top: nativeDisplay.top,
      bottom: nativeDisplay.bottom,
      hinge: nativeDisplay.hinge,
      orientation: nativeDisplay.top.width >= nativeDisplay.top.height ? 'landscape' : 'portrait',
      reason: nativeDisplay.source
    };
  }

  const segments = getWindowSegmentsFromRuntime(runtime);
  if (segmentsLookStacked(segments)) {
    const [top, bottom] = sortTopBottom(segments);
    return {
      mode: DISPLAY_MODES.FOLDABLE_DS,
      top,
      bottom,
      hinge: runtime.hinge ? normalizeRect(runtime.hinge) : null,
      orientation: 'portrait',
      reason: 'window-segments'
    };
  }

  if (preferredMode === DISPLAY_MODES.STACKED_DS || preferredMode === DISPLAY_MODES.RGDS_DUAL) {
    if (height >= breakpoints.minPaneHeight * 2) {
      return {
        ...createStackedLayout(width, height, breakpoints, `preferred-${preferredMode}`),
        mode: preferredMode === DISPLAY_MODES.RGDS_DUAL ? DISPLAY_MODES.RGDS_DUAL : DISPLAY_MODES.STACKED_DS
      };
    }
    return createSingleLayout(width, height, 'preferred-dual-mode-too-small');
  }

  const aspect = height / Math.max(width, 1);
  if (height >= breakpoints.minStackedHeight && aspect >= breakpoints.minStackedAspect) {
    return createStackedLayout(width, height, breakpoints);
  }

  return createSingleLayout(width, height);
}

export function layoutToCssVariables(layout) {
  const vars = {
    '--prismtek-display-mode': layout.mode,
    '--prismtek-top-x': `${layout.top.x}px`,
    '--prismtek-top-y': `${layout.top.y}px`,
    '--prismtek-top-width': `${layout.top.width}px`,
    '--prismtek-top-height': `${layout.top.height}px`
  };

  if (layout.bottom) {
    vars['--prismtek-bottom-x'] = `${layout.bottom.x}px`;
    vars['--prismtek-bottom-y'] = `${layout.bottom.y}px`;
    vars['--prismtek-bottom-width'] = `${layout.bottom.width}px`;
    vars['--prismtek-bottom-height'] = `${layout.bottom.height}px`;
  }

  if (layout.hinge) {
    vars['--prismtek-hinge-x'] = `${layout.hinge.x}px`;
    vars['--prismtek-hinge-y'] = `${layout.hinge.y}px`;
    vars['--prismtek-hinge-width'] = `${layout.hinge.width}px`;
    vars['--prismtek-hinge-height'] = `${layout.hinge.height}px`;
  }

  return vars;
}

export function applyDualScreenLayout(root, layout) {
  if (!root) return layout;
  root.dataset.displayMode = layout.mode;
  root.dataset.displayReason = layout.reason;
  for (const [name, value] of Object.entries(layoutToCssVariables(layout))) {
    root.style.setProperty(name, value);
  }
  return layout;
}

export function createDualScreenRuntime({ root, preferredMode, breakpoints } = {}) {
  const targetRoot = root ?? (typeof document !== 'undefined' ? document.documentElement : null);

  function update(runtime = {}) {
    const layout = computeDualScreenLayout({ preferredMode, ...runtime }, { breakpoints });
    applyDualScreenLayout(targetRoot, layout);
    return layout;
  }

  if (typeof window !== 'undefined') {
    window.addEventListener('resize', () => update(), { passive: true });
    window.addEventListener('orientationchange', () => update(), { passive: true });
  }

  return {
    modes: DISPLAY_MODES,
    update,
    get current() {
      return update();
    }
  };
}

export function validateDualScreenGameConfig(config) {
  const errors = [];
  const allowedModes = new Set(Object.values(DISPLAY_MODES));

  if (!config || typeof config !== 'object') errors.push('config must be an object');
  if (!config?.gameId) errors.push('gameId is required');
  if (!config?.displayName) errors.push('displayName is required');
  if (!config?.androidPackage) errors.push('androidPackage is required');
  if (!config?.entrypoint) errors.push('entrypoint is required');
  if (!Array.isArray(config?.displayModes) || config.displayModes.length === 0) {
    errors.push('displayModes must include at least one mode');
  } else {
    for (const mode of config.displayModes) {
      if (!allowedModes.has(mode)) errors.push(`unsupported display mode: ${mode}`);
    }
  }
  if (!config?.screens?.top?.role) errors.push('screens.top.role is required');
  if (!config?.screens?.bottom?.role) errors.push('screens.bottom.role is required');
  if (!Array.isArray(config?.verification?.requiredReceipts) || config.verification.requiredReceipts.length === 0) {
    errors.push('verification.requiredReceipts must include at least one receipt');
  }

  return {
    ok: errors.length === 0,
    errors
  };
}

export { DISPLAY_MODES, DEFAULT_BREAKPOINTS };
