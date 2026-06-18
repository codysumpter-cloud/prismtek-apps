#!/usr/bin/env node
import { existsSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";
import path from "node:path";
import { spawnSync } from "node:child_process";

const args = process.argv.slice(2);
const packDir = args.find((arg) => !arg.startsWith("--")) || "examples/minimal-character-pack";
const planOnly = args.includes("--plan-only");
const outDirArgIndex = args.indexOf("--out-dir");
const outDir = outDirArgIndex >= 0 ? args[outDirArgIndex + 1] : path.join(packDir, "gifs");

function readJson(file) {
  return JSON.parse(readFileSync(file, "utf8"));
}

function ensureDir(dir) {
  mkdirSync(dir, { recursive: true });
}

function hasCommand(command) {
  const result = spawnSync(process.platform === "win32" ? "where" : "which", [command], { encoding: "utf8" });
  return result.status === 0;
}

const manifestPath = path.join(packDir, "manifest.json");
if (!existsSync(manifestPath)) {
  console.error(`Missing ${manifestPath}`);
  process.exit(1);
}

const manifest = readJson(manifestPath);
const plan = {
  schemaVersion: "prismcade-gif-export-plan-v0",
  characterId: manifest.characterId,
  generatedAt: new Date().toISOString(),
  toolPreference: ["magick", "convert", "pixelorama-cli"],
  outputs: manifest.animations.map((animation) => ({
    animationId: animation.id,
    input: animation.source,
    output: `gifs/${animation.id}.gif`,
    frameWidth: animation.frameWidth,
    frameHeight: animation.frameHeight,
    frameCount: animation.frameCount,
    fps: animation.fps,
    loop: animation.loop
  }))
};

ensureDir(outDir);
writeFileSync(path.join(outDir, "animation-gif-export-plan.json"), `${JSON.stringify(plan, null, 2)}\n`, "utf8");

const magick = hasCommand("magick") ? "magick" : hasCommand("convert") ? "convert" : null;
if (planOnly || !magick) {
  console.log(`Wrote GIF export plan for ${plan.outputs.length} animation(s). ${magick ? "Run without --plan-only to export with ImageMagick." : "Install ImageMagick or export from Pixelorama to render GIF files."}`);
  process.exit(0);
}

for (const output of plan.outputs) {
  const inputPath = path.join(packDir, output.input);
  if (!existsSync(inputPath)) {
    console.warn(`Skipping ${output.animationId}: missing ${output.input}`);
    continue;
  }
  const delay = Math.max(1, Math.round(100 / output.fps));
  const target = path.join(packDir, output.output);
  ensureDir(path.dirname(target));
  const result = spawnSync(magick, [inputPath, "-crop", `${output.frameWidth}x${output.frameHeight}`, "+repage", "-set", "delay", String(delay), "-loop", output.loop ? "0" : "1", target], { stdio: "inherit" });
  if (result.status !== 0) process.exit(result.status || 1);
}

console.log(`Exported animation GIFs to ${outDir}`);
