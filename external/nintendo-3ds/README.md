# Nintendo 3DS Lab external checkouts

This folder is a local workspace for 3DS-related upstream projects discovered from the 3Beans video/repo chain.

The upstream source is **not vendored** into `prismtek-apps` by default. Use `scripts/bootstrap-3ds-lab.sh` to clone or update the repositories locally when you need them.

## Included upstreams

| Project | Local path | Role |
| --- | --- | --- |
| 3Beans | `external/nintendo-3ds/3Beans` | Low-level Nintendo 3DS emulator for desktop experiments and future 3DS Lab UX research. |
| GodMode9 | `external/nintendo-3ds/GodMode9` | 3DS file browser/dumping tool reference for user-owned consoles. |
| Luma3DS | `external/nintendo-3ds/Luma3DS` | 3DS custom firmware reference for homebrew/dev workflows. |

## Bootstrap

From the repo root:

```bash
./scripts/bootstrap-3ds-lab.sh
```

The script reads `external/nintendo-3ds/manifest.json` and clones/updates each upstream checkout.

## Safety and license boundary

- Do **not** commit console dumps, boot ROMs, NAND images, SD images, encrypted/decrypted cartridge dumps, CIAs, title keys, save files, or other private/copyrighted data.
- Use only data dumped from hardware and software you own.
- Keep upstream GPL-family source isolated as external checkouts unless a future licensing review explicitly approves deeper integration.
- `prismtek-apps` may build product UX around setup guidance, path validation, profile management, logs, and receipts; it should not ship Nintendo assets, keys, dumps, or game content.

## Intended Prismtek use

The product-shaped path is a **3DS Lab** helper inside BeMore/Buddy:

1. validate a user's local 3Beans install/checkouts;
2. guide legal personal dumping/checklist steps without distributing copyrighted files;
3. manage local emulator profiles and paths;
4. collect compatibility notes and debug receipts;
5. keep Buddy's guidance review-first and non-destructive.
