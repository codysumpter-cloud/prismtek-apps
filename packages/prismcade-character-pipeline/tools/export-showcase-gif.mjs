#!/usr/bin/env node
import { existsSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";
import path from "node:path";
import { spawnSync } from "node:child_process";

const args = process.argv.slice(2);
const packDir = args.find((arg) => !arg.startsWith("--")) || "examples/minimal-character-pack";
const planOnly = args.includes("--plan-only");

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
const gifDir = path.join(packDir, "gifs");
ensureDir(gifDir);
const plan = {
  schemaVersion: "prismcade-showcase-gif-plan-v0",
  characterId: manifest.characterId,
  output: "showcase.gif",
  order: ["idle", "walk", "run", "jump", "hurt", "victory", "defeat"].filter((id) => manifest.animations.some((animation) => animation.id === id)),
  fallbackOrder: manifest.animations.map((animation) => animation.id),
  notes: "Export per-animation GIFs first, then use Pixelorama/ImageMagick/ffmpeg to assemble a labeled showcase. This plan keeps the repeatable order in the repo."
};
writeFileSync(path.join(gifDir, "showcase-gif-export-plan.json"), `${JSON.stringify(plan, null, 2)}\n`, "utf8");

if (planOnly || !hasCommand("magick")) {
  console.log(`Wrote showcase GIF export plan. ${hasCommand("magick") ? "Run without --plan-only after per-animation GIFs exist to attempt assembly." : "Install ImageMagick or assemble in Pixelorama."}`);
  process.exit(0);
}

const inputs = (plan.order.length ? plan.order : plan.fallbackOrder)
  .map((id) => path.join(gifDir, `${id}.gif`))
  .filter((file) => existsSync(file));
if (inputs.length === 0) {
  console.warn("No per-animation GIFs found; wrote plan only.");
  process.exit(0);
}
const result = spawnSync("magick", [...inputs, path.join(packDir, "showcase.gif")], { stdio: "inherit" });
process.exit(result.status || 0);
