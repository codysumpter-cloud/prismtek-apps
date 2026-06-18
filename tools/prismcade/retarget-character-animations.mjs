#!/usr/bin/env node
import { existsSync, mkdirSync, readdirSync, readFileSync, statSync, writeFileSync } from "node:fs";
import path from "node:path";

const root = process.cwd();
const args = process.argv.slice(2);

function argValue(name, fallback = null) {
  const index = args.indexOf(name);
  if (index === -1 || index + 1 >= args.length) return fallback;
  return args[index + 1];
}

function usage() {
  console.log("Usage: node tools/prismcade/retarget-character-animations.mjs --job <job.json> [--out <dir>]");
}

const jobPathArg = argValue("--job");
if (!jobPathArg) {
  usage();
  process.exit(1);
}

const jobPath = path.resolve(root, jobPathArg);
if (!existsSync(jobPath)) {
  console.error(`Retarget job not found: ${jobPathArg}`);
  process.exit(1);
}

const job = JSON.parse(readFileSync(jobPath, "utf8"));
const outputRoot = path.resolve(root, argValue("--out", job.outputRoot || `generated/prismcade/retarget-jobs/${job.jobId}`));
mkdirSync(outputRoot, { recursive: true });

const imageExtensions = new Set([".png", ".gif", ".webp", ".ase", ".aseprite"]);
const slotSynonyms = new Map([
  ["idle", ["idle", "stand", "stance"]],
  ["walk", ["walk"]],
  ["run", ["run", "dash"]],
  ["jump", ["jump", "snappy"]],
  ["fall", ["fall"]],
  ["land", ["land"]],
  ["climb", ["climb"]],
  ["crouch_idle", ["crouch-idle", "crouch_idle", "crouch idle"]],
  ["crouch_walk", ["crouch-walk", "crouch_walk", "crouch walk"]],
  ["wall_slide", ["wall slide", "wall-slide", "wall_slide"]],
  ["wall_land", ["wall land", "wall-land", "wall_land"]],
  ["ledge_climb", ["ledge climb", "ledge-climb", "ledge_climb"]],
  ["roll", ["roll"]],
  ["push", ["push"]],
  ["pull", ["pull"]],
  ["hurt", ["hurt", "damage", "hit"]],
  ["defeat", ["death", "defeat", "dead", "ko"]],
  ["punch", ["punch"]],
  ["basic", ["basic", "attack", "combo", "atk"]],
  ["skill", ["skill", "special"]],
  ["big_skill", ["big skill", "big_skill", "super"]],
  ["sword_idle", ["sword idle", "sword-idle", "sword_idle"]],
  ["sword_run", ["sword run", "sword-run", "sword_run"]],
  ["sword_stab", ["sword stab", "sword-stab", "sword_stab", "stab"]],
  ["victory", ["victory", "win"]],
  ["interact", ["interact", "use", "item"]]
]);

function walk(dir) {
  const out = [];
  if (!existsSync(dir)) return out;
  for (const entry of readdirSync(dir)) {
    const full = path.join(dir, entry);
    const stat = statSync(full);
    if (stat.isDirectory()) out.push(...walk(full));
    else if (imageExtensions.has(path.extname(entry).toLowerCase())) out.push(full);
  }
  return out;
}

function normalize(value) {
  return value.toLowerCase().replace(/[_]+/g, " ").replace(/[-]+/g, " ").replace(/\s+/g, " ").trim();
}

function inferSlots(filePath) {
  const normalized = normalize(filePath);
  const matches = [];
  for (const [slot, needles] of slotSynonyms.entries()) {
    if (needles.some((needle) => normalized.includes(normalize(needle)))) {
      matches.push(slot);
    }
  }
  return matches;
}

const sourceReports = [];
const slotCandidates = Object.fromEntries((job.canonicalSlots || []).map((slot) => [slot, []]));

