import { cp, mkdir, rm } from "node:fs/promises";
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
console.log("Build complete. USE_REFERENCE_TEST_ASSETS forced false for release artifacts.");
