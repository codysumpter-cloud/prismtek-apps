# Prismcade Creator Picker Surface

The Prismcade creator page now has a visible asset picker backed by the row registries in `data/prismcade/asset-rows/`.

Run from the repo root:

```bash
python -m http.server 4173
```

Open:

```txt
http://localhost:4173/apps/prismcade-creator/
```

The picker loads characters, VFX, worlds, items, UI, and audio rows. It supports family tabs, search, view/status/role filters, selected asset chips, and manifest export with selected asset row IDs.

Candidate and cleanup rows remain visible as production backlog. Only promoted rows are selectable for export.
