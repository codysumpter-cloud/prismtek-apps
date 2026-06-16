#!/usr/bin/env node
import { spawnSync } from 'node:child_process';
import { existsSync, mkdirSync } from 'node:fs';
import { join } from 'node:path';

const references = {
  'trex-runner-ds': 'https://github.com/Fewnity/T-Rex-Runner-Game-Nintendo-DS.git',
  'terrariads': 'https://github.com/AzizBgBoss/TerrariaDS.git',
  'minicraft-ds-edition': 'https://github.com/ArthurCose/Minicraft-DS-Edition.git',
};

const [, , name] = process.argv;

if (!name || !references[name]) {
  console.error('Usage: node tools/ds-homebrew-kit/import-third-party-ds-reference.mjs <name>');
  console.error('Available references:');
  for (const key of Object.keys(references)) console.error(`  - ${key}`);
  process.exit(1);
}

const root = join(process.cwd(), '.external', 'ds-homebrew-references');
const target = join(root, name);
mkdirSync(root, { recursive: true });

if (existsSync(target)) {
  console.log(`Reference already exists: ${target}`);
  process.exit(0);
}

const result = spawnSync('git', ['clone', '--depth', '1', references[name], target], {
  stdio: 'inherit',
});

if (result.status !== 0) {
  process.exit(result.status ?? 1);
}

console.log('\nImported local research reference:');
console.log(`  ${target}`);
console.log('\nThis checkout is ignored by git. Review the source license before copying any files into Prismtek-owned paths.');
