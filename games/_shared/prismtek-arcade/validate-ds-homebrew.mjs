import assert from "node:assert/strict";
import { existsSync, readFileSync } from "node:fs";
import path from "node:path";

const gameDirs = process.argv.slice(2);
if (gameDirs.length === 0) {
  throw new Error("usage: node games/_shared/prismtek-arcade/validate-ds-homebrew.mjs <game-dir> [...game-dir]");
}

for (const gameDirArg of gameDirs) {
  const gameDir = path.resolve(gameDirArg);
  const dsDir = path.join(gameDir, "ds-homebrew");
  const readmePath = path.join(dsDir, "README.md");
  const makefilePath = path.join(dsDir, "Makefile");
  const mainPath = path.join(dsDir, "source", "main.c");

  assert.ok(existsSync(dsDir), `${gameDirArg}: missing ds-homebrew/`);
  assert.ok(existsSync(readmePath), `${gameDirArg}: missing ds-homebrew/README.md`);
  assert.ok(existsSync(makefilePath), `${gameDirArg}: missing ds-homebrew/Makefile`);
  assert.ok(existsSync(mainPath), `${gameDirArg}: missing ds-homebrew/source/main.c`);

  const readme = readFileSync(readmePath, "utf8");
  const makefile = readFileSync(makefilePath, "utf8");
  const main = readFileSync(mainPath, "utf8");

  assert.match(readme, /devkitPro|libnds/i, `${gameDirArg}: README must name the DS toolchain`);
  assert.match(readme, /\.nds/i, `${gameDirArg}: README must document the .nds output`);
  assert.match(makefile, /ds_rules/, `${gameDirArg}: Makefile must include devkitARM ds_rules`);
  assert.match(makefile, /\.nds/, `${gameDirArg}: Makefile must build an .nds target`);
  assert.match(main, /#include\s+<nds\.h>/, `${gameDirArg}: source/main.c must include nds.h`);
  assert.match(main, /scanKeys\s*\(/, `${gameDirArg}: source/main.c must scan DS input`);
  assert.match(main, /swiWaitForVBlank\s*\(/, `${gameDirArg}: source/main.c must wait for VBlank`);
  assert.doesNotMatch(`${readme}\n${makefile}\n${main}`, /TODO:|TBD|not implemented/i, `${gameDirArg}: DS source receipts must not be placeholder TODOs`);

  console.log(`DS homebrew source receipt passed: ${path.basename(gameDir)}`);
}
