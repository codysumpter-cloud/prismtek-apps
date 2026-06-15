#!/usr/bin/env node
import { readFileSync } from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const manifestPath = path.resolve(__dirname, 'porting-kits.manifest.json');
const manifest = JSON.parse(readFileSync(manifestPath, 'utf8'));

if (manifest.policy?.commitDownloadedFiles !== false) {
  throw new Error('porting kit downloads must remain local-only');
}

if (!Array.isArray(manifest.kits) || manifest.kits.length === 0) {
  throw new Error('manifest must include at least one kit');
}

for (const kit of manifest.kits) {
  for (const key of ['id', 'target', 'status']) {
    if (!kit[key]) throw new Error(`kit missing ${key}`);
  }
  if (!Array.isArray(kit.requiredFor)) throw new Error(`${kit.id} missing requiredFor`);
  if (!Array.isArray(kit.verifyCommands)) throw new Error(`${kit.id} missing verifyCommands`);
  console.log(`ok: ${kit.id} -> ${kit.target}`);
}

console.log(`Porting kit manifest OK: ${manifest.kits.length} kit(s).`);
