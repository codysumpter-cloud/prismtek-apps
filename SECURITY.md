# Security Policy

## Supported surface

Security fixes should target the current default branch and any actively shipped app surfaces.

## Reporting a vulnerability

Please do **not** open a public issue for sensitive problems such as:

- credential leaks
- auth bypasses
- unsafe command execution paths
- private-data exposure
- sandbox or pairing bypasses

Instead, gather the minimum reproducible details and report the issue privately to the maintainer.

## Secrets and private data

Never commit:

- live API keys or tokens
- provisioning secrets
- private relay endpoints with credentials
- screenshots or logs containing private user data

## Safe defaults

- use placeholders in docs and examples
- redact logs before sharing
- prefer least-privilege tokens for automation
- rotate any secret immediately if it may have been exposed
