# Reference Assets Only

This directory is reserved for temporary local development/testing output from GIF extraction tools.

Reference assets only. Not for release.

Rules:

- Do not ship files in this directory.
- Do not distribute files in this directory.
- Do not include files in public builds.
- Do not include files in release builds.
- Do not commit extracted PNG frames or third-party GIFs here.
- Use `USE_REFERENCE_TEST_ASSETS=true` only for local development checks.
- Release builds force `USE_REFERENCE_TEST_ASSETS=false`.

All final shipped Pixel Fruit Arena art must be original Prismtek-created artwork.
