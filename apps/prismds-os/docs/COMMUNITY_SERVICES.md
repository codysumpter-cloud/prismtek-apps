# Community services

PrismDS can track optional community services as metadata profiles. These profiles are intentionally passive: they document links, compatibility notes, and support status, but they do not auto-install software, change accounts, or rewrite networking.

## Current profiles

| Service | Status | PrismDS role |
| --- | --- | --- |
| Pretendo Network | Verified public project | Link, document, track compatibility |
| Brewtendo | Unverified placeholder | Reserve profile slot until official source is supplied |
| Roseverse | Unverified placeholder | Reserve profile slot until official source is supplied |

## Pretendo

Pretendo Network is tracked as a verified public project. PrismDS should only point users to official Pretendo setup information and should not try to perform account, patch, or network changes automatically.

Profile:

```text
profiles/services/pretendo.json
```

## Brewtendo

Brewtendo is tracked as a placeholder because no reliable official source was verified in this pass. The profile exists so PrismDS has a place to store future links and compatibility notes once the source is confirmed.

Profile:

```text
profiles/services/brewtendo.json
```

## Roseverse

Roseverse is tracked as a placeholder because no reliable official source was verified in this pass. The profile includes `rverse` as an alias candidate, but does not assume they are the same project.

Profile:

```text
profiles/services/roseverse.json
```

## Rules

- Do not bundle service clients unless their license and distribution model are verified.
- Do not auto-change accounts, certificates, DNS, or network settings.
- Prefer official docs over mirrored instructions.
- Treat every profile as metadata until tested on a real RGDS.
