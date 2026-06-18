#!/usr/bin/env node
import { existsSync, readdirSync, readFileSync } from 'node:fs';
import path from 'node:path';
import process from 'node:process';

const repoRoot = process.cwd();
const rowsDir = path.join(repoRoot, 'data/prismcade/asset-rows');

const REQUIRED_FILES = [
  'character-assets.json',
  'vfx-assets.json',
  'world-assets.json',
  'item-assets.json',
  'ui-assets.json',
  'audio-assets.json',
];

function fail(message) {
  console.error(`asset row validation failed: ${message}`);
  process.exitCode = 1;
}

function readJson(filePath) {
  return JSON.parse(readFileSync(filePath, 'utf8'));
}

function rowsFromFile(file) {
  return [
    ...(Array.isArray(file.entries) ? file.entries : []),
    ...(Array.isArray(file.priorityRows) ? file.priorityRows : []),
    ...(Array.isArray(file.categories) ? file.categories : []),
  ];
}

if (!existsSync(rowsDir)) {
  fail('missing data/prismcade/asset-rows directory');
} else {
  for (const required of REQUIRED_FILES) {
    const filePath = path.join(rowsDir, required);
    if (!existsSync(filePath)) fail(`missing ${required}`);
  }

  const ids = new Set();
  const jsonFiles = readdirSync(rowsDir).filter((file) => file.endsWith('.json')).sort();

  for (const fileName of jsonFiles) {
    const filePath = path.join(rowsDir, fileName);
    const file = readJson(filePath);
    if (!file.schemaVersion || !String(file.schemaVersion).startsWith('prismcade-row-level-')) {
      fail(`${fileName} has invalid schemaVersion`);
    }

    const rows = rowsFromFile(file);
    if (rows.length === 0) fail(`${fileName} has no rows`);

    for (const row of rows) {
      const id = `${fileName}:${row.id}`;
      if (!row.id) fail(`${fileName} row missing id`);
      if (ids.has(id)) fail(`duplicate row id ${id}`);
      ids.add(id);
      if (!row.name && !row.displayName) fail(`${fileName}:${row.id} missing name/displayName`);
      if (!row.sourcePath) fail(`${fileName}:${row.id} missing sourcePath`);
      const status = row.status ?? row.prismcadeStatus ?? 'candidate';
      const license = row.licenseStatus ?? file.defaultLicenseStatus ?? 'mixed_needs_per_pack_review';
      if (status === 'game_ready' && ['unknown_do_not_ship', 'external_reference_only'].includes(license)) {
        fail(`${fileName}:${row.id} cannot be game_ready with ${license}`);
      }
    }
  }
}

if (!process.exitCode) {
  console.log('asset row validation passed.');
}