for (const pack of job.sourcePacks || []) {
  const packRoot = path.resolve(root, pack.root);
  const exists = existsSync(packRoot);
  const files = exists ? walk(packRoot) : [];
  const report = {
    id: pack.id,
    role: pack.role,
    root: pack.root,
    exists,
    fileCount: files.length,
    candidateSlots: pack.candidateSlots || []
  };
  sourceReports.push(report);

  for (const file of files) {
    const rel = path.relative(root, file).split(path.sep).join("/");
    const inferred = inferSlots(rel);
    const allowed = new Set([...(pack.candidateSlots || []), ...inferred]);
    for (const slot of allowed) {
      if (!slotCandidates[slot]) continue;
      slotCandidates[slot].push({ sourcePackId: pack.id, file: rel, inferred: inferred.includes(slot) });
    }
  }
}

const missingSlots = Object.entries(slotCandidates)
  .filter(([, candidates]) => candidates.length === 0)
  .map(([slot]) => slot);

const plan = {
  schemaVersion: "prismcade-retarget-plan-v0",
  generatedAt: new Date().toISOString(),
  jobId: job.jobId,
  targetCharacter: job.targetCharacter,
  rigTemplateId: job.rigTemplateId,
  defaultFrameSize: job.defaultFrameSize,
  allowedOutputSizes: job.allowedOutputSizes,
  sourceReports,
  slotCandidates,
  missingSlots,
  reviewRequired: job.reviewRequired !== false,
  promotionPolicy: job.promotionPolicy || "draft_until_visual_review"
};

writeFileSync(path.join(outputRoot, "retarget-plan.json"), JSON.stringify(plan, null, 2));

const csvRows = ["slot,sourcePackId,file,inferred"];
for (const [slot, candidates] of Object.entries(slotCandidates)) {
  if (candidates.length === 0) {
    csvRows.push(`${slot},,,false`);
    continue;
  }
  for (const candidate of candidates) {
    csvRows.push(`${slot},${candidate.sourcePackId},${candidate.file},${candidate.inferred}`);
  }
}
writeFileSync(path.join(outputRoot, "slot-map.csv"), csvRows.join("\n") + "\n");

const promptLines = [];
promptLines.push(`# Pixel Forge Retarget Prompt Plan: ${job.jobId}`);
promptLines.push("");
promptLines.push(`Target character: ${job.targetCharacter?.displayName || job.targetCharacter?.id}`);
promptLines.push(`Rig template: ${job.rigTemplateId}`);
promptLines.push("");
promptLines.push("Use source files only as pose, timing, and frame-count references. Redraw or generate the target character into the pose. Preserve hair, face, clothing, shoes, palette, proportions, and readable silhouette.");
promptLines.push("");
for (const slot of job.canonicalSlots || []) {
  promptLines.push(`## ${slot}`);
  const candidates = slotCandidates[slot] || [];
  if (candidates.length === 0) {
    promptLines.push("- Missing source candidate. Create a new Prismcade template animation or mark for manual art.");
  } else {
    for (const candidate of candidates.slice(0, 6)) {
      promptLines.push(`- Reference: ${candidate.file}`);
    }
  }
  promptLines.push("- Output: transparent frames at approved Prismcade size, same pivot/floor line, no antialiasing, no background.");
  promptLines.push("");
}
writeFileSync(path.join(outputRoot, "pixel-forge-prompts.md"), promptLines.join("\n"));

const qa = [
  `# Retarget QA Checklist: ${job.jobId}`,
  "",
  "- [ ] Target character identity is preserved.",
  "- [ ] Hair shape and face remain consistent.",
  "- [ ] Clothing and shoes remain consistent.",
  "- [ ] Transparent background only.",
  "- [ ] No warped/squashed final-sprite placeholder frames promoted.",
  "- [ ] Feet and floor line are stable where required.",
  "- [ ] Frame size matches the selected rig template.",
  "- [ ] Loops read cleanly at game speed.",
  "- [ ] Hit/hurt timing can be mapped for combat slots.",
  "- [ ] Source rights/provenance have been recorded before platform promotion.",
  ""
];
writeFileSync(path.join(outputRoot, "qa-checklist.md"), qa.join("\n"));

writeFileSync(path.join(outputRoot, "missing-slots.json"), JSON.stringify({ missingSlots }, null, 2));

console.log(`Wrote retarget plan: ${path.relative(root, outputRoot)}`);
console.log(`Source packs: ${sourceReports.length}`);
console.log(`Missing slots: ${missingSlots.length}`);
