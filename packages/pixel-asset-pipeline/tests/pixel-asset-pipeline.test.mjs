import test from 'node:test';
import assert from 'node:assert/strict';
import {
  buildAnimationManifest,
  buildGenerationPrompt,
  buildPixelLabAnimationJobPlan,
  buildPixelLabCharacterExportDescriptor,
  buildProviderJob,
  listPixelLabAnimationTemplates,
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

test('normalizes repeated separators without regex backtracking risk', () => {
  const noisyAnimation = `Magic${'_'.repeat(2500)}Cast`;
  const noisyVariant = ` Buddy ${'-'.repeat(2500)} Export Packet `;
  assert.equal(normalizeAnimationName(noisyAnimation), 'cast');
  assert.equal(normalizeVariantId(noisyVariant), 'buddy-export-packet');
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

test('builds a repeatable PixelLab character export descriptor', () => {
  const descriptor = buildPixelLabCharacterExportDescriptor({
    characterId: 'a0bf4028-6285-4cec-870c-8723b5fedbed',
    displayName: 'Female Character Blue Hoodie',
    size: { width: 124, height: 124 },
    completedAnimations: []
  });

  assert.equal(descriptor.schemaVersion, 'prismtek-pixellab-character-export-v1');
  assert.equal(descriptor.variantId, 'female-character-blue-hoodie');
  assert.equal(descriptor.provider.characterId, 'a0bf4028-6285-4cec-870c-8723b5fedbed');
  assert.equal(descriptor.download.url, 'https://api.pixellab.ai/mcp/characters/a0bf4028-6285-4cec-870c-8723b5fedbed/download');
  assert.equal(descriptor.directions.length, 8);
  assert.equal(descriptor.templatePack.templates[0].slot, 'idle');
  assert.equal(descriptor.provenance.rights, 'user-owned-pixellab-export; verify project/license before shipping');
});

test('supports four-direction PixelLab source sprites without inventing diagonals', () => {
  const descriptor = buildPixelLabCharacterExportDescriptor({
    characterId: '89cc0912-2dfc-4b84-9c50-d9eb51cbd30e',
    displayName: 'BMO',
    directions: 4,
    size: { width: 68, height: 68 }
  });
  const plan = buildPixelLabAnimationJobPlan({
    characters: [descriptor],
    directions: 4,
    templateSlots: ['idle']
  });

  assert.deepEqual(descriptor.directions, ['south', 'east', 'north', 'west']);
  assert.equal(plan.jobs.length, 1);
  assert.deepEqual(plan.jobs[0].directions, ['south', 'east', 'north', 'west']);
});

test('builds PixelLab animation jobs only for missing reusable templates', () => {
  const plan = buildPixelLabAnimationJobPlan({
    characters: [
      {
        characterId: '7a14aefe-6c41-4290-ba26-a149d93725fb',
        displayName: 'Buddy',
        completedAnimations: [
          { templateAnimationId: 'breathing-idle', direction: 'south' },
          { templateAnimationId: 'walking-8-frames', direction: 'south' }
        ]
      },
      {
        characterId: '90611122-97c7-4b92-acd9-db41084445e9',
        displayName: 'Ponytail Guy',
        completedAnimations: []
      }
    ],
    directions: ['south'],
    templateSlots: ['idle', 'walk']
  });

  assert.equal(plan.schemaVersion, 'prismtek-pixellab-animation-job-plan-v1');
  assert.equal(plan.jobs.length, 2);
  assert.deepEqual(plan.jobs.map((job) => [job.characterId, job.templateAnimationId]), [
    ['90611122-97c7-4b92-acd9-db41084445e9', 'breathing-idle'],
    ['90611122-97c7-4b92-acd9-db41084445e9', 'walking-8-frames']
  ]);
  assert.equal(plan.commands[0], 'animate_character(character_id="90611122-97c7-4b92-acd9-db41084445e9", template_animation_id="breathing-idle", mode="template", directions=["south"])');
});

test('lists reusable PixelLab template slots for the core game pack', () => {
  const templates = listPixelLabAnimationTemplates({ slots: ['idle', 'walk', 'hurt'] });
  assert.deepEqual(templates.map((template) => template.templateAnimationId), [
    'breathing-idle',
    'walking-8-frames',
    'taking-punch'
  ]);
});
