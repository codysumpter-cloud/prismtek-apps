#!/usr/bin/env node
import assert from "node:assert/strict";
import { existsSync, readFileSync } from "node:fs";
import path from "node:path";
import { readPngInfo } from "./lib/png-info.mjs";

const args = process.argv.slice(2);
const flags = new Set(args.filter((arg) => arg.startsWith("--")));
const packDirs = args.filter((arg) => !arg.startsWith("--"));
const allowMissingAssets = flags.has("--allow-missing-assets") || !flags.has("--strict-assets");
const strictAssets = flags.has("--strict-assets");

if (packDirs.length === 0) packDirs.push("examples/minimal-character-pack");

const allowedSourceTools = new Set(["pixellab", "pixelorama", "manual", "generated", "mixed", "contract"]);
const requiredBaseAnimations = ["idle", "walk", "hurt"];

function readJson(file) {
  return JSON.parse(readFileSync(file, "utf8"));
}

function assertString(value, label) {
  assert.equal(typeof value, "string", `${label} must be a string`);
  assert.ok(value.trim().length > 0, `${label} cannot be empty`);
}

function assertNumber(value, label) {
  assert.equal(typeof value, "number", `${label} must be a number`);
  assert.ok(Number.isFinite(value), `${label} must be finite`);
}

function assertPositiveInteger(value, label) {
  assertNumber(value, label);
  assert.equal(Number.isInteger(value), true, `${label} must be an integer`);
  assert.ok(value > 0, `${label} must be positive`);
}

function assertBoolean(value, label) {
  assert.equal(typeof value, "boolean", `${label} must be a boolean`);
}

function assertArray(value, label) {
  assert.ok(Array.isArray(value), `${label} must be an array`);
}

function assertObject(value, label) {
  assert.ok(value && typeof value === "object" && !Array.isArray(value), `${label} must be an object`);
}

function assertRelativeRepoPath(value, label) {
  assertString(value, label);
  assert.ok(!path.isAbsolute(value), `${label} must be relative, not absolute`);
  assert.ok(!value.split(/[\\/]+/).includes(".."), `${label} must not contain ..`);
}

function assertRect(rect, label, frameWidth, frameHeight) {
  assertObject(rect, label);
  for (const key of ["x", "y", "width", "height"]) assertNumber(rect[key], `${label}.${key}`);
  assert.ok(rect.width > 0, `${label}.width must be > 0`);
  assert.ok(rect.height > 0, `${label}.height must be > 0`);
  assert.ok(rect.x >= 0 && rect.y >= 0, `${label} must start inside the frame`);
  assert.ok(rect.x + rect.width <= frameWidth, `${label} must fit inside frame width`);
  assert.ok(rect.y + rect.height <= frameHeight, `${label} must fit inside frame height`);
}

function assertAnchor(anchor, label, frameWidth, frameHeight) {
  assertObject(anchor, label);
  assertNumber(anchor.x, `${label}.x`);
  assertNumber(anchor.y, `${label}.y`);
  assert.ok(anchor.x >= 0 && anchor.x <= frameWidth, `${label}.x must be inside frame`);
  assert.ok(anchor.y >= 0 && anchor.y <= frameHeight, `${label}.y must be inside frame`);
}

function validatePngSource(packDir, animation, prefix, allowMissing) {
  const sourcePath = path.join(packDir, animation.source);
  if (!existsSync(sourcePath)) {
    if (allowMissing) return { skipped: true };
    assert.fail(`${prefix}: missing animation source ${animation.source}`);
  }

  const info = readPngInfo(sourcePath);
  const columns = animation.columns ?? animation.frameCount;
  const rows = animation.rows ?? 1;
  assertPositiveInteger(columns, `${prefix}.columns`);
  assertPositiveInteger(rows, `${prefix}.rows`);
  assert.ok(animation.frameCount <= columns * rows, `${prefix}.frameCount cannot exceed columns * rows`);
  assert.equal(info.width, animation.frameWidth * columns, `${prefix}: PNG width must equal frameWidth * columns`);
  assert.equal(info.height, animation.frameHeight * rows, `${prefix}: PNG height must equal frameHeight * rows`);
  return { skipped: false, info };
}

