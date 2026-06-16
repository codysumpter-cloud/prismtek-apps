#!/usr/bin/env node

import { existsSync, readFileSync, statSync } from 'node:fs';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const repoRoot = resolve(dirname(fileURLToPath(import.meta.url)), '..', '..');
const failures = [];

function assertPath(relativePath, label = relativePath) {
  const absolutePath = join(repoRoot, relativePath);
  if (!existsSync(absolutePath)) {
    failures.push(`Missing ${label}: ${relativePath}`);
    return false;
  }
  return true;
}

function assertDirectory(relativePath) {
  const absolutePath = join(repoRoot, relativePath);
  if (!assertPath(relativePath)) return;
  if (!statSync(absolutePath).isDirectory()) {
    failures.push(`Expected directory: ${relativePath}`);
  }
}

function assertFile(relativePath) {
  const absolutePath = join(repoRoot, relativePath);
  if (!assertPath(relativePath)) return;
  if (!statSync(absolutePath).isFile()) {
    failures.push(`Expected file: ${relativePath}`);
  }
}

function readJson(relativePath) {
  try {
    return JSON.parse(readFileSync(join(repoRoot, relativePath), 'utf8'));
  } catch (error) {
    failures.push(`Invalid JSON in ${relativePath}: ${error.message}`);
    return null;
  }
}

for (const directory of ['apps', 'docs', 'experiments', 'games', 'integrations', 'packages', 'tools']) {
  assertDirectory(directory);
}

for (const file of [
  'README.md',
  'package.json',
  'turbo.json',
  'prismtek-apps.code-workspace',
  '.editorconfig',
  '.vscode/extensions.json',
  '.vscode/settings.json',
  '.vscode/tasks.json',
  'docs/development/vscode-workspace.md'
]) {
  assertFile(file);
}

const rootPackage = readJson('package.json');
if (rootPackage) {
  const requiredScripts = [
    'build',
    'dev',
    'games:validate-support',
    'integrations:validate',
    'lint',
    'platforms:validate',
    'references:validate',
    'workspace:doctor'
  ];

  for (const scriptName of requiredScripts) {
    if (!rootPackage.scripts?.[scriptName]) {
      failures.push(`Missing package script: ${scriptName}`);
    }
  }
}

const workspaceFile = readJson('prismtek-apps.code-workspace');
if (workspaceFile) {
  const hasRepoRoot = workspaceFile.folders?.some((folder) => folder.path === '.');
  if (!hasRepoRoot) {
    failures.push('Workspace file must include the repository root folder.');
  }
}

const tasksFile = readJson('.vscode/tasks.json');
if (tasksFile) {
  const taskLabels = new Set((tasksFile.tasks ?? []).map((task) => task.label));
  for (const taskLabel of [
    'Prismtek: workspace doctor',
    'Prismtek: lint',
    'Prismtek: build',
    'Prismtek: validate games',
    'Game: Pixel Fruit Arena test'
  ]) {
    if (!taskLabels.has(taskLabel)) {
      failures.push(`Missing VS Code task: ${taskLabel}`);
    }
  }
}

if (failures.length > 0) {
  console.error('Prismtek workspace doctor failed:');
  for (const failure of failures) {
    console.error(`- ${failure}`);
  }
  process.exit(1);
}

console.log('Prismtek workspace doctor passed. VS Code workspace scaffolding is present.');
