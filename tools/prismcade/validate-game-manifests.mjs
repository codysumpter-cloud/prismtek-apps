#!/usr/bin/env node
import assert from "node:assert/strict";
import { existsSync, readFileSync } from "node:fs";
import path from "node:path";

const root = process.cwd();
const manifestPath = path.join(root, "data/prismcade/game-manifests.json");
const allowedStatuses = new Set([
  "playable-mvp",
  "playable-prototype",
  "quick-play-import",
  "large-showcase-prototype",
  "contract-only",
  "blocked"
]);
const allowedPriorities = new Set(["high", "medium", "later"]);

function readJson(file) {
  return JSON.parse(readFileSync(file, "utf8"));
}

function assertString(value, label) {
  assert.equal(typeof value, "string", `${label} must be a string`);
  assert.ok(value.trim().length > 0, `${label} cannot be empty`);
}

function assertBoolean(value, label) {
  assert.equal(typeof value, "boolean", `${label} must be a boolean`);
}

function assertArray(value, label) {
  assert.ok(Array.isArray(value), `${label} must be an array`);
}

function assertRelativeRepoPath(value, label) {
  assertString(value, label);
  assert.ok(!path.isAbsolute(value), `${label} must be repo-relative, not absolute`);
  assert.ok(!value.includes(".."), `${label} must not contain ..`);
}

function validateGame(game, index) {
  const prefix = `games[${index}] ${game?.id ?? "(missing id)"}`;

  for (const key of ["id", "title", "slug", "path", "status", "arcadeRole", "priority", "description", "thumbnail", "entrypoint"]) {
    assertString(game[key], `${prefix}.${key}`);
  }

  assert.ok(allowedStatuses.has(game.status), `${prefix}.status must be one of ${[...allowedStatuses].join(", ")}`);
  assert.ok(allowedPriorities.has(game.priority), `${prefix}.priority must be high, medium, or later`);

  assertRelativeRepoPath(game.path, `${prefix}.path`);
  assertRelativeRepoPath(game.entrypoint, `${prefix}.entrypoint`);
  assertRelativeRepoPath(game.thumbnail, `${prefix}.thumbnail`);

  const gamePath = path.join(root, game.path);
  assert.ok(existsSync(gamePath), `${prefix}: missing game path ${game.path}`);
  assert.ok(existsSync(path.join(gamePath, "README.md")), `${prefix}: missing README.md`);
  assert.ok(existsSync(path.join(gamePath, "package.json")), `${prefix}: missing package.json`);
  assert.ok(existsSync(path.join(root, game.entrypoint)), `${prefix}: missing entrypoint ${game.entrypoint}`);

  assertArray(game.tags, `${prefix}.tags`);
  assert.ok(game.tags.length > 0, `${prefix}.tags must not be empty`);
  for (const tag of game.tags) assertString(tag, `${prefix}.tags[]`);

  assert.ok(game.commands && typeof game.commands === "object", `${prefix}.commands must be an object`);
  for (const key of ["dev", "test", "build", "package"]) assertString(game.commands[key], `${prefix}.commands.${key}`);

  assertArray(game.controls, `${prefix}.controls`);
  assert.ok(game.controls.length > 0, `${prefix}.controls must not be empty`);

  assert.ok(game.players && typeof game.players === "object", `${prefix}.players must be an object`);
  assert.equal(typeof game.players.min, "number", `${prefix}.players.min must be a number`);
  assert.equal(typeof game.players.max, "number", `${prefix}.players.max must be a number`);
  assert.ok(game.players.min >= 1, `${prefix}.players.min must be at least 1`);
  assert.ok(game.players.max >= game.players.min, `${prefix}.players.max must be >= min`);
  assertArray(game.players.modes, `${prefix}.players.modes`);

  assert.ok(game.inputSupport && typeof game.inputSupport === "object", `${prefix}.inputSupport must be an object`);
  for (const key of ["keyboard", "pointer", "touch", "gamepad"]) assertBoolean(game.inputSupport[key], `${prefix}.inputSupport.${key}`);

  assert.ok(game.platformStatus && typeof game.platformStatus === "object", `${prefix}.platformStatus must be an object`);
  assert.ok(Object.keys(game.platformStatus).length > 0, `${prefix}.platformStatus must not be empty`);

  assert.ok(game.platformHooks && typeof game.platformHooks === "object", `${prefix}.platformHooks must be an object`);
  for (const key of ["localProfileReady", "localHistoryReady", "matchReceiptReady", "shareCardReady", "leaderboardExportReady", "hostedLeaderboardReady"]) {
    assertBoolean(game.platformHooks[key], `${prefix}.platformHooks.${key}`);
  }
  if (game.platformHooks.hostedLeaderboardReady) {
    assert.ok(game.platformHooks.leaderboardExportReady, `${prefix}: hostedLeaderboardReady requires leaderboardExportReady`);
    assert.ok(game.platformHooks.matchReceiptReady, `${prefix}: hostedLeaderboardReady requires matchReceiptReady`);
  }

  assert.ok(game.assets && typeof game.assets === "object", `${prefix}.assets must be an object`);
  assert.ok("manifest" in game.assets, `${prefix}.assets.manifest key is required`);
  assertString(game.assets.nextAssetNeed, `${prefix}.assets.nextAssetNeed`);

  assertArray(game.receipts, `${prefix}.receipts`);
  assertArray(game.nextActions, `${prefix}.nextActions`);
}

assert.ok(existsSync(manifestPath), `Missing ${manifestPath}`);
const registry = readJson(manifestPath);

assert.equal(registry.schemaVersion, "prismcade-game-manifest-registry-v0", "Unexpected Prismcade registry schemaVersion");
assert.ok(registry.docs && typeof registry.docs === "object", "registry.docs is required");
for (const [key, docPath] of Object.entries(registry.docs)) {
  assertRelativeRepoPath(docPath, `docs.${key}`);
  assert.ok(existsSync(path.join(root, docPath)), `Missing docs.${key}: ${docPath}`);
}

assertArray(registry.games, "registry.games");
assert.ok(registry.games.length >= 8, "registry.games should cover the active Prismtek Arcade roster");

const ids = new Set();
const slugs = new Set();

registry.games.forEach((game, index) => {
  validateGame(game, index);
  assert.ok(!ids.has(game.id), `Duplicate game id ${game.id}`);
  assert.ok(!slugs.has(game.slug), `Duplicate game slug ${game.slug}`);
  ids.add(game.id);
  slugs.add(game.slug);
});

for (const expected of [
  "pixel-fruit-arena",
  "flappy-pixel",
  "crossy-pixel",
  "pixel-snake",
  "neon-brick-breaker",
  "pixel-stacker",
  "spin-street-showdown",
  "tamernet-battle-sandbox",
  "prismwilds-echo-dominion"
]) {
  assert.ok(ids.has(expected), `Missing expected Prismcade game ${expected}`);
}

const pfa = registry.games.find((game) => game.id === "pixel-fruit-arena");
assert.equal(pfa.arcadeRole, "platform-fighter", "Pixel Fruit Arena should stay a focused fighter showcase");
assert.equal(pfa.priority, "high", "Pixel Fruit Arena should be high priority for Prismcade");

const prismwilds = registry.games.find((game) => game.id === "prismwilds-echo-dominion");
assert.equal(prismwilds.priority, "later", "Prismwilds should be cataloged as a later large showcase, not the first platform blocker");

console.log(`Prismcade manifest registry passed: ${registry.games.length} games validated.`);
