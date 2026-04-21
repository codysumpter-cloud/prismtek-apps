# BeMore Builds

## macOS Build 1

BeMore Mac has two product-owned pieces:

- `apps/bemore-macos` is the local workspace/runtime server used by Mac and paired iPhone flows.
- `apps/bemore-macos-native` is the native macOS TestFlight shell. Its XcodeGen project target is `BeMoreMac`, the generated project is `BeMoreMac.xcodeproj`, and the App Store bundle identifier is `BeMoreAgent`, sharing the existing BeMore App Store Connect record so the macOS TestFlight build lands under the same product family.

The local runtime slice provides:
- workspace selection and file tree browsing
- text file open/edit/save
- command/process runner with output and stop receipts
- task creation and task command launch
- git diff/review state
- artifact and receipt panels
- Buddy state
- iPhone pairing boundary through the runtime snapshot API

The runtime server defaults to loopback:

```sh
npm --workspace apps/bemore-macos run dev
```

Use `BEMORE_MAC_RUNTIME_HOST=0.0.0.0` only when intentionally exposing the runtime for a paired iPhone or trusted tunnel.

The native macOS shell is generated and archived with:

```sh
cd apps/bemore-macos-native
xcodegen generate
xcodebuild -project BeMoreMac.xcodeproj -scheme BeMoreMac -destination 'platform=macOS' build
xcodebuild -project BeMoreMac.xcodeproj -scheme BeMoreMac -configuration Release -destination 'generic/platform=macOS' -archivePath .build/BeMoreMac.xcarchive -allowProvisioningUpdates DEVELOPMENT_TEAM=DY9FHPRZA9 CODE_SIGN_STYLE=Automatic clean archive
```

TestFlight upload is owned by `.github/workflows/bemore-macos-testflight.yml` and requires App Store Connect API secrets in this repo: `APPSTORE_CONNECT_API_KEY`, `APPSTORE_CONNECT_KEY_ID`, and `APPSTORE_CONNECT_ISSUER_ID`. Xcode 26 requires the issuer ID whenever `-authenticationKeyPath` is used.

## iOS Build 40

The working BeMoreAgent iOS source and release validation path now live in `prismtek-apps` under `apps/bemore-ios-native`.

The current repo-owned iOS release lane is:
- `.github/workflows/bemoreagent-platform-ios-validate.yml`
- `.github/workflows/bemore-ios-ci-testflight.yml`

The current source build number is `40` in `apps/bemore-ios-native/BeMoreAgentShell/Info.plist`.

That means `prismtek-apps` is now the canonical product repo for the native iPhone app source, validation flow, and TestFlight upload path. `bmo-stack` still matters for policy, runtime contracts, and deeper operator logic, but it is no longer the place to describe the working iOS project as if it lives only there.

Current practical rule:
- update the native iPhone app source, XcodeGen inputs, Info.plist, and iOS release docs here
- keep execution/policy/runtime-identity details in `bmo-stack`
- only claim a TestFlight submission after the current runner, signing assets, and App Store Connect path have actually validated that upload
