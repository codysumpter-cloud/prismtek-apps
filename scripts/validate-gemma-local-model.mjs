#!/usr/bin/env node

import fs from "node:fs";
import path from "node:path";
import process from "node:process";

const DEFAULT_MODEL_ROOTS = [
  "apps/bemore-ios-native/LocalModels",
  "apps/bemore-ios-native/BeMoreAgentShell/LocalModels",
  "apps/bemore-ios-native/BeMoreAgentShell/Resources/Models",
  "apps/bemore-ios-native/BeMoreAgentShell/Models",
];

const REQUIRED_MLC_MARKERS = ["mlc-chat-config.json", "tokenizer.json", "params_shard_0.bin"];
const GOOGLE_EDGE_EXTENSIONS = new Set([".task", ".bin"]);
const DISCOURAGED_EXTENSIONS = new Set([".gguf", ".safetensors", ".pth", ".pt"]);

function parseArgs(argv) {
  const args = { paths: [], strict: false, json: false };
  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    if (arg === "--path" || arg === "-p") {
      args.paths.push(argv[++index]);
    } else if (arg === "--strict") {
      args.strict = true;
    } else if (arg === "--json") {
      args.json = true;
    } else if (arg === "--help" || arg === "-h") {
      args.help = true;
    } else {
      throw new Error(`Unknown argument: ${arg}`);
    }
  }
  return args;
}

function printHelp() {
  console.log(`Usage: validate-gemma-local-model.mjs [options]

Checks whether local Gemma model artifacts look suitable for the BeMore iOS local model path.
No model binaries are expected in git.

Options:
  -p, --path <path>   Check a model file or folder. Can be passed multiple times.
      --strict        Exit non-zero when no usable local artifact is found.
      --json          Print machine-readable JSON.
  -h, --help          Show this help.

Examples:
  node scripts/validate-gemma-local-model.mjs
  node scripts/validate-gemma-local-model.mjs --path ~/Downloads/gemma-4-e2b-it.task
  node scripts/validate-gemma-local-model.mjs --path ./LocalModels/gemma-4-e2b-it-q4f16_1-MLC
`);
}

function exists(candidate) {
  return fs.existsSync(candidate);
}

function stat(candidate) {
  try {
    return fs.statSync(candidate);
  } catch {
    return null;
  }
}

function listFilesRecursive(root, maxDepth = 2, depth = 0) {
  const found = [];
  const rootStat = stat(root);
  if (!rootStat) return found;
  if (rootStat.isFile()) return [root];
  if (!rootStat.isDirectory() || depth > maxDepth) return found;

  for (const entry of fs.readdirSync(root, { withFileTypes: true })) {
    const fullPath = path.join(root, entry.name);
    if (entry.isDirectory()) {
      found.push(...listFilesRecursive(fullPath, maxDepth, depth + 1));
    } else {
      found.push(fullPath);
    }
  }
  return found;
}

