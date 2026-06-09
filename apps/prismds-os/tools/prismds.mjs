#!/usr/bin/env node
import { access, mkdir, readdir, readFile, stat, writeFile } from 'node:fs/promises';
import { constants } from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import process from 'node:process';

const ROOT = path.resolve(new URL('..', import.meta.url).pathname);
const DEFAULT_HOME = path.join(os.homedir(), '.local', 'share', 'prismds');
const REQUIRED_REPO_FILES = [
  'README.md',
  'profiles/rgds.json',
  'profiles/emulators/azahar.json',
  'profiles/emulators/lowlevel-3ds.json',
  'configs/prismds.config.json',
  'configs/emulationstation/es_systems_3ds.xml',
  'configs/systemd/prismds-session.service',
  'configs/desktop/prismds.desktop',
  'scripts/install-prismds.sh',
  'scripts/uninstall-prismds.sh',
  'scripts/launch-azahar.sh',
  'scripts/launch-lowlevel-3ds.sh',
  'scripts/validate-local-3ds-lab-files.sh',
  'scripts/performance-mode.sh',
  'scripts/install-azahar-android-adb.sh'
];

const RUNTIME_DIRS = [
  'apps/azahar',
  'apps/lowlevel-3ds',
  'bios/3ds/local-system-files',
  'bin',
  'configs',
  'logs/prismds',
  'roms/3ds',
  'saves/3ds',
  'screenshots/3ds',
  'states/3ds',
  'tmp'
];

function usage() {
  console.log(`PrismDS OS Layer

Usage:
  prismds check              Validate repo package files
  prismds build              Build a distributable manifest under dist/
  prismds doctor             Inspect this device/runtime install
  prismds emit-install-plan  Print the directories the installer will create

Environment:
  PRISMDS_HOME  Override runtime install path. Default: ${DEFAULT_HOME}
`);
}

async function exists(filePath) {
  try {
    await access(filePath, constants.F_OK);
    return true;
  } catch {
    return false;
  }
}

async function fileSize(filePath) {
  try {
    return (await stat(filePath)).size;
  } catch {
    return 0;
  }
}

async function commandExists(command) {
  const pathVar = process.env.PATH ?? '';
  const suffixes = process.platform === 'win32' ? ['.exe', '.cmd', '.bat', ''] : [''];
  for (const base of pathVar.split(path.delimiter)) {
    for (const suffix of suffixes) {
      if (await exists(path.join(base, `${command}${suffix}`))) return true;
    }
  }
  return false;
}

async function checkRepo() {
  const missing = [];
  for (const rel of REQUIRED_REPO_FILES) {
    if (!(await exists(path.join(ROOT, rel)))) missing.push(rel);
  }

  const profiles = [
    'profiles/rgds.json',
    'profiles/emulators/azahar.json',
    'profiles/emulators/lowlevel-3ds.json',
    'configs/prismds.config.json'
  ];
  for (const rel of profiles) {
    JSON.parse(await readFile(path.join(ROOT, rel), 'utf8'));
  }

  if (missing.length) {
    console.error('Missing required files:');
    for (const file of missing) console.error(`- ${file}`);
    process.exitCode = 1;
    return;
  }

  console.log(`OK: PrismDS repo package is complete (${REQUIRED_REPO_FILES.length} required files).`);
}

async function build() {
  await checkRepo();
  const dist = path.join(ROOT, 'dist');
  await mkdir(dist, { recursive: true });
  const manifest = {
    name: '@prismtek/prismds-os',
    version: JSON.parse(await readFile(path.join(ROOT, 'package.json'), 'utf8')).version,
    builtAt: new Date().toISOString(),
    target: 'Anbernic RG DS / RK3568 / Android + Linux',
    files: REQUIRED_REPO_FILES,
    runtimeDirs: RUNTIME_DIRS
  };
  await writeFile(path.join(dist, 'manifest.json'), `${JSON.stringify(manifest, null, 2)}\n`);
  console.log(`Built ${path.relative(process.cwd(), path.join(dist, 'manifest.json'))}`);
}

async function emitInstallPlan() {
  const home = process.env.PRISMDS_HOME || DEFAULT_HOME;
  console.log(`Install root: ${home}`);
  for (const dir of RUNTIME_DIRS) console.log(`mkdir -p ${path.join(home, dir)}`);
}

async function doctor() {
  const home = process.env.PRISMDS_HOME || DEFAULT_HOME;
  console.log('PrismDS doctor');
  console.log(`Platform: ${process.platform} ${process.arch}`);
  console.log(`Node: ${process.version}`);
  console.log(`Runtime root: ${home}`);

  const release = await exists('/etc/os-release') ? await readFile('/etc/os-release', 'utf8') : '';
  const isLikelyLinux = process.platform === 'linux';
  const isArm = ['arm', 'arm64'].includes(process.arch);
  console.log(`Linux: ${isLikelyLinux ? 'yes' : 'no'}`);
  console.log(`ARM: ${isArm ? 'yes' : 'no'}`);
  if (release) {
    const pretty = release.split('\n').find((line) => line.startsWith('PRETTY_NAME='));
    if (pretty) console.log(pretty.replace('PRETTY_NAME=', 'OS: ').replaceAll('"', ''));
  }

  const checks = [
    ['Azahar binary', path.join(home, 'apps/azahar/Azahar.AppImage')],
    ['Low-level 3DS lab binary', path.join(home, 'apps/lowlevel-3ds/emulator')],
    ['3DS content folder', path.join(home, 'roms/3ds')],
    ['Local system-file folder', path.join(home, 'bios/3ds/local-system-files')],
    ['PrismDS bin folder', path.join(home, 'bin')]
  ];
  for (const [label, target] of checks) {
    console.log(`${label}: ${(await exists(target)) ? 'found' : 'missing'} (${target})`);
  }

  console.log(`adb: ${(await commandExists('adb')) ? 'found' : 'missing'}`);
  console.log(`emulationstation: ${(await commandExists('emulationstation')) ? 'found' : 'missing'}`);

  const labRoot = path.join(home, 'bios/3ds/local-system-files');
  if (await exists(labRoot)) {
    const entries = await readdir(labRoot);
    const totalBytes = (await Promise.all(entries.map((entry) => fileSize(path.join(labRoot, entry))))).reduce((sum, size) => sum + size, 0);
    console.log(`Local lab system files: ${entries.length} file(s), ${totalBytes} bytes`);
  }

  const romDir = path.join(home, 'roms/3ds');
  if (await exists(romDir)) {
    const entries = await readdir(romDir);
    const content = entries.filter((name) => /\.(3ds|cci|cxi|cia)$/i.test(name));
    console.log(`3DS content: ${content.length} file(s)`);
  }
}

const command = process.argv[2] ?? 'help';
try {
  if (command === 'check') await checkRepo();
  else if (command === 'build') await build();
  else if (command === 'doctor') await doctor();
  else if (command === 'emit-install-plan') await emitInstallPlan();
  else usage();
} catch (error) {
  console.error(error instanceof Error ? error.message : error);
  process.exitCode = 1;
}
