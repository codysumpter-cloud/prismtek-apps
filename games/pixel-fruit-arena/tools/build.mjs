import { cp, mkdir, readdir, rm } from "node:fs/promises";
import { existsSync } from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const dist = path.join(root, "dist");
await rm(dist, { recursive: true, force: true });
await mkdir(dist, { recursive: true });
for (const entry of ["index.html", "src", "data", "assets"]) {
  await cp(path.join(root, entry), path.join(dist, entry), { recursive: true });
}
const referencePath = path.join(dist, "assets", "reference");
await rm(referencePath, { recursive: true, force: true });
if (existsSync(referencePath)) throw new Error("Reference assets leaked into release build");

const leakedGifs = await findFilesByExtension(dist, ".gif");
if (leakedGifs.length > 0) {
  throw new Error(`GIF assets leaked into release build:\n${leakedGifs.join("\n")}`);
}

console.log("Build complete. Reference assets and GIF files excluded from release artifacts.");

async function findFilesByExtension(dir, extension) {
  if (!existsSync(dir)) return [];
  const entries = await readdir(dir, { withFileTypes: true });
  const matches = [];
  for (const entry of entries) {
    const absolute = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      matches.push(...await findFilesByExtension(absolute, extension));
    } else if (entry.isFile() && path.extname(entry.name).toLowerCase() === extension) {
      matches.push(path.relative(dist, absolute));
    }
  }
  return matches;
}
