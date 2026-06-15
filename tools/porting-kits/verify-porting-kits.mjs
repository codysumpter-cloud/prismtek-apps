#!/usr/bin/env node
import fs from 'node:fs';
import path from 'node:path';
import { spawnSync } from 'node:child_process';

const repoRoot = path.resolve(path.dirname(new URL(import.meta.url).pathname), '..', '..');
const manifestPath = path.join(repoRoot, 'tools', 'porting-kits', 'porting-kits.manifest.json');
const downloadRoot = process.env.PRISMTEK_PORTING_KITS_DIR || path.join(repoRoot, '.porting-kits');

function fail(message) {
  console.error(`ERROR: ${message}`);
  process.exitCode = 1;
}

function commandName(command) {
  return command.trim().split(/\s+/)[0];
}

function hasCommand(command) {
  const shell = process.platform === 'win32' ? 'where' : 'command';
  const args = process.platform === 'win32' ? [command] : ['-v', command];
  const result = spawnSync(shell, args, { stdio: 'ignore', shell: process.platform !== 'win32' });
  return result.status === 0;
}

if (!fs.existsSync(manifestPath)) {
  fail(`Missing manifest: ${manifestPath}`);
  process.exit();
}

let manifest;
try {
  manifest = JSON.parse(fs.readFileSync(manifestPath, 'utf8'));
} catch (error) {
  fail(`Manifest is not valid JSON: ${error.message}`);
  process.exit();
}

if (!Array.isArray(manifest.kits) || manifest.kits.length === 0) {
  fail('Manifest must include at least one kit.');
}

const ids = new Set();
const urlPattern = /^https:\/\//;
let automatedCount = 0;
let manualCount = 0;

for (const kit of manifest.kits) {
  if (!kit.id) fail('Every kit needs an id.');
  if (!kit.target) fail(`Kit ${kit.id ?? '<missing>'} needs a target.`);
  if (ids.has(kit.id)) fail(`Duplicate kit id: ${kit.id}`);
  ids.add(kit.id);

  if (!Array.isArray(kit.sources) || kit.sources.length === 0) {
    fail(`Kit ${kit.id} needs at least one source.`);
    continue;
  }

  for (const source of kit.sources) {
    if (!source.id) fail(`Kit ${kit.id} has a source without an id.`);
    if (!source.url || !urlPattern.test(source.url)) {
      fail(`Source ${source.id ?? '<missing>'} must use an https URL.`);
    }
    if (source.automated) {
      automatedCount += 1;
      if (!source.destination) fail(`Automated source ${source.id} needs a destination.`);
      if (source.destination?.includes('..')) fail(`Automated source ${source.id} has an unsafe destination.`);
      const downloadedPath = path.join(downloadRoot, source.destination ?? '');
      if (fs.existsSync(downloadedPath)) {
        console.log(`downloaded: ${source.id} -> ${path.relative(repoRoot, downloadedPath)}`);
      } else {
        console.log(`pending download: ${source.id} -> ${path.relative(repoRoot, downloadedPath)}`);
      }
    } else {
      manualCount += 1;
    }
  }

  for (const verifyCommand of kit.verifyCommands ?? []) {
    const cmd = commandName(verifyCommand);
    if (hasCommand(cmd)) {
      console.log(`available: ${cmd} (${kit.id})`);
    } else {
      console.log(`missing/manual: ${cmd} (${kit.id})`);
    }
  }
}

if (!manifest.policy || manifest.policy.commitDownloadedFiles !== false) {
  fail('Manifest policy must explicitly set commitDownloadedFiles to false.');
}

console.log(`\nPorting kit manifest OK: ${manifest.kits.length} kits, ${automatedCount} automated source(s), ${manualCount} manual/review source(s).`);
console.log(`Download root: ${path.relative(repoRoot, downloadRoot)}`);

if (process.exitCode) {
  process.exit(process.exitCode);
}
