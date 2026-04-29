# BeMoreAgent Build 47 TestFlight marker

Lead branch: `main`

Build 47 is the current TestFlight target for the BeMoreAgent native iOS app.

Required source metadata:

- `CFBundleShortVersionString`: `0.2`
- `CFBundleVersion`: `47`

The `BeMore iOS CI & TestFlight` workflow should run on `main` pushes that touch `apps/bemore-ios-native/**` and should archive/export/upload this build after the unsigned validation job succeeds.
