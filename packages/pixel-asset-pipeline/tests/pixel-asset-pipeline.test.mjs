import test from 'node:test';
import assert from 'node:assert/strict';
import {
  buildAnimationManifest,
  buildGenerationPrompt,
  buildProviderJob,
  normalizeAnimationName,
  normalizeVariantId,
  sliceSpriteSheetGrid,
  validateAnimationManifest,
  validateSpriteSheetGrid
} from '../src/index.mjs';

test('normalizes animation and variant names', () => {
  assert.equal(normalizeAnimationName('Magic Cast!!'), 'cast');
  assert.equal(normalizeAnimationName('MELEE JAB'), 'melee_thrust');
  assert.equal(normalizeVariantId(' BMO 64x64 Rotations!!! '), 'bmo-64x64-rotations');
});

test('validates a clean 64x64 sprite sheet grid', () => {
  const result = validateSpriteSheetGrid({ imageWidth: 256, imageHeight: 128, frameWidth: 64, frameHeight: 64 });
  assert.equal(result.ok, true);
  assert.equal(result.columns, 4);
  assert.equal(result.rows, 2);
  assert.equal(result.frameCount, 8);
  assert.deepEqual(result.errors, []);
});

test('slices sprite sheet frames into exact source rects', () => {
  const result = sliceSpriteSheetGrid({ imageWidth: 128, imageHeight: 128, frameWidth: 64, frameHeight: 64 });
  assert.equal(result.frames.length, 4);
  assert.deepEqual(result.frames[3], { index: 3, row: 1, column: 1, x: 64, y: 64, width: 64, height: 64 });
});

test('surfaces grid leftovers as warnings', () => {
  const result = validateSpriteSheetGrid({ imageWidth: 260, imageHeight: 128, frameWidth: 64, frameHeight: 64 });
  assert.equal(result.ok, true);
  assert.equal(result.leftoverX, 4);
  assert.match(result.warnings.join('\n'), /4px remain horizontally/);
});

test('builds and validates an animation manifest', () => {
  const result = buildAnimationManifest({
    variantId: 'BMO Test',
    displayName: 'BMO Test',
    sheetPath: 'variants/bmo/bmo.png',
    imageWidth: 256,
    imageHeight: 128,
    frameWidth: 64,
    frameHeight: 64,
    animations: [
      { id: 'idle', fps: 8, loop: true, frameIndexes: [0, 1, 2, 3] },
      { id: 'hurt', fps: 12, loop: false, frameIndexes: [4, 5] }
    ],
    provenance: {
      source: 'uploaded-user-bmo-reference',
      rights: 'user-provided-reference; review before shipping',
      createdBy: 'test'
    }
  });

  assert.equal(result.ok, true);
  assert.equal(result.manifest.variantId, 'bmo-test');
  assert.equal(result.manifest.animations.length, 2);
  assert.equal(validateAnimationManifest(result.manifest).ok, true);
});

test('rejects animation frames outside the sheet', () => {
  const result = buildAnimationManifest({
    imageWidth: 64,
    imageHeight: 64,
    frameWidth: 64,
    frameHeight: 64,
    animations: [{ id: 'idle', frameIndexes: [0, 1] }]
  });
  assert.equal(result.ok, false);
  assert.match(result.errors.join('\n'), /missing frame index 1/);
});

test('builds clean provider prompts and jobs', () => {
  const prompt = buildGenerationPrompt({ subject: 'tiny BMO-like Prismtek helper', animationSlots: ['idle', 'melee slash'] });
  assert.match(prompt, /Required animation slots: idle, melee_slash/);
  assert.match(prompt, /Do not copy franchise characters/);

  const job = buildProviderJob({ provider: 'pixellab-compatible', subject: 'original buddy' });
  assert.equal(job.schemaVersion, 'prismtek-pixel-provider-job-v1');
  assert.equal(job.safety.noSecrets, true);
});
