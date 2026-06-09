# Nintendo 3DS Lab external checkouts

This folder is a local workspace for 3DS-related upstream projects discovered from the 3Beans video/repo chain.

The upstream source is **not vendored** into `prismtek-apps` by default. Keep the upstream repositories as local-only checkouts when you need to inspect or build them.

## Included upstreams

| Project | Local path | Role |
| --- | --- | --- |
| 3Beans | `external/nintendo-3ds/3Beans` | Low-level Nintendo 3DS emulator for desktop experiments and future 3DS Lab UX research. |
| GodMode9 | `external/nintendo-3ds/GodMode9` | 3DS file browser/dumping tool reference for user-owned consoles. |
| Luma3DS | `external/nintendo-3ds/Luma3DS` | 3DS custom firmware reference for homebrew/dev workflows. |

## Local checkout commands

From the repo root:

```bash
mkdir -p external/nintendo-3ds

git clone --branch main --single-branch https://github.com/Hydr8gon/3Beans.git external/nintendo-3ds/3Beans
git clone --branch master --single-branch https://github.com/d0k3/GodMode9.git external/nintendo-3ds/GodMode9
git clone --branch master --single-branch https://github.com/LumaTeam/Luma3DS.git external/nintendo-3ds/Luma3DS
```

To update an existing checkout:

```bash
git -C external/nintendo-3ds/3Beans pull --ff-only
git -C external/nintendo-3ds/GodMode9 pull --ff-only
git -C external/nintendo-3ds/Luma3DS pull --ff-only
```

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
