# GameMaker CLI Tooling Adapter

Status: **contract-only**

`gm-cli` is tracked as a possible local developer tool for GameMaker project validation, packaging, and resource-editing research. This document is a safety contract, not an implementation.

## Prismcade use cases

- Validate creator-owned GameMaker projects before import research.
- Package HTML5 exports into a receipt-tracked artifact folder.
- Inspect project metadata for title, version, target, and declared permissions.
- Research resource editing for AI-assisted project changes without relying on the GameMaker IDE.

## Repository-local toolchain rule

If this adapter becomes executable, downloaded tools and runtimes must stay out of git. Use a repo-local ignored path such as:

```txt
.prismtek-tools/gamemaker/
```

Every automated download must leave a receipt with:

- source URL,
- tool version,
- checksum when available,
- install path,
- timestamp,
- license/terms review status,
- rollback/delete command.

## Blocked outputs

- GameMaker account tokens or credentials.
- GameMaker IDE/runtime binaries committed to the repo.
- Generated HTML5 exports without manifest metadata.
- Unreviewed sample projects or marketplace assets.
- Any Prismcade ranked score path that trusts a GameMaker client without proof validation.

## First safe implementation wedge

Create a dry-run script only:

```txt
tools/integrations/gamemaker-cli/validate.mjs
```

The dry-run should read a local manifest, verify expected paths, and print what it *would* run. It should not download or execute `gm-cli` until the license/runtime terms are reviewed.

## Promotion gate

This adapter can graduate from contract-only only after:

1. local install receipts are designed,
2. a sample original project is tested,
3. generated artifacts are ignored or quarantined by default,
4. Prismcade wrapping works without arbitrary code trust,
5. `npm run integrations:validate` still passes.
