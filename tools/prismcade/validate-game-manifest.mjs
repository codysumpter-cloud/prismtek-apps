#!/usr/bin/env node
// Validates per-game manifests against data/prismcade/schemas/prismcade-game.schema.json.
// Dependency-free (matches the style of validate-game-manifests.mjs) so it runs in CI with no install.
//
// Usage:
//   node tools/prismcade/validate-game-manifest.mjs                 # scan games/**/data/*.manifest.json
//   node tools/prismcade/validate-game-manifest.mjs path/to/x.manifest.json [more...]
import assert from "node:assert/strict";
import { readFileSync, readdirSync, statSync, existsSync } from "node:fs";
import path from "node:path";

const root = process.cwd();
const schemaPath = path.join(root, "data/prismcade/schemas/prismcade-game.schema.json");
const schema = JSON.parse(readFileSync(schemaPath, "utf8"));

const SCHEMA_VERSION = schema.properties.schemaVersion.const;
const RUNTIMES = new Set(schema.properties.runtime.enum);
const STATUSES = new Set(schema.properties.status.enum);
const ID_RE = new RegExp(schema.properties.id.pattern);

function readJson(file) {
  return JSON.parse(readFileSync(file, "utf8"));
}

function assertString(value, label) {
  assert.equal(typeof value, "string", `${label} must be a string`);
  assert.ok(value.trim().length > 0, `${label} cannot be empty`);
}

function assertRepoRelative(value, label) {
  assertString(value, label);
  assert.ok(!path.isAbsolute(value), `${label} must be repo-relative, not absolute`);
  assert.ok(!value.includes(".."), `${label} must not contain ..`);
}

function validateManifest(file) {
  const m = readJson(file);
  const where = path.relative(root, file);

  assert.equal(m.schemaVersion, SCHEMA_VERSION, `${where}: schemaVersion must be "${SCHEMA_VERSION}" (got "${m.schemaVersion}")`);

  assertString(m.id, `${where}.id`);
  assert.ok(ID_RE.test(m.id), `${where}.id "${m.id}" must match ${schema.properties.id.pattern}`);

  assertString(m.title, `${where}.title`);
  assertRepoRelative(m.entrypoint, `${where}.entrypoint`);

  assert.ok(RUNTIMES.has(m.runtime), `${where}.runtime must be one of: ${[...RUNTIMES].join(", ")} (got "${m.runtime}")`);
  assert.ok(STATUSES.has(m.status), `${where}.status must be one of: ${[...STATUSES].join(", ")} (got "${m.status}")`);

  if (m.entrypoint && existsSync(path.join(root, m.entrypoint))) {
    // ok: entrypoint resolves on disk
  } else if (m.status !== "contract-only" && m.status !== "creator-prototype") {
    throw new Error(`${where}.entrypoint "${m.entrypoint}" does not exist on disk (allowed only for contract-only / creator-prototype)`);
  }

  if (m.data) {
    for (const [key, rel] of Object.entries(m.data)) {
      assertRepoRelative(rel, `${where}.data.${key}`);
    }
  }
  return where;
}

function findManifests(dir, acc) {
  for (const name of readdirSync(dir)) {
    if (name === "node_modules" || name.startsWith(".")) continue;
    const full = path.join(dir, name);
    const st = statSync(full);
    if (st.isDirectory()) findManifests(full, acc);
    else if (name.endsWith(".manifest.json")) acc.push(full);
  }
  return acc;
}

const args = process.argv.slice(2);
let targets;
if (args.length) {
  targets = args.map((a) => path.resolve(root, a));
} else {
  const gamesDir = path.join(root, "games");
  targets = existsSync(gamesDir) ? findManifests(gamesDir, []) : [];
}

if (!targets.length) {
  console.log("validate-game-manifest: no *.manifest.json files found to check.");
  process.exit(0);
}

let failures = 0;
for (const file of targets) {
  try {
    const where = validateManifest(file);
    console.log(`ok  ${where}`);
  } catch (err) {
    failures += 1;
    console.error(`FAIL ${err.message}`);
  }
}

if (failures) {
  console.error(`\nvalidate-game-manifest: ${failures} manifest(s) failed.`);
  process.exit(1);
}
console.log(`\nvalidate-game-manifest: all ${targets.length} manifest(s) valid.`);
