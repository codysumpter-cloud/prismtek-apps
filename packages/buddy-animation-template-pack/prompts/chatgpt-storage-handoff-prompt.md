# ChatGPT / Codex storage handoff prompt

Use this prompt when another session needs to store generated Buddy animation outputs in `prismtek-apps`.

```text
You are Buddy working in the Prismtek Apps repo.

Repo:
https://github.com/codysumpter-cloud/prismtek-apps

Target package:
packages/buddy-animation-template-pack/

Goal:
Store the generated Buddy animation output using the package contract. Do not invent a new folder. Do not summarize only. Actually place the files into the repo.

Before writing:
1. Inspect README.md and package.json at repo root.
2. Inspect packages/buddy-animation-template-pack/README.md.
3. Inspect packages/buddy-animation-template-pack/metadata.json.
4. Inspect packages/buddy-animation-template-pack/animation-contract/BUDDY_ANIMATION_CONTRACT.md.
5. Inspect packages/buddy-animation-template-pack/animation-contract/animation-schema.json.

Write targets:
- Put reference/master sheets in packages/buddy-animation-template-pack/reference/.
- Put generated variant sheets under packages/buddy-animation-template-pack/examples/ or a new packages/buddy-animation-template-pack/variants/<variant-id>/ folder.
- Every generated sheet needs a JSON manifest matching buddy-animation-manifest-v1.

Required validation:
- Confirm every JSON file parses.
- Confirm all sheet paths in JSON point to files that exist.
- Confirm frame dimensions are 64x64 or 128x128.
- Confirm animation state IDs use lowercase snake_case.
- Confirm no copied franchise or unlicensed sprites are committed.

Commit:
Use a focused branch, e.g.
chore/add-buddy-animation-output-<variant-id>

Commit message:
Add Buddy animation output for <variant-id>

PR body must include:
- Summary of files added.
- Source/provenance of generated art.
- Validation performed.
- Any missing binary/reference files.
```

## Current known limitation

Some ChatGPT iOS sessions only allow image uploads, not arbitrary ZIP files. In that case, upload the image sheets directly and store them under `reference/` or `variants/<variant-id>/` with a manifest.
