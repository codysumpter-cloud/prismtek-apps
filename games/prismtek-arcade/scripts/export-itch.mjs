import { mkdirSync, rmSync, existsSync } from "node:fs";
import { copyFile, cp } from "node:fs/promises";
import { join } from "node:path";
import { spawnSync } from "node:child_process";

const root = process.cwd();
const dist = join(root, "dist");
const artifacts = join(root, "artifacts");
const staging = join(artifacts, "itch");
const zipPath = join(artifacts, "prismtek-arcade-itch.zip");

if (!existsSync(join(dist, "index.html"))) {
  throw new Error("dist/index.html is missing. Run npm run build first.");
}

mkdirSync(artifacts, { recursive: true });
rmSync(staging, { recursive: true, force: true });
rmSync(zipPath, { force: true });
mkdirSync(staging, { recursive: true });
await cp(dist, staging, { recursive: true });

const zip = spawnSync("zip", ["-r", zipPath, "."], {
  cwd: staging,
  stdio: "inherit"
});

if (zip.status !== 0) {
  await copyFile(join(staging, "index.html"), join(artifacts, "index.html"));
  throw new Error("zip command failed or is unavailable. Staged itch files were left in artifacts/itch.");
}

console.log(`Created ${zipPath}`);
