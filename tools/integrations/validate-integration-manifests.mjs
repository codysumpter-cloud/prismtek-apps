#!/usr/bin/env node
import { readFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const repoRoot = join(__dirname, '..', '..');

const manifests = [
  {
    label: 'game engine adapters',
    path: join(repoRoot, 'data', 'integrations', 'game-engine-adapters.json'),
  },
  {
    label: 'asset source adapters',
    path: join(repoRoot, 'data', 'integrations', 'asset-source-adapters.json'),
  },
];

const requiredTopLevel = ['schemaVersion', 'purpose', 'defaultPolicy', 'adapters'];
const requiredAdapterFields = [
  'id',
  'name',
  'sourceReferenceId',
  'url',
  'kind',
  'status',
  'targetPath',
  'supportedTargets',
  'licenseObserved',
  'pluginEntryPoints',
  'validation',
  'notes',
];

const requiredPluginEntryPoints = ['intake', 'validate'];
const requiredValidationFlags = ['manifestRequired', 'licenseReviewRequired', 'artifactReceiptRequired'];

function assertString(value, message) {
  if (!value || typeof value !== 'string') {
    throw new Error(message);
  }
}

function assertBoolean(value, message) {
  if (typeof value !== 'boolean') {
    throw new Error(message);
  }
}

function validateManifest({ label, path }) {
  const manifest = JSON.parse(readFileSync(path, 'utf8'));

  for (const field of requiredTopLevel) {
    if (!(field in manifest)) {
      throw new Error(`${label}: missing top-level field: ${field}`);
    }
  }

  if (!Number.isInteger(manifest.schemaVersion) || manifest.schemaVersion < 1) {
    throw new Error(`${label}: schemaVersion must be a positive integer.`);
  }

  assertString(manifest.purpose, `${label}: purpose must be a non-empty string.`);

  if (!manifest.defaultPolicy || typeof manifest.defaultPolicy !== 'object' || Array.isArray(manifest.defaultPolicy)) {
    throw new Error(`${label}: defaultPolicy must be an object.`);
  }

  for (const field of ['adapterRoot', 'docsRoot', 'shipPolicy', 'preferredUse']) {
    assertString(manifest.defaultPolicy[field], `${label}: defaultPolicy.${field} must be a non-empty string.`);
  }

  if (!Array.isArray(manifest.adapters) || manifest.adapters.length === 0) {
    throw new Error(`${label}: adapters must include at least one entry.`);
  }

  const ids = new Set();

  for (const adapter of manifest.adapters) {
    for (const field of requiredAdapterFields) {
      if (!(field in adapter)) {
        throw new Error(`${label}: adapter ${adapter.id ?? '<unknown>'} is missing field: ${field}`);
      }
    }

    for (const field of ['id', 'name', 'sourceReferenceId', 'url', 'kind', 'status', 'targetPath', 'licenseObserved', 'notes']) {
      assertString(adapter[field], `${label}: adapter ${adapter.id ?? '<unknown>'} must include string field: ${field}`);
    }

    if (ids.has(adapter.id)) {
      throw new Error(`${label}: duplicate adapter id: ${adapter.id}`);
    }
    ids.add(adapter.id);

    if (!/^https?:\/\//.test(adapter.url)) {
      throw new Error(`${label}: adapter ${adapter.id} must use an http(s) URL.`);
    }

    if (!Array.isArray(adapter.supportedTargets) || adapter.supportedTargets.length === 0) {
      throw new Error(`${label}: adapter ${adapter.id} must list supportedTargets.`);
    }

    for (const target of adapter.supportedTargets) {
      assertString(target, `${label}: adapter ${adapter.id} has an invalid supportedTargets entry.`);
    }

    if (!adapter.pluginEntryPoints || typeof adapter.pluginEntryPoints !== 'object' || Array.isArray(adapter.pluginEntryPoints)) {
      throw new Error(`${label}: adapter ${adapter.id} pluginEntryPoints must be an object.`);
    }

    for (const field of requiredPluginEntryPoints) {
      assertString(adapter.pluginEntryPoints[field], `${label}: adapter ${adapter.id} pluginEntryPoints.${field} must be a non-empty string.`);
    }

    if (!adapter.validation || typeof adapter.validation !== 'object' || Array.isArray(adapter.validation)) {
      throw new Error(`${label}: adapter ${adapter.id} validation must be an object.`);
    }

    for (const field of requiredValidationFlags) {
      assertBoolean(adapter.validation[field], `${label}: adapter ${adapter.id} validation.${field} must be boolean.`);
    }

    if (!Array.isArray(adapter.validation.forbiddenOutputs) || adapter.validation.forbiddenOutputs.length === 0) {
      throw new Error(`${label}: adapter ${adapter.id} validation.forbiddenOutputs must list at least one guardrail.`);
    }
  }

  return manifest.adapters.length;
}

const counts = manifests.map((manifest) => [manifest.label, validateManifest(manifest)]);
const summary = counts.map(([label, count]) => `${count} ${label}`).join(', ');
console.log(`Validated integration manifests: ${summary}.`);
