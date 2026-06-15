import assert from "node:assert/strict";
import { existsSync, readFileSync } from "node:fs";

const games = [
  { name: "Pixel Fruit Arena", path: "games/pixel-fruit-arena" },
  { name: "TamerNet Battle Sandbox", path: "games/tamernet-battle-sandbox" },
  { name: "Spin Street Showdown", path: "games/spin-street-showdown" }
];

const docs = [
  { label: "root README", path: "README.md" },
  { label: "arcade feel guide", path: "docs/games/prismtek-arcade-feel.md" },
  { label: "platform tracker", path: "docs/games/three-game-platform-readiness.md" }
];

for (const game of games) {
  assert.ok(existsSync(game.path), `${game.name}: missing ${game.path}`);
  assert.ok(existsSync(`${game.path}/README.md`), `${game.name}: missing README.md`);
  assert.ok(existsSync(`${game.path}/package.json`), `${game.name}: missing package.json`);
}

for (const doc of docs) {
  assert.ok(existsSync(doc.path), `${doc.label}: missing ${doc.path}`);
  const text = readFileSync(doc.path, "utf8");
  for (const game of games) {
    assert.match(text, new RegExp(game.name.replace(/[.*+?^${}()|[\]\\]/g, "\\$&")), `${doc.label}: missing ${game.name}`);
    assert.match(text, new RegExp(game.path.replace(/[.*+?^${}()|[\]\\]/g, "\\$&")), `${doc.label}: missing ${game.path}`);
  }
}

console.log("Prismtek Arcade roster docs passed.");
