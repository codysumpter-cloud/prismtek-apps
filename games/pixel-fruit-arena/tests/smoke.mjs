import { readFile } from 'node:fs/promises';
import { spawnSync } from 'node:child_process';

const root = new URL('..', import.meta.url);
const json = async (path) => JSON.parse(await readFile(new URL(path, root), 'utf8'));

const fruits = await json('data/fruits/core-fruits.json');
const stage = await json('data/stages/sky-ruins-arena.json');
const profile = await json('data/characters/default-profile.json');
const animations = await json('data/characters/prismtek-placeholder.animations.json');

if (fruits.length !== 6) throw new Error(`Expected 6 fruits, found ${fruits.length}`);
for (const fruit of fruits) {
  if (fruit.abilities.length !== 3) throw new Error(`${fruit.id} must have 3 abilities`);
  if (!fruit.awakening) throw new Error(`${fruit.id} missing awakening`);
}
if (stage.spawns.length < 4) throw new Error('Stage must support 4 spawn points');
if (!profile.appearance || !profile.owned_fruits || !profile.equipped_fruit) throw new Error('Profile schema is incomplete');
if (animations.sprite_width !== 64 || animations.sprite_height !== 64) throw new Error('Original character must be 64x64');

const validation = spawnSync('python3', ['tools/validate_sprites.py'], { cwd: root, stdio: 'inherit' });
if (validation.status !== 0) process.exit(validation.status ?? 1);

console.log('Pixel Fruit Arena smoke tests passed');
