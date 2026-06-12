import { readFile, readdir } from 'node:fs/promises';
import { join } from 'node:path';

const root = new URL('..', import.meta.url);
const forbiddenTerms = ['One Piece', 'Luffy', 'Nika', 'Gomu', 'Devil Fruit'];
const allowedReferenceFiles = new Set(['README_REFERENCE_ASSETS.md']);
let failures = 0;

async function walk(dir) {
  for (const entry of await readdir(dir, { withFileTypes: true })) {
    const path = join(dir, entry.name);
    if (entry.isDirectory()) await walk(path);
    else await check(path);
  }
}

async function check(path) {
  if (path.includes('assets/reference/onepiece-test') && !allowedReferenceFiles.has(path.split('/').pop())) {
    console.error(`Reference artifact must not be committed: ${path}`);
    failures += 1;
  }
  if (!/\.(js|json|md|html|css|svg|py|mjs)$/.test(path)) return;
  const text = await readFile(path, 'utf8');
  for (const term of forbiddenTerms) {
    if (text.includes(term) && !path.endsWith('README_REFERENCE_ASSETS.md')) {
      console.error(`Forbidden shipped term "${term}" in ${path}`);
      failures += 1;
    }
  }
}

await walk(new URL('.', root));
if (failures) process.exit(1);
console.log('Pixel Fruit Arena lint passed');
