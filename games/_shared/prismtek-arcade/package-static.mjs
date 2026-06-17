import { existsSync } from "node:fs";
import { mkdir, readdir, readFile, rm, stat, writeFile } from "node:fs/promises";
import path from "node:path";

const gameArg = process.argv[2] ?? ".";
const gameDir = path.resolve(gameArg);
const packagePath = path.join(gameDir, "package.json");
const indexPath = path.join(gameDir, "index.html");

if (!existsSync(indexPath)) {
  throw new Error(`missing index.html in ${gameDir}`);
}

let slug = path.basename(gameDir);
if (existsSync(packagePath)) {
  const pkg = JSON.parse(await readFile(packagePath, "utf8"));
  slug = (pkg.name ?? slug).split("/").pop().replace(/^@/, "") || slug;
}

const artifacts = path.join(gameDir, "artifacts");
const zipPath = path.join(artifacts, `${slug}-web.zip`);
const excludedDirectories = new Set([
  ".git",
  ".package-web-tmp",
  "artifacts",
  "dist",
  "docs",
  "ds-homebrew",
  "node_modules",
  "tools"
]);
const excludedFiles = new Set(["package-lock.json"]);

const filePaths = await walkFiles(gameDir);
if (!filePaths.includes("index.html")) {
  throw new Error("packaged web ZIP must include index.html at the archive root");
}

await mkdir(artifacts, { recursive: true });
await rm(zipPath, { force: true });

const localParts = [];
const centralParts = [];
let offset = 0;

for (const relativePath of filePaths) {
  const absolutePath = path.join(gameDir, relativePath);
  const data = await readFile(absolutePath);
  const name = Buffer.from(relativePath.replaceAll(path.sep, "/"));
  const crc = crc32(data);
  const { dosTime, dosDate } = dosTimestamp(new Date());

  const localHeader = Buffer.alloc(30);
  localHeader.writeUInt32LE(0x04034b50, 0);
  localHeader.writeUInt16LE(20, 4);
  localHeader.writeUInt16LE(0, 6);
  localHeader.writeUInt16LE(0, 8);
  localHeader.writeUInt16LE(dosTime, 10);
  localHeader.writeUInt16LE(dosDate, 12);
  localHeader.writeUInt32LE(crc, 14);
  localHeader.writeUInt32LE(data.length, 18);
  localHeader.writeUInt32LE(data.length, 22);
  localHeader.writeUInt16LE(name.length, 26);
  localHeader.writeUInt16LE(0, 28);
  localParts.push(localHeader, name, data);

  const centralHeader = Buffer.alloc(46);
  centralHeader.writeUInt32LE(0x02014b50, 0);
  centralHeader.writeUInt16LE(20, 4);
  centralHeader.writeUInt16LE(20, 6);
  centralHeader.writeUInt16LE(0, 8);
  centralHeader.writeUInt16LE(0, 10);
  centralHeader.writeUInt16LE(dosTime, 12);
  centralHeader.writeUInt16LE(dosDate, 14);
  centralHeader.writeUInt32LE(crc, 16);
  centralHeader.writeUInt32LE(data.length, 20);
  centralHeader.writeUInt32LE(data.length, 24);
  centralHeader.writeUInt16LE(name.length, 28);
  centralHeader.writeUInt16LE(0, 30);
  centralHeader.writeUInt16LE(0, 32);
  centralHeader.writeUInt16LE(0, 34);
  centralHeader.writeUInt16LE(0, 36);
  centralHeader.writeUInt32LE(0, 38);
  centralHeader.writeUInt32LE(offset, 42);
  centralParts.push(centralHeader, name);
  offset += localHeader.length + name.length + data.length;
}

const centralDirectory = Buffer.concat(centralParts);
const end = Buffer.alloc(22);
end.writeUInt32LE(0x06054b50, 0);
end.writeUInt16LE(0, 4);
end.writeUInt16LE(0, 6);
end.writeUInt16LE(filePaths.length, 8);
end.writeUInt16LE(filePaths.length, 10);
end.writeUInt32LE(centralDirectory.length, 12);
end.writeUInt32LE(offset, 16);
end.writeUInt16LE(0, 20);

await writeFile(zipPath, Buffer.concat([...localParts, centralDirectory, end]));
console.log(`Created ${path.relative(gameDir, zipPath)} (${filePaths.length} files).`);

async function walkFiles(dir) {
  const entries = await readdir(dir, { withFileTypes: true });
  const files = [];
  for (const entry of entries) {
    if (excludedDirectories.has(entry.name)) continue;
    if (excludedFiles.has(entry.name)) continue;
    const absolute = path.join(dir, entry.name);
    const relative = path.relative(gameDir, absolute).replaceAll(path.sep, "/");
    if (entry.isDirectory()) {
      files.push(...await walkFiles(absolute));
    } else if (entry.isFile()) {
      await stat(absolute);
      files.push(relative);
    }
  }
  return files.sort();
}

function dosTimestamp(date) {
  const year = Math.max(1980, date.getFullYear());
  const dosTime = (date.getHours() << 11) | (date.getMinutes() << 5) | Math.floor(date.getSeconds() / 2);
  const dosDate = ((year - 1980) << 9) | ((date.getMonth() + 1) << 5) | date.getDate();
  return { dosTime, dosDate };
}

const crcTable = Array.from({ length: 256 }, (_, index) => {
  let c = index;
  for (let k = 0; k < 8; k += 1) c = c & 1 ? 0xedb88320 ^ (c >>> 1) : c >>> 1;
  return c >>> 0;
});

function crc32(buffer) {
  let crc = 0xffffffff;
  for (const byte of buffer) crc = crcTable[(crc ^ byte) & 0xff] ^ (crc >>> 8);
  return (crc ^ 0xffffffff) >>> 0;
}
