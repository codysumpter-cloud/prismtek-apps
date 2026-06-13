import { existsSync } from "node:fs";
import { readdir, stat } from "node:fs/promises";
import path from "node:path";
import { fileURLToPath } from "node:url";

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const dist = path.join(root, "dist");
const requiredEntries = ["index.html", "app.webmanifest", "sw.js", "src", "data", "assets"];

if (!existsSync(dist)) throw new Error("dist/ is missing. Run npm run build first.");

for (const entry of requiredEntries) {
  const absolute = path.join(dist, entry);
  if (!existsSync(absolute)) throw new Error(`dist/${entry} is missing from the web build.`);
}

const referencePath = path.join(dist, "assets", "reference");
if (existsSync(referencePath)) throw new Error("dist/assets/reference must not be present in release builds.");

const files = await walkFiles(dist);
const gifLeaks = files.filter((file) => file.toLowerCase().endsWith(".gif"));
if (gifLeaks.length > 0) {
  throw new Error(`GIF assets leaked into release build:\n${gifLeaks.join("\n")}`);
}

console.log(`Validated Pixel Fruit Arena dist: ${files.length} files, no reference assets, no GIF leaks.`);

async function walkFiles(dir) {
  const entries = await readdir(dir, { withFileTypes: true });
  const files = [];
  for (const entry of entries) {
    const absolute = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      files.push(...await walkFiles(absolute));
    } else if (entry.isFile()) {
      await stat(absolute);
      files.push(path.relative(dist, absolute).replaceAll(path.sep, "/"));
    }
  }
  return files.sort();
}
