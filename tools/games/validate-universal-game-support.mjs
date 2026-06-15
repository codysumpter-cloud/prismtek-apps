#!/usr/bin/env node
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.resolve(__dirname, '..', '..');

const activeGames = [
  'games/pixel-fruit-arena',
  'games/tamernet-battle-sandbox',
  'games/spin-street-showdown'
];

const requiredInputs = ['keyboard', 'mouse', 'controller', 'touch'];
const requiredPlatforms = [
  'webBrowser',
  'windows',
  'macos',
  'linux',
  'ios',
  'android',
  'rgdsAndroid',
  'rgdsLinux',
  'roblox'
];
const allowedStatuses = new Set([
  'Required',
  'Configured',
  'Partially verified',
  'Verified',
  'Blocked',
  'Missing',
  'Not applicable'
]);

let failed = false;

function fail(message) {
  console.error(`ERROR: ${message}`);
  failed = true;
}

function readJson(relativePath) {
  const absolutePath = path.join(repoRoot, relativePath);
  if (!fs.existsSync(absolutePath)) {
    fail(`missing file: ${relativePath}`);
    return null;
  }
  try {
    return JSON.parse(fs.readFileSync(absolutePath, 'utf8'));
  } catch (error) {
    fail(`invalid JSON in ${relativePath}: ${error.message}`);
    return null;
  }
}

function validateStatus(owner, key, entry) {
  if (!entry || typeof entry !== 'object') {
    fail(`${owner}.${key} must be an object`);
    return;
  }
  if (entry.required !== true) {
    fail(`${owner}.${key}.required must be true`);
  }
  if (!allowedStatuses.has(entry.status)) {
    fail(`${owner}.${key}.status must be one of: ${Array.from(allowedStatuses).join(', ')}`);
  }
}

for (const gamePath of activeGames) {
  const configPath = `${gamePath}/platforms/universal-support.json`;
  const config = readJson(configPath);
  if (!config) continue;

  if (!config.gameId) fail(`${configPath} needs gameId`);
  if (!config.displayName) fail(`${configPath} needs displayName`);

  for (const input of requiredInputs) {
    validateStatus(`${config.gameId}.inputs`, input, config.inputs?.[input]);
  }

  for (const platform of requiredPlatforms) {
    validateStatus(`${config.gameId}.platforms`, platform, config.platforms?.[platform]);
  }

  if (!Array.isArray(config.requiredReceipts) || config.requiredReceipts.length < requiredInputs.length + requiredPlatforms.length - 1) {
    fail(`${configPath} must list receipts for the required inputs and platform families`);
  }

  if (!Array.isArray(config.knownGaps)) {
    fail(`${configPath} must include knownGaps array`);
  }

  if (!Array.isArray(config.nextActions)) {
    fail(`${configPath} must include nextActions array`);
  }

  console.log(`ok: ${config.gameId} universal support contract`);
}

if (failed) {
  process.exit(1);
}

console.log(`Universal game support validation OK: ${activeGames.length} active game(s).`);
