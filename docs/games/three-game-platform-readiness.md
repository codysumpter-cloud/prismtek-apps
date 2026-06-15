# Three Game Platform Readiness

Status values: **Verified**, **Partially verified**, **Unverified**, **Missing**.

| Game | Web browser | Web ZIP | Windows | macOS | Linux / Steam Deck | RGDS Android | RGDS Linux | Nintendo DS source |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Pixel Fruit Arena | Verified | Partially verified | Partially verified | Unverified | Unverified | Unverified | Unverified | Partially verified |
| TamerNet Battle Sandbox | Verified | Partially verified | Partially verified | Unverified | Unverified | Unverified | Unverified | Partially verified |
| Spin Street Showdown | Verified | Partially verified | Partially verified | Unverified | Unverified | Unverified | Unverified | Partially verified |

## Repo receipts

- Pixel Fruit Arena keeps its existing runtime tests, build script, and ZIP packaging path.
- TamerNet now has package scripts, a browser smoke test, and ZIP packaging path.
- Spin Street now has ZIP packaging path beside the existing browser smoke test.
- All three games now have DS source folders with a README, Makefile, and `source/main.c`.
- CI validates the DS source receipt for all three games.

## Remaining receipts before full release

- Build DS outputs on a machine with devkitPro/libnds installed.
- Publish web ZIP artifacts through GitHub Releases or itch.io.
- Test each downloadable game on Windows, macOS, Linux, Steam Deck, RGDS Android mode, and RGDS Linux mode.
