#!/usr/bin/env node
import { existsSync, readFileSync } from 'node:fs';
import path from 'node:path';
import process from 'node:process';

const repoRoot = process.cwd();

const requiredFiles = [
  'packages/game-assets/characters/prismtek-fixed-hair/identity/identity.json',
  'packages/game-assets/characters/prismtek-fixed-hair/view-variants.json',
  'packages/game-assets/characters/prismtek-fixed-hair/templates/side-template-map.json',
  'packages/game-assets/characters/prismtek-fixed-hair/templates/low-top-down-template-map.json',
  'packages/game-assets/characters/prismtek-fixed-hair/templates/top-down-template-map.json',
  'packages/game-assets/characters/prismtek-fixed-hair/templates/isometric-template-map.json',
  'packages/game-assets/characters/prismtek-fixed-hair/templates/profile-lobby-template-map.json',
  'data/prismcade/view-template-registry.json',
  'data/prismcade/view-retarget-jobs/prismtek-fixed-hair-all-views.json',
  'docs/prismcade/CHARACTER_VIEW_RETARGETING.md',
  'docs/prismcade/TOP_DOWN_CHARACTER_ANIMATION_GUIDE.md'
];

function fail(message) {
  console.error(`view-retargeting validation failed: ${message}`);
  process.exitCode = 1;
}

function readJson(relativePath) {
  return JSON.parse(readFileSync(path.join(repoRoot, relativePath), 'utf8'));
}

for (const relativePath of requiredFiles) {
  if (!existsSync(path.join(repoRoot, relativePath))) {
    fail(`missing ${relativePath}`);
  }
}

if (!process.exitCode) {
  const identity = readJson('packages/game-assets/characters/prismtek-fixed-hair/identity/identity.json');
  if (identity.characterId !== 'prismtek-fixed-hair') fail('identity characterId mismatch.');

  const variants = readJson('packages/game-assets/characters/prismtek-fixed-hair/view-variants.json');
  for (const view of ['side', 'profile', 'lobby', 'low_top_down', 'top_down', 'isometric']) {
    if (!variants.variants?.[view]) fail(`missing view variant ${view}.`);
  }

  const registry = readJson('data/prismcade/view-template-registry.json');
  const templateIds = new Set((registry.templates ?? []).map((template) => template.id));
  for (const requiredTemplate of ['side-compact-chibi-64', 'low-top-down-economy-64', 'top-down-full-8dir-64', 'isometric-diagonal-64', 'profile-lobby-identity-64']) {
    if (!templateIds.has(requiredTemplate)) fail(`missing template registry entry ${requiredTemplate}.`);
  }

  const job = readJson('data/prismcade/view-retarget-jobs/prismtek-fixed-hair-all-views.json');
  if (job.characterId !== 'prismtek-fixed-hair') fail('retarget job characterId mismatch.');
  if (!Array.isArray(job.stages) || job.stages.length < 5) fail('retarget job should describe all major view stages.');
}

if (!process.exitCode) {
  console.log('view-retargeting validation passed.');
}
