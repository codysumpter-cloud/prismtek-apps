#!/usr/bin/env node
import assert from "node:assert/strict";
import { existsSync, readFileSync } from "node:fs";
import path from "node:path";

const root = process.cwd();
const catalogPath = path.join(root, "data/prismcade/prismcade-catalog.json");
const allowedNative = new Set(["playable", "planned"]);
const allowedCanonical = new Set(["native", "web", "apps"]);

assert.ok(existsSync(catalogPath), `Missing ${catalogPath}`);
const catalog = JSON.parse(readFileSync(catalogPath, "utf8"));

assert.equal(catalog.schemaVersion, "prismcade-canonical-catalog-v0", "Unexpected canonical catalog schemaVersion");
assert.ok(Array.isArray(catalog.games) && catalog.games.length > 0, "catalog.games must be a non-empty array");

const ids = new Set();
for (const [index, game] of catalog.games.entries()) {
  const prefix = `games[${index}] ${game?.id ?? "(missing id)"}`;
  for (const key of ["id", "title", "description"]) {
    assert.equal(typeof game[key], "string", `${prefix}.${key} must be a string`);
    assert.ok(game[key].trim().length > 0, `${prefix}.${key} cannot be empty`);
  }
  assert.ok(!ids.has(game.id), `Duplicate canonical id ${game.id}`);
  ids.add(game.id);

  assert.ok(Array.isArray(game.categories), `${prefix}.categories must be an array`);
  assert.ok(game.web && typeof game.web.playable === "boolean", `${prefix}.web.playable must be boolean`);
  assert.equal(typeof game.website, "boolean", `${prefix}.website must be boolean`);
  assert.ok(game.apps && typeof game.apps.present === "boolean", `${prefix}.apps.present must be boolean`);
  assert.ok(allowedNative.has(game.native), `${prefix}.native must be playable|planned`);
  assert.ok(allowedCanonical.has(game.canonicalRuntime), `${prefix}.canonicalRuntime must be native|web|apps`);
  assert.ok(Array.isArray(game.replaces), `${prefix}.replaces must be an array`);
}

// Replacement targets must not also be live canonical ids (avoid duplicate visible cards).
for (const game of catalog.games) {
  for (const replaced of game.replaces) {
    assert.ok(!ids.has(replaced), `${game.id} replaces ${replaced}, which must not also be a live catalog id`);
  }
}

const counts = catalog.counts ?? {};
const nativePlayable = catalog.games.filter((g) => g.native === "playable").length;
if (typeof counts.nativePlayable === "number") {
  assert.equal(counts.nativePlayable, nativePlayable, "counts.nativePlayable out of sync");
}

console.log(`Prismcade canonical catalog OK: ${catalog.games.length} games, ${nativePlayable} native-playable.`);
