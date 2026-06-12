import { mkdir, cp, rm } from 'node:fs/promises';
import { spawnSync } from 'node:child_process';
import { resolve } from 'node:path';

const root = resolve(import.meta.dirname, '..');
const out = resolve(root, 'dist');

const validation = spawnSync('python3', ['tools/validate_sprites.py'], { cwd: root, stdio: 'inherit', env: { ...process.env, NODE_ENV: 'production', USE_REFERENCE_TEST_ASSETS: 'false' } });
if (validation.status !== 0) process.exit(validation.status ?? 1);

await rm(out, { recursive: true, force: true });
await mkdir(out, { recursive: true });
await cp(resolve(root, 'index.html'), resolve(out, 'index.html'));
await cp(resolve(root, 'src'), resolve(out, 'src'), { recursive: true });
await cp(resolve(root, 'data'), resolve(out, 'data'), { recursive: true });
console.log('Built Pixel Fruit Arena to dist/ with reference assets excluded.');