function validatePack(packDirInput) {
  const packDir = path.resolve(packDirInput);
  const metadataPath = path.join(packDir, "metadata.json");
  const manifestPath = path.join(packDir, "manifest.json");

  assert.ok(existsSync(metadataPath), `Missing ${path.relative(process.cwd(), metadataPath)}`);
  assert.ok(existsSync(manifestPath), `Missing ${path.relative(process.cwd(), manifestPath)}`);

  const metadata = readJson(metadataPath);
  const manifest = readJson(manifestPath);
  const packLabel = metadata.characterId || path.basename(packDir);

  assert.equal(metadata.schemaVersion, "prismcade-character-pack-v0", `${packLabel}.metadata.schemaVersion is invalid`);
  assert.equal(manifest.schemaVersion, "prismcade-animation-manifest-v0", `${packLabel}.manifest.schemaVersion is invalid`);
  assertString(metadata.characterId, `${packLabel}.metadata.characterId`);
  assertString(metadata.displayName, `${packLabel}.metadata.displayName`);
  assertString(metadata.sourceTool, `${packLabel}.metadata.sourceTool`);
  assert.ok(allowedSourceTools.has(metadata.sourceTool), `${packLabel}.metadata.sourceTool must be one of ${[...allowedSourceTools].join(", ")}`);
  assert.equal(manifest.characterId, metadata.characterId, `${packLabel}.manifest.characterId must match metadata.characterId`);

  assertObject(metadata.targetFrame, `${packLabel}.metadata.targetFrame`);
  assertPositiveInteger(metadata.targetFrame.width, `${packLabel}.metadata.targetFrame.width`);
  assertPositiveInteger(metadata.targetFrame.height, `${packLabel}.metadata.targetFrame.height`);
  assertBoolean(metadata.transparentBackground, `${packLabel}.metadata.transparentBackground`);

  assertPositiveInteger(manifest.frameWidth, `${packLabel}.manifest.frameWidth`);
  assertPositiveInteger(manifest.frameHeight, `${packLabel}.manifest.frameHeight`);
  assert.equal(manifest.frameWidth, metadata.targetFrame.width, `${packLabel}: manifest and metadata frame width must match`);
  assert.equal(manifest.frameHeight, metadata.targetFrame.height, `${packLabel}: manifest and metadata frame height must match`);

  assertAnchor(manifest.anchor, `${packLabel}.manifest.anchor`, manifest.frameWidth, manifest.frameHeight);
  assertNumber(manifest.baselineY, `${packLabel}.manifest.baselineY`);
  assert.ok(manifest.baselineY >= manifest.frameHeight * 0.7 && manifest.baselineY <= manifest.frameHeight, `${packLabel}.manifest.baselineY should be near the lower part of the frame`);

  assertArray(manifest.requiredAnimations, `${packLabel}.manifest.requiredAnimations`);
  for (const required of requiredBaseAnimations) {
    assert.ok(manifest.requiredAnimations.includes(required), `${packLabel}.manifest.requiredAnimations must include ${required}`);
  }

  assertArray(manifest.animations, `${packLabel}.manifest.animations`);
  assert.ok(manifest.animations.length > 0, `${packLabel}.manifest.animations must not be empty`);

  const ids = new Set();
  const assetMode = metadata.assetMode || "assets-required";
  const allowMissing = allowMissingAssets || assetMode === "contract-only";
  let checkedAssets = 0;
  let skippedAssets = 0;

  for (const [index, animation] of manifest.animations.entries()) {
    const prefix = `${packLabel}.animations[${index}] ${animation?.id || "(missing id)"}`;
    assertString(animation.id, `${prefix}.id`);
    assert.ok(!ids.has(animation.id), `${packLabel}: duplicate animation id ${animation.id}`);
    ids.add(animation.id);

    assertRelativeRepoPath(animation.source, `${prefix}.source`);
    assertPositiveInteger(animation.frameWidth, `${prefix}.frameWidth`);
    assertPositiveInteger(animation.frameHeight, `${prefix}.frameHeight`);
    assert.equal(animation.frameWidth, manifest.frameWidth, `${prefix}.frameWidth must match manifest.frameWidth`);
    assert.equal(animation.frameHeight, manifest.frameHeight, `${prefix}.frameHeight must match manifest.frameHeight`);
    assertPositiveInteger(animation.frameCount, `${prefix}.frameCount`);
    assertNumber(animation.fps, `${prefix}.fps`);
    assert.ok(animation.fps > 0 && animation.fps <= 60, `${prefix}.fps must be between 0 and 60`);
    assertBoolean(animation.loop, `${prefix}.loop`);
    assertAnchor(animation.anchor || manifest.anchor, `${prefix}.anchor`, animation.frameWidth, animation.frameHeight);
    assertNumber(animation.baselineY ?? manifest.baselineY, `${prefix}.baselineY`);
    assertRect(animation.hitbox, `${prefix}.hitbox`, animation.frameWidth, animation.frameHeight);
    assertRect(animation.hurtbox, `${prefix}.hurtbox`, animation.frameWidth, animation.frameHeight);
    assertArray(animation.tags, `${prefix}.tags`);
    for (const tag of animation.tags) assertString(tag, `${prefix}.tags[]`);

    if (["idle", "walk"].includes(animation.id)) {
      const baseline = animation.baselineY ?? manifest.baselineY;
      assert.ok(baseline >= animation.frameHeight * 0.75, `${prefix}: idle/walk baseline must be low enough to catch foot clipping`);
      assert.ok(animation.hurtbox.y + animation.hurtbox.height >= animation.frameHeight * 0.85, `${prefix}: hurtbox should cover feet/baseline area`);
    }

    const assetCheck = validatePngSource(packDir, animation, prefix, allowMissing);
    if (assetCheck.skipped) skippedAssets += 1;
    else checkedAssets += 1;
  }

  for (const required of manifest.requiredAnimations) {
    assert.ok(ids.has(required), `${packLabel}: required animation ${required} is missing from animations[]`);
  }

  assertArray(metadata.provenance, `${packLabel}.metadata.provenance`);
  for (const [index, item] of metadata.provenance.entries()) {
    assertObject(item, `${packLabel}.metadata.provenance[${index}]`);
    assertString(item.type, `${packLabel}.metadata.provenance[${index}].type`);
    assertString(item.note, `${packLabel}.metadata.provenance[${index}].note`);
  }

  if (strictAssets && skippedAssets > 0) assert.fail(`${packLabel}: ${skippedAssets} assets were skipped in strict mode`);

  console.log(`${metadata.characterId}: ${manifest.animations.length} animations validated (${checkedAssets} assets checked, ${skippedAssets} assets skipped).`);
}

for (const packDir of packDirs) validatePack(packDir);
