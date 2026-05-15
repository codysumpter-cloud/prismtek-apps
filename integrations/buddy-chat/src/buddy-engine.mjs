const DEFAULT_ASCII = ['  [o_o]', ' /|___|\\', '   / \\'].join('\n');

const DEFAULT_BUDDY = {
  id: 'bmo-buddy',
  name: 'BMO Buddy',
  kind: 'pixel',
  palette: ['mint', 'sky', 'cream'],
  mood: 'ready',
  energy: 72,
  bond: 8,
  level: 1,
  traits: ['practical', 'kind', 'ships small wedges'],
  ascii: DEFAULT_ASCII,
  pixel: [
    '00111100',
    '01111110',
    '11011011',
    '11111111',
    '10111101',
    '11000011',
    '01111110',
    '00100100',
  ],
};

const MOODS = new Set(['ready', 'curious', 'cozy', 'focused', 'sleepy', 'excited', 'brave']);
const KINDS = new Set(['pixel', 'ascii', 'tamagotchi']);

export function defaultBuddy() {
  return clone(DEFAULT_BUDDY);
}

export function normalizeBuddy(input = {}) {
  const base = defaultBuddy();
  const source = typeof input === 'object' && input !== null ? input : {};
  const name = cleanText(source.name, base.name).slice(0, 40);
  const kind = KINDS.has(source.kind) ? source.kind : base.kind;
  const mood = MOODS.has(source.mood) ? source.mood : base.mood;
  const traits = Array.isArray(source.traits)
    ? source.traits.map((trait) => cleanText(trait, '')).filter(Boolean).slice(0, 6)
    : base.traits;
  const palette = Array.isArray(source.palette)
    ? source.palette.map((color) => cleanText(color, '')).filter(Boolean).slice(0, 5)
    : base.palette;

  return {
    ...base,
    ...source,
    id: cleanSlug(source.id || name || base.id),
    name,
    kind,
    mood,
    traits: traits.length ? traits : base.traits,
    palette: palette.length ? palette : base.palette,
    energy: clampNumber(source.energy, 0, 100, base.energy),
    bond: clampNumber(source.bond, 0, 100, base.bond),
    level: clampNumber(source.level, 1, 99, base.level),
    ascii: cleanAscii(source.ascii || base.ascii),
    pixel: normalizePixel(source.pixel || base.pixel),
  };
}

export function createBuddyProfile({name, kind = 'pixel', vibe = 'helpful', palette = []} = {}) {
  const safeName = cleanText(name, 'New Buddy').slice(0, 40);
  const safeVibe = cleanText(vibe, 'helpful').slice(0, 80);
  const safeKind = KINDS.has(kind) ? kind : 'pixel';
  const safePalette = Array.isArray(palette)
    ? palette.map((color) => cleanText(color, '')).filter(Boolean).slice(0, 5)
    : String(palette || '')
        .split(',')
        .map((color) => cleanText(color, ''))
        .filter(Boolean)
        .slice(0, 5);

  const seed = hash(`${safeName}|${safeKind}|${safeVibe}|${safePalette.join(',')}`);
  const face = seed % 3 === 0 ? 'o_o' : seed % 3 === 1 ? '^_^' : '•_•';
  const ears = seed % 2 === 0 ? [' /\\_/\\', `( ${face} )`] : ['  .-.-.', ` ( ${face} )`];
  const ascii = safeKind === 'ascii' || safeKind === 'tamagotchi'
    ? [ears[0], ears[1], ' /|___|\\', '   / \\'].join('\n')
    : DEFAULT_BUDDY.ascii;

  return normalizeBuddy({
    name: safeName,
    kind: safeKind,
    palette: safePalette.length ? safePalette : derivePalette(seed),
    mood: 'ready',
    energy: 74,
    bond: 10,
    level: 1,
    traits: deriveTraits(safeVibe, seed),
    ascii,
    pixel: derivePixel(seed),
  });
}

