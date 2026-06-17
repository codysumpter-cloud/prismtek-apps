# BeMore Mac build 6 release check

This marker keeps the macOS native TestFlight workflow in scope for the build 6 release pass.

Build source of truth:

- `apps/bemore-macos-native/project.yml`
- `MARKETING_VERSION: 1.0`
- `CURRENT_PROJECT_VERSION: 6`

Validation target:

- BeMore Mac TestFlight workflow archives and uploads build 6 when this branch lands on `main` and the required App Store Connect and signing secrets are present.
