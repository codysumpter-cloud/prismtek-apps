# Engine plugin contract

Engine plugins are repo-local tools that connect a Prismtek game or experiment to an external engine reference. They must be deterministic, receipt-producing, and safe by default.

## Core rule

An engine plugin may help Prismtek generate, validate, or compare project files. It must not silently import external engine code, sample projects, binaries, assets, or platform packages into shipped game paths.

The adapter contract is the boundary between research and product code.

## Required commands

Each implemented engine plugin should expose these conceptual commands, even if the first version only validates configuration:

| Command | Purpose | Safe first implementation |
| --- | --- | --- |
| `intake` | Read adapter config and prepare a local experiment workspace. | Validate paths and write a receipt, but do not download anything by default. |
| `validate` | Confirm required files, licenses, paths, and output guards. | Validate manifest structure and forbidden output paths. |
| `export` | Generate or package Prismtek-owned output for a target platform. | Refuse until a game-local target manifest exists. |

## Required inputs

- Adapter id from `data/integrations/game-engine-adapters.json`.
- Target game or experiment path.
- Target platform.
- Source engine version, commit, tag, package version, or local install path.
- Output directory.
- Receipt destination.
- Optional dry-run flag.

## Required outputs

Every plugin run should produce:

- a machine-readable receipt;
- a human-readable summary;
- deterministic exit code;
- clear list of generated, skipped, and blocked paths;
- explicit validation status.

Plugins must not output:

- secrets;
- raw prompts;
- tokens;
- private absolute machine paths;
- local username/home directory paths;
- unreviewed external code/assets in shipped game paths.

## Path safety

Plugins must normalize and validate paths before writing. They should reject:

- paths outside the repository root;
- `..` traversal outputs;
- absolute private system paths in committed files;
- generated output into `games/**` unless the target game has a manifest;
- generated output into release folders without artifact receipts;
- writes into `.external/**` unless the command is explicitly an intake/research command.

## Required receipt schema

```json
{
  "schemaVersion": 1,
  "adapterId": "phaser-web-adapter",
  "adapterKind": "web-game-framework-adapter",
  "command": "validate",
  "dryRun": true,
  "sourceReferenceId": "phaser",
  "sourceVersion": "unknown | commit | tag | package version",
  "targetPath": "games/example/",
  "targetPlatform": "web",
  "startedAt": "YYYY-MM-DDTHH:mm:ssZ",
  "completedAt": "YYYY-MM-DDTHH:mm:ssZ",
  "generatedPaths": [],
  "skippedPaths": [],
  "blockedPaths": [],
  "licenseReview": "pending | reviewed | blocked",
  "artifactReview": "pending | reviewed | blocked",
  "platformReview": "pending | reviewed | blocked",
  "validationResult": "passed | failed",
  "warnings": [],
  "errors": []
}
```

## Manifest checks

A plugin must verify that its adapter manifest includes:

- id;
- name;
- source reference id;
- URL;
- kind;
- status;
- target path;
- supported targets;
- license note;
- plugin entry points;
- validation rules;
- forbidden outputs;
- notes.

The shared validator handles the baseline. Plugin-specific validators should add deeper checks only for the adapter they own.

## Download policy

The first version of an engine plugin should prefer **no downloads**. Downloading toolchains or engines inside CI should be a later, explicit decision.

When downloads are eventually allowed, the plugin must record:

- URL;
- resolved version;
- checksum when available;
- destination path;
- license note;
- cache policy;
- whether the downloaded files are allowed to be committed.

Most downloaded engines/toolchains should be cached or installed locally, not committed to the repo.

## Export policy

Exports are the riskiest step. An export plugin must refuse to run unless the target game or experiment declares:

- intended platform;
- output path;
- generated-file manifest path;
- license/provenance state;
- cleanup behavior;
- validation command.

Export output must include a receipt that can explain exactly what changed.

## Platform support language

Plugins must use conservative platform wording:

| Word | Meaning |
| --- | --- |
| `missing` | No adapter path or build recipe exists. |
| `unverified` | Contract exists but no successful local run is recorded. |
| `partially verified` | Some local validation passed, but packaging/release is incomplete. |
| `verified local` | Reproducible local result exists. |
| `release candidate` | Packageable artifact exists and has receipts. |
| `shippable` | Release artifact passed license, asset, and platform checks. |

Do not claim Windows, macOS, Linux, Android, iOS, RGDS, itch.io, or DS support until a platform receipt exists.

## Security/privacy rules

Plugins must never commit or print:

- API keys;
- OAuth tokens;
- GitHub tokens;
- private file paths;
- credentials;
- raw browser/session data;
- private user prompts;
- downloaded archives with unknown contents.

If a plugin needs configuration, prefer checked-in sample config plus ignored local config.

## Test expectations

Each implemented plugin should eventually have:

- manifest unit checks;
- dry-run test;
- invalid adapter id test;
- forbidden path test;
- missing receipt test;
- fixture-based output snapshot;
- CI-safe mode with no network requirement.

## Minimal first plugin shape

A first adapter implementation can be tiny:

```bash
node tools/integrations/phaser/validate.mjs --dry-run
```

It should:

1. Load the shared manifest.
2. Find the adapter by id.
3. Verify required fields.
4. Print a clear summary.
5. Emit no runtime files.

That is enough to prove the contract without pretending the whole engine integration is finished.

## Graduation checklist

Before marking any adapter beyond `contract-only`, verify:

- command exists;
- command is documented;
- receipt is emitted;
- dry-run is deterministic;
- forbidden output guard works;
- game-local manifest exists if writing to a game;
- CI can run without secrets;
- platform wording stays honest.
