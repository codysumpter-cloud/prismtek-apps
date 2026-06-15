#!/usr/bin/env node
import assert from 'node:assert/strict';
import {
  computeDualScreenLayout,
  layoutToCssVariables
} from '../../packages/prismtek-dual-screen-runtime/src/index.js';

const single = computeDualScreenLayout({ width: 960, height: 540 });
assert.equal(single.mode, 'single');
assert.equal(single.bottom, null);

const stacked = computeDualScreenLayout({ width: 640, height: 960 });
assert.equal(stacked.mode, 'stacked-ds');
assert.ok(stacked.bottom.height > 0);

const preferred = computeDualScreenLayout({ width: 640, height: 960, preferredMode: 'rgds-dual' });
assert.equal(preferred.mode, 'rgds-dual');
assert.ok(preferred.bottom.height > 0);

const native = computeDualScreenLayout({
  nativeDisplay: {
    mode: 'external-display',
    top: { x: 0, y: 0, width: 640, height: 480 },
    bottom: { x: 0, y: 480, width: 640, height: 480 }
  }
});
assert.equal(native.mode, 'external-display');
assert.equal(native.top.height, 480);
assert.equal(native.bottom.height, 480);

const cssVars = layoutToCssVariables(stacked);
assert.equal(cssVars['--prismtek-display-mode'], 'stacked-ds');
assert.ok(cssVars['--prismtek-top-width'].endsWith('px'));
assert.ok(cssVars['--prismtek-bottom-height'].endsWith('px'));

console.log('Dual-screen runtime smoke test OK.');
