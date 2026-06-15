#!/usr/bin/env node
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { validateDualScreenGameConfig } from '../../packages/prismtek-dual-screen-runtime/src/index.js';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.resolve(__dirname, '..', '..');
const configPaths = [
  'games/pixel-fruit-arena/platforms/android-dual-screen.json',
  'games/tamernet-battle-sandbox/platforms/android-dual-screen.json',
  'games/spin-street-showdown/platforms/android-dual-screen.json'
];

let failed = false;

for (const relativePath of configPaths) {
  const absolutePath = path.join(repoRoot, relativePath);
  if (!fs.existsSync(absolutePath)) {
    console.error(`missing: ${relativePath}`);
    failed = true;
    continue;
  }

  let config;
  try {
    config = JSON.parse(fs.readFileSync(absolutePath, 'utf8'));
  } catch (error) {
    console.error(`invalid JSON: ${relativePath}: ${error.message}`);
    failed = true;
    continue;
  }

  const result = validateDualScreenGameConfig(config);
  if (!result.ok) {
    console.error(`invalid config: ${relativePath}`);
    for (const error of result.errors) {
      console.error(`  - ${error}`);
    }
    failed = true;
    continue;
  }

  console.log(`ok: ${config.gameId} -> ${relativePath}`);
}

if (failed) {
  process.exit(1);
}

console.log(`Dual-screen game config validation OK: ${configPaths.length} game(s).`);
