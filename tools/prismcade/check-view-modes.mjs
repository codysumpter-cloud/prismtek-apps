#!/usr/bin/env node
import { existsSync, readFileSync } from 'node:fs';
import path from 'node:path';
import process from 'node:process';

const repoRoot = process.cwd();
const viewModesPath = path.join(repoRoot, 'data/prismcade/view-modes.json');
const prismtekManifestPath = path.join(repoRoot, 'packages/game-assets/characters/prismtek-fixed-hair/manifest.prismcade-character.json');

function readJson(filePath) {
  return JSON.parse(readFileSync(filePath, 'utf8'));
}

function fail(message) {
  console.error(`view-modes validation failed: ${message}`);
  process.exitCode = 1;
}

function ensureArray(value, label) {
  if (!Array.isArray(value) || value.length === 0) {
    fail(`${label} must be a non-empty array.`);
    return [];
  }
  return value;
}

if (!existsSync(viewModesPath)) {
  fail(`missing ${path.relative(repoRoot, viewModesPath)}`);
} else {
  const config = readJson(viewModesPath);
  if (config.schemaVersion !== 'prismcade-view-modes-v0') {
    fail('schemaVersion must be prismcade-view-modes-v0.');
  }

  const modes = ensureArray(config.viewModes, 'viewModes');
  const ids = new Set();

  for (const mode of modes) {
    if (!mode.id) fail('every view mode needs an id.');
    if (ids.has(mode.id)) fail(`duplicate view mode id ${mode.id}.`);
    ids.add(mode.id);

    ensureArray(mode.gameFamilies, `${mode.id}.gameFamilies`);
    ensureArray(mode.requiredCharacterViews, `${mode.id}.requiredCharacterViews`);
    ensureArray(mode.requiredSlots, `${mode.id}.requiredSlots`);

    if (!Array.isArray(mode.defaultRuntimeSize) || mode.defaultRuntimeSize.length !== 2) {
      fail(`${mode.id}.defaultRuntimeSize must be [width, height].`);
    }
  }

  for (const requiredMode of ['side', 'top_down', 'low_top_down', 'isometric', 'profile_lobby']) {
    if (!ids.has(requiredMode)) fail(`missing required view mode ${requiredMode}.`);
  }
}

if (!existsSync(prismtekManifestPath)) {
  fail(`missing ${path.relative(repoRoot, prismtekManifestPath)}`);
} else {
  const manifest = readJson(prismtekManifestPath);
  const variants = manifest.viewVariants ?? {};
  if (!variants.side) fail('prismtek-fixed-hair manifest must declare viewVariants.side.');
  if (!variants.profile) fail('prismtek-fixed-hair manifest must declare viewVariants.profile fallback.');
  if (!variants.lobby) fail('prismtek-fixed-hair manifest must declare viewVariants.lobby fallback.');
  if (variants.side && !Array.isArray(variants.side.runtimeSizes)) {
    fail('viewVariants.side.runtimeSizes must list available runtime sizes.');
  }
}

if (!process.exitCode) {
  console.log('view-modes validation passed.');
}
