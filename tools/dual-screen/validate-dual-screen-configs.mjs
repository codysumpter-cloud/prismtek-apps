#!/usr/bin/env node
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';

const files = [
  'games/pixel-fruit-arena/platforms/android-dual-screen.json',
  'games/tamernet-battle-sandbox/platforms/android-dual-screen.json',
  'games/spin-street-showdown/platforms/android-dual-screen.json'
];

for (const file of files) {
  const config = JSON.parse(readFileSync(file, 'utf8'));
  assert.ok(config.gameId, `${file} needs gameId`);
  assert.ok(config.displayName, `${file} needs displayName`);
  assert.ok(config.preferredLayout, `${file} needs preferredLayout`);
  console.log(`ok: ${file}`);
}

console.log(`Dual-screen config validation OK: ${files.length} game(s).`);
