# Prismtek integration contracts

This folder defines the safe path for connecting external game engines, reference projects, and open asset sources to Prismtek-owned games.

The key rule is simple: **integrate by contract first, never by blind copy.** External engines and asset sources can inform tooling, adapters, experiments, and local research, but shipped games must only consume reviewed, documented, Prismtek-owned or license-cleared outputs.

## Files

| File | Purpose |
| --- | --- |
| [`game-engine-adapters.md`](game-engine-adapters.md) | Human-readable registry for game-engine adapter contracts. |
| [`asset-source-adapters.md`](asset-source-adapters.md) | Human-readable registry for asset-source intake contracts. |
| [`engine-plugin-contract.md`](engine-plugin-contract.md) | Required behavior for engine integration plugins. |
| [`asset-intake-plugin-contract.md`](asset-intake-plugin-contract.md) | Required behavior for asset intake and promotion plugins. |
| [`../../data/integrations/game-engine-adapters.json`](../../data/integrations/game-engine-adapters.json) | Machine-readable engine adapter manifest. |
| [`../../data/integrations/asset-source-adapters.json`](../../data/integrations/asset-source-adapters.json) | Machine-readable asset adapter manifest. |
| [`../../tools/integrations/validate-integration-manifests.mjs`](../../tools/integrations/validate-integration-manifests.mjs) | Manifest validator used by `npm run integrations:validate`. |

## Why this exists

Prismtek Apps now has a growing set of games, experiments, porting targets, uploaded asset packs, and open-source references. Without a contract layer, it is too easy to accidentally do the wrong thing:

- copy an engine instead of adapting to it;
- mix incompatible art styles;
- ship assets without provenance;
- claim platform support before a build exists;
- make games depend on raw intake folders;
- bury useful reference work in one-off docs that CI cannot validate.

This integration layer keeps those paths explicit.

## What counts as an integration

An integration can be:

- a game engine adapter;
- a renderer adapter;
- an asset source intake adapter;
- an asset promotion plugin;
- a platform packaging bridge;
- a validation/reporting tool;
- a generated-output receipt format.

An integration is **not** automatically:

- permission to ship upstream code;
- permission to ship third-party art/audio/fonts;
- a platform-support claim;
- a replacement for a game-specific architecture review.

## Validation

Run:

```bash
npm run integrations:validate
npm run references:validate
```

`integrations:validate` checks that adapter manifests are structurally usable. `references:validate` keeps the broader open-source reference registry healthy.

## Adapter workflow

1. **Register** the external engine or source in the reference registry.
2. **Declare** an adapter contract under `data/integrations/`.
3. **Document** the intended workflow in `docs/integrations/`.
4. **Implement** a tiny dry-run plugin.
5. **Emit** receipts for generated or promoted output.
6. **Promote** only reviewed files into game-local paths.
7. **Validate** the game and platform claims.

## Promotion rule

An adapter contract does **not** mean an engine, binary, module, asset pack, or generated artifact is approved to ship. Promotion into a game path requires:

1. Source/provenance receipt.
2. License review for the exact file or package.
3. Style and product-fit review.
4. Generated-output receipt when tooling transforms files.
5. Game-local manifest update showing what was promoted and why.

## Honest status language

Use conservative language in docs and manifests.

| Status | Meaning |
| --- | --- |
| `contract-only` | Manifest/docs exist only. No runtime adapter is implemented. |
| `prototype` | A dry-run or local-only plugin exists. |
| `verified-local` | A repeatable local validation exists. |
| `release-candidate` | A packageable artifact exists, but may still need review. |
| `shippable` | The specific output passed license, platform, and product checks. |

## Safety boundaries

The integration system must not commit:

- secrets;
- credentials;
- raw prompts;
- private absolute paths;
- unreviewed archives as runtime dependencies;
- copied sample games;
- unknown-origin fonts;
- engine binaries without receipts;
- platform-support claims without platform receipts.

## Best next implementation

The next PR should implement the smallest useful plugin:

- load one manifest;
- validate one adapter by id;
- print a summary;
- emit a receipt;
- write no runtime files.

That proves the contract while keeping the repo honest and safe.
