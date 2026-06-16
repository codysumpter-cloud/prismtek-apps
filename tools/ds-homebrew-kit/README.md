# DS homebrew kit

Utilities and notes for building Nintendo DS homebrew experiments inside Prismtek Apps.

## Local research references

Use the import helper to clone external DS homebrew projects into a git-ignored local folder:

```bash
node tools/ds-homebrew-kit/import-third-party-ds-reference.mjs trex-runner-ds
node tools/ds-homebrew-kit/import-third-party-ds-reference.mjs terrariads
node tools/ds-homebrew-kit/import-third-party-ds-reference.mjs minicraft-ds-edition
```

The files land under:

```txt
.external/ds-homebrew-references/
```

That folder is intentionally ignored by git. Use those projects for local study and rebuild the patterns with original Prismtek code/assets unless the source license is explicitly compatible with the intended Prismtek use.

## Prismtek-owned implementation targets

The next good templates to create are:

```txt
tools/ds-homebrew-kit/templates/runner/
tools/ds-homebrew-kit/templates/tile-world/
tools/ds-homebrew-kit/templates/dual-screen-survival/
```

These should become clean, original DS homebrew starters for Prismtek games.
