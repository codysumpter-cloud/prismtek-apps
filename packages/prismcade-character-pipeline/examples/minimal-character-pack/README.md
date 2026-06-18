# Minimal Prismcade character pack

This example is intentionally **contract-only** so the repo can validate schema and animation metadata without committing placeholder binary art.

To test with real assets, replace the `spritesheets/*.png` paths in `manifest.json` with reviewed 64x64 transparent PNG strips and run:

```bash
node ../../tools/validate-character-pack.mjs . --strict-assets
```