function classifyArtifact(candidate) {
  const absolutePath = path.resolve(candidate);
  const candidateStat = stat(absolutePath);
  const result = {
    path: absolutePath,
    exists: Boolean(candidateStat),
    kind: "missing",
    status: "missing",
    messages: [],
    warnings: [],
  };

  if (!candidateStat) {
    result.messages.push("Path does not exist.");
    return result;
  }

  if (candidateStat.isDirectory()) {
    const hasAllMarkers = REQUIRED_MLC_MARKERS.every((marker) => exists(path.join(absolutePath, marker)));
    if (hasAllMarkers) {
      result.kind = "mlc-package";
      result.status = "usable-when-mlc-runtime-linked";
      result.messages.push("Prepared MLC package markers found.");
      result.warnings.push("This is not the official Google mobile default, but it can work if MLCSwift/TVM is linked in the iOS build.");
      return result;
    }

    const nestedFiles = listFilesRecursive(absolutePath, 2);
    const edgeFiles = nestedFiles.filter((file) => GOOGLE_EDGE_EXTENSIONS.has(path.extname(file).toLowerCase()));
    if (edgeFiles.length > 0) {
      result.kind = "google-edge-folder";
      result.status = "usable-when-litert-or-mediapipe-runtime-linked";
      result.messages.push(`Found Google AI Edge compatible artifact(s): ${edgeFiles.map((file) => path.basename(file)).join(", ")}.`);
      result.warnings.push("Import the specific .task or .bin artifact into the app; folder execution requires runtime-specific packaging support.");
      return result;
    }

    result.kind = "folder";
    result.status = "not-ready";
    result.messages.push(`Folder is missing MLC markers: ${REQUIRED_MLC_MARKERS.join(", ")}.`);
    result.messages.push("Folder does not contain a visible .task or .bin artifact within two levels.");
    return result;
  }

  const ext = path.extname(absolutePath).toLowerCase();
  if (GOOGLE_EDGE_EXTENSIONS.has(ext)) {
    result.kind = ext === ".task" ? "ai-edge-task" : "mediapipe-bin";
    result.status = "usable-when-litert-or-mediapipe-runtime-linked";
    result.messages.push(`${ext} artifact is the right shape for Google AI Edge / MediaPipe-style local testing.`);
    result.warnings.push("The current app build must link LiteRT-LM or MediaPipe GenAI before this can generate tokens inside BeMore.");
    return result;
  }

  if (ext === ".mlmodelc") {
    result.kind = "coreml-compiled-model";
    result.status = "usable-when-coreml-wrapper-exists";
    result.messages.push("Compiled Core ML artifact found.");
    result.warnings.push("BeMore currently does not expose a Core ML LLM wrapper, so this is not a live route yet.");
    return result;
  }

  if (DISCOURAGED_EXTENSIONS.has(ext)) {
    result.kind = "unsupported-mobile-artifact";
    result.status = "wrong-artifact-for-ios-runtime";
    result.messages.push(`${ext} is not the right artifact shape for the current BeMore iOS local model path.`);
    result.warnings.push("Use a Google AI Edge .task, MediaPipe .bin, or prepared MLC package instead.");
    return result;
  }

  result.kind = "unknown-file";
  result.status = "not-ready";
  result.messages.push(`Unknown model artifact extension: ${ext || "none"}.`);
  result.warnings.push("Expected .task, .bin, .mlmodelc, or a prepared MLC package folder.");
  return result;
}

function discoverCandidates(pathsFromArgs) {
  if (pathsFromArgs.length > 0) return pathsFromArgs;

  const candidates = [];
  for (const root of DEFAULT_MODEL_ROOTS) {
    if (!exists(root)) continue;
    candidates.push(root);
    const rootStat = stat(root);
    if (rootStat?.isDirectory()) {
      for (const entry of fs.readdirSync(root)) {
        candidates.push(path.join(root, entry));
      }
    }
  }
  return candidates;
}

function summarize(results) {
  const ready = results.filter((result) => result.status.startsWith("usable"));
  const wrong = results.filter((result) => result.status === "wrong-artifact-for-ios-runtime");
  return {
    checked: results.length,
    readyCount: ready.length,
    wrongArtifactCount: wrong.length,
    hasReadyArtifact: ready.length > 0,
  };
}

function printHuman(results, summary) {
  if (results.length === 0) {
    console.log("No local model artifact paths found.");
    console.log("Pass --path to check a downloaded .task/.bin file or a prepared runtime package folder.");
    return;
  }

  for (const result of results) {
    console.log(`\n${result.path}`);
    console.log(`  kind: ${result.kind}`);
    console.log(`  status: ${result.status}`);
    for (const message of result.messages) console.log(`  - ${message}`);
    for (const warning of result.warnings) console.log(`  warning: ${warning}`);
  }

  console.log(`\nChecked ${summary.checked} artifact(s). Ready-shaped artifact(s): ${summary.readyCount}.`);
}

function main() {
  const args = parseArgs(process.argv.slice(2));
  if (args.help) {
    printHelp();
    return;
  }

  const candidates = discoverCandidates(args.paths);
  const results = candidates.map(classifyArtifact);
  const summary = summarize(results);

  if (args.json) {
    console.log(JSON.stringify({ summary, results }, null, 2));
  } else {
    printHuman(results, summary);
  }

  if (args.strict && !summary.hasReadyArtifact) {
    process.exit(1);
  }
}

try {
  main();
} catch (error) {
  console.error(error.message);
  process.exit(2);
}