export function evolveBuddy({buddy, event = 'chat'} = {}) {
  const current = normalizeBuddy(buddy);
  const safeEvent = cleanText(event, 'chat').toLowerCase().slice(0, 80);
  const feeding = /feed|snack|treat|meal|water/.test(safeEvent);
  const play = /play|game|pixel|draw|create/.test(safeEvent);
  const rest = /rest|sleep|nap|quiet/.test(safeEvent);
  const work = /work|ship|build|code|debug|fix/.test(safeEvent);

  const energyDelta = feeding ? 14 : rest ? 18 : play ? -8 : work ? -6 : -2;
  const bondDelta = play ? 5 : feeding ? 3 : work ? 2 : 1;
  const nextBond = clampNumber(current.bond + bondDelta, 0, 100, current.bond);
  const nextEnergy = clampNumber(current.energy + energyDelta, 0, 100, current.energy);
  const nextLevel = Math.max(current.level, Math.floor(nextBond / 20) + 1);
  const mood = nextEnergy < 20 ? 'sleepy' : play ? 'excited' : work ? 'focused' : feeding ? 'cozy' : 'curious';

  return normalizeBuddy({
    ...current,
    mood,
    energy: nextEnergy,
    bond: nextBond,
    level: nextLevel,
  });
}

export function buddySystemPrompt(buddy) {
  const state = normalizeBuddy(buddy);
  return [
    `You are ${state.name}, a tiny BeMore Buddy that lives inside ChatGPT.`,
    `Mood: ${state.mood}. Energy: ${state.energy}. Bond: ${state.bond}. Level: ${state.level}.`,
    `Traits: ${state.traits.join(', ')}.`,
    'Be warm, practical, and brief. Help the user create, care for, and use buddies for real work.',
    'Never claim access to private systems unless the tool result or user supplied context proves it.',
  ].join('\n');
}

function derivePalette(seed) {
  const palettes = [
    ['mint', 'teal', 'cream'],
    ['lavender', 'indigo', 'moon'],
    ['peach', 'coral', 'sand'],
    ['lime', 'slate', 'sky'],
  ];
  return palettes[seed % palettes.length];
}

function deriveTraits(vibe, seed) {
  const pool = ['creative', 'protective', 'curious', 'cozy', 'focused', 'playful', 'patient', 'bold'];
  const traits = [vibe || 'helpful'];
  traits.push(pool[seed % pool.length]);
  traits.push(pool[(seed >> 3) % pool.length]);
  return Array.from(new Set(traits)).slice(0, 4);
}

function derivePixel(seed) {
  const rows = [];
  for (let y = 0; y < 8; y += 1) {
    let row = '';
    for (let x = 0; x < 8; x += 1) {
      const border = y === 0 || y === 7 || x === 0 || x === 7;
      const eye = y === 3 && (x === 2 || x === 5);
      const mouth = y === 5 && x >= 3 && x <= 4;
      const bit = border || eye || mouth || ((seed >> ((x + y) % 16)) & 1);
      row += bit ? '1' : '0';
    }
    rows.push(row);
  }
  return rows;
}

function normalizePixel(pixel) {
  if (!Array.isArray(pixel)) return DEFAULT_BUDDY.pixel;
  const rows = pixel
    .map((row) => String(row || '').replace(/[^01]/g, '').slice(0, 16))
    .filter(Boolean)
    .slice(0, 16);
  return rows.length ? rows : DEFAULT_BUDDY.pixel;
}

function cleanAscii(value) {
  return String(value || DEFAULT_ASCII).replace(/[\u0000-\u0008\u000b\u000c\u000e-\u001f\u007f]/g, '').slice(0, 1000);
}

function cleanText(value, fallback) {
  const text = String(value ?? fallback ?? '').replace(/[\u0000-\u001f\u007f]/g, ' ').trim();
  return text || fallback;
}

function cleanSlug(value) {
  const slug = String(value || 'buddy').toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '');
  return slug || 'buddy';
}

function clampNumber(value, min, max, fallback) {
  const number = Number(value);
  if (!Number.isFinite(number)) return fallback;
  return Math.max(min, Math.min(max, Math.round(number)));
}

function hash(value) {
  let out = 2166136261;
  for (const char of value) {
    out ^= char.charCodeAt(0);
    out = Math.imul(out, 16777619);
  }
  return out >>> 0;
}

function clone(value) {
  return JSON.parse(JSON.stringify(value));
}
