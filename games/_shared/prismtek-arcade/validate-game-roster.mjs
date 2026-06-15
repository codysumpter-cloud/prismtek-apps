import assert from "node:assert/strict";
import { existsSync, readFileSync } from "node:fs";

const activeGames = [
  { name: "Pixel Fruit Arena", path: "games/pixel-fruit-arena" },
  { name: "TamerNet Battle Sandbox", path: "games/tamernet-battle-sandbox" },
  { name: "Spin Street Showdown", path: "games/spin-street-showdown" }
];

const queuedGames = [
  { name: "Flappy Pixel", id: "flappy-pixel", path: "games/flappy-pixel" },
  { name: "Crossy Pixel", id: "crossy-pixel", path: "games/crossy-pixel" },
  { name: "Pixel Snake", id: "pixel-snake", path: "games/pixel-snake" },
  { name: "Neon Brick Breaker", id: "neon-brick-breaker", path: "games/neon-brick-breaker" },
  { name: "Pixel Stacker", id: "pixel-stacker", path: "games/pixel-stacker" }
];

const activeDocs = [
  { label: "root README", path: "README.md" },
  { label: "arcade feel guide", path: "docs/games/prismtek-arcade-feel.md" },
  { label: "platform tracker", path: "docs/games/three-game-platform-readiness.md" }
];

const queueDocs = [
  ...activeDocs,
  { label: "Prismtek-site arcade migration queue", path: "docs/games/prismtek-site-arcade-migration-queue.md" }
];

function escapeRegExp(value) {
  return value.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
}

function assertDocMentions(doc, value, label) {
  assert.match(doc.text, new RegExp(escapeRegExp(value)), `${doc.label}: missing ${label}`);
}

for (const game of activeGames) {
  assert.ok(existsSync(game.path), `${game.name}: missing ${game.path}`);
  assert.ok(existsSync(`${game.path}/README.md`), `${game.name}: missing README.md`);
  assert.ok(existsSync(`${game.path}/package.json`), `${game.name}: missing package.json`);
}

for (const docDef of activeDocs) {
  assert.ok(existsSync(docDef.path), `${docDef.label}: missing ${docDef.path}`);
  const doc = { ...docDef, text: readFileSync(docDef.path, "utf8") };
  for (const game of activeGames) {
    assertDocMentions(doc, game.name, game.name);
    assertDocMentions(doc, game.path, game.path);
  }
}

for (const docDef of queueDocs) {
  assert.ok(existsSync(docDef.path), `${docDef.label}: missing ${docDef.path}`);
  const doc = { ...docDef, text: readFileSync(docDef.path, "utf8") };
  for (const game of queuedGames) {
    assertDocMentions(doc, game.name, game.name);
    assertDocMentions(doc, game.id, game.id);
    assertDocMentions(doc, game.path, game.path);
  }
}

console.log("Prismtek Arcade active roster and migration queue docs passed.");
