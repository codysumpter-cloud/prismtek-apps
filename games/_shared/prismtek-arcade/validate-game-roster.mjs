import assert from "node:assert/strict";
import { existsSync, readFileSync } from "node:fs";

const activeGames = [
  { name: "Pixel Fruit Arena", path: "games/pixel-fruit-arena" },
  { name: "TamerNet Battle Sandbox", path: "games/tamernet-battle-sandbox" },
  { name: "Spin Street Showdown", path: "games/spin-street-showdown" },
  { name: "Flappy Pixel", path: "games/flappy-pixel", id: "flappy-pixel" },
  { name: "Crossy Pixel", path: "games/crossy-pixel", id: "crossy-pixel" },
  { name: "Pixel Snake", path: "games/pixel-snake", id: "pixel-snake" },
  { name: "Neon Brick Breaker", path: "games/neon-brick-breaker", id: "neon-brick-breaker" },
  { name: "Pixel Stacker", path: "games/pixel-stacker", id: "pixel-stacker" }
];

const docs = [
  { label: "root README", path: "README.md" },
  { label: "arcade feel guide", path: "docs/games/prismtek-arcade-feel.md" },
  { label: "platform tracker", path: "docs/games/three-game-platform-readiness.md" },
  { label: "Prismtek-site arcade migration receipt", path: "docs/games/prismtek-site-arcade-migration-queue.md" }
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

for (const docDef of docs) {
  assert.ok(existsSync(docDef.path), `${docDef.label}: missing ${docDef.path}`);
  const doc = { ...docDef, text: readFileSync(docDef.path, "utf8") };
  for (const game of activeGames) {
    assertDocMentions(doc, game.name, game.name);
    assertDocMentions(doc, game.path, game.path);
    if (game.id) {
      assertDocMentions(doc, game.id, game.id);
    }
  }
}

console.log("Prismtek Arcade active roster docs passed.");
