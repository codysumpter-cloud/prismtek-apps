import fs from 'node:fs';

const requiredFiles = [
  'index.html',
  'README.md',
  'package.json',
  'data/assets.json',
  'assets/README.md'
];

for (const file of requiredFiles) {
  if (!fs.existsSync(file)) {
    throw new Error(`Missing required Prismwilds file: ${file}`);
  }
}

const html = fs.readFileSync('index.html', 'utf8');
const tokens = [
  'Heartwater Caldera',
  'UNDERPOPULATED_PLAYER_TARGET',
  'dive',
  'hidden',
  'feeder',
  'roaming',
  'berries',
  'waterHoles',
  'oxygen',
  'scent',
  'rare-bloom',
  'cactus-fruit'
];

for (const token of tokens) {
  if (!html.includes(token)) {
    throw new Error(`index.html missing expected runtime token: ${token}`);
  }
}

const assets = JSON.parse(fs.readFileSync('data/assets.json', 'utf8'));
if (!Array.isArray(assets.creatures) || assets.creatures.length < 6) {
  throw new Error('data/assets.json needs at least six curated creature asset candidates.');
}
if (!Array.isArray(assets.world) || assets.world.length < 6) {
  throw new Error('data/assets.json needs at least six curated world asset candidates.');
}
if (!Array.isArray(assets.resources) || assets.resources.length < 3) {
  throw new Error('data/assets.json needs food/water resource candidates.');
}

console.log('Prismwilds smoke test passed: dense world, survival, stealth, water, feeder NPCs, roaming dinosaurs, and asset curation are present.');
