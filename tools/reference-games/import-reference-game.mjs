#!/usr/bin/env node
import { spawnSync } from 'node:child_process';
import { existsSync, mkdirSync, readFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const repoRoot = join(__dirname, '..', '..');
const manifestPath = join(repoRoot, 'data', 'reference-games', 'open-source-reference-games.json');
const manifest = JSON.parse(readFileSync(manifestPath, 'utf8'));
const id = process.argv[2];

if (!id) {
  console.error('Usage: node tools/reference-games/import-reference-game.mjs <reference-id>');
  console.error('Available references:');
  for (const reference of manifest.references) {
    if (reference.url.endsWith('.git')) console.error(`  - ${reference.id}`);
  }
  process.exit(1);
}

const reference = manifest.references.find((entry) => entry.id === id);
if (!reference) {
  console.error(`Unknown reference id: ${id}`);
  process.exit(1);
}

if (!reference.url.endsWith('.git')) {
  console.error(`Reference is not a git checkout target: ${id}`);
  console.error(`Open manually: ${reference.url}`);
  process.exit(1);
}

const root = join(repoRoot, manifest.defaultPolicy.importPath);
const target = join(root, id);
mkdirSync(root, { recursive: true });

if (existsSync(target)) {
  console.log(`Reference already exists: ${target}`);
  process.exit(0);
}

console.log(`Importing ${reference.name} into ${target}`);
const result = spawnSync('git', ['clone', '--depth', '1', reference.url, target], {
  stdio: 'inherit',
});

if (result.status !== 0) {
  process.exit(result.status ?? 1);
}

console.log('\nImported local reference checkout.');
console.log(`Status: ${reference.status}`);
console.log(`Observed license: ${reference.licenseObserved}`);
console.log('\nThis checkout is ignored by git. Review exact file licenses before copying anything into Prismtek-owned paths.');
