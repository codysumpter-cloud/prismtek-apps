#!/usr/bin/env node
import { readFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const repoRoot = join(__dirname, '..', '..');
const manifestPath = join(repoRoot, 'data', 'reference-games', 'open-source-reference-games.json');
const manifest = JSON.parse(readFileSync(manifestPath, 'utf8'));

const requiredTopLevel = ['schemaVersion', 'purpose', 'defaultPolicy', 'references'];
for (const field of requiredTopLevel) {
  if (!(field in manifest)) throw new Error(`Missing top-level field: ${field}`);
}

if (!Array.isArray(manifest.references) || manifest.references.length === 0) {
  throw new Error('Manifest must include at least one reference.');
}

const ids = new Set();
const requiredReferenceFields = [
  'id',
  'name',
  'url',
  'kind',
  'licenseObserved',
  'status',
  'notes',
];

for (const reference of manifest.references) {
  for (const field of requiredReferenceFields) {
    if (!reference[field] || typeof reference[field] !== 'string') {
      throw new Error(`Reference ${reference.id ?? '<unknown>'} is missing string field: ${field}`);
    }
  }

  if (ids.has(reference.id)) {
    throw new Error(`Duplicate reference id: ${reference.id}`);
  }
  ids.add(reference.id);

  if (!/^https?:\/\//.test(reference.url)) {
    throw new Error(`Reference ${reference.id} must use an http(s) URL.`);
  }
}

console.log(`Validated ${manifest.references.length} reference game entries.`);
