#!/usr/bin/env node
import { existsSync, readFileSync } from "node:fs";
import path from "node:path";

const root = process.cwd();
const registryPath = path.join(root, "data/prismcade/animation-source-registry.json");
let failures = 0;

function fail(message) {
  failures += 1;
  console.error(message);
}

if (!existsSync(registryPath)) {
  fail("Missing data/prismcade/animation-source-registry.json");
} else {
  let registry;
  try {
    registry = JSON.parse(readFileSync(registryPath, "utf8"));
  } catch (error) {
    fail(`Registry is not valid JSON: ${error.message}`);
  }

  if (registry) {
    if (!Array.isArray(registry.sources) || registry.sources.length === 0) {
      fail("Registry must include at least one source");
    } else {
      for (const source of registry.sources) {
        if (!source.id) fail("Source missing id");
        if (!source.type) fail(`${source.id || "unknown"} missing type`);
        if (!source.status) fail(`${source.id || "unknown"} missing status`);
        if (!source.sourcePath) fail(`${source.id || "unknown"} missing sourcePath`);
      }
    }
  }
}

if (failures > 0) {
  process.exitCode = 1;
} else {
  console.log("Prismcade animation source registry is valid.");
}
