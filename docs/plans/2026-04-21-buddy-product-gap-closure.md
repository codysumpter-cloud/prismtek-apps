# Buddy Product Gap Closure Plan

> **For Hermes:** Use subagent-driven-development skill to implement this plan task-by-task.

**Goal:** Close the product gaps Cody called out so BeMore ships a real companion-first Buddy experience: useful Studio, structured Buddy tab, onboarding appearance creation, linked accounts, real local-model posture, and tamagotchi-style Buddy growth.

**Architecture:** Keep the iPhone app native-first. Use browser surfaces only for explicit OAuth/account flows. Move Buddy appearance and customization into a shared native surface reused by Buddy and onboarding. Treat built-in capabilities as built-in, not faux skills. Preserve the current chat-to-skill teaching flow and expand it where it is already real.

**Tech Stack:** SwiftUI, local persisted app state in `BeMoreShell`, existing Buddy event/store/runtime services, XcodeGen project generation.

---

## Verified gap list from repo audit

1. **Studio parity gap**
   - Native sprite editing has now been restored locally, but export/playback/layers/selection are still missing.
2. **Buddy tab organization gap**
   - `Views/BuddyView.swift` is still a giant monolith (~1400 lines) with appearance, care, training, roster, trade, and marketplace all stacked together.
3. **Onboarding appearance gap**
   - `OnboardingFlow.swift` still lacks a Buddy appearance creation/customization step.
4. **GitHub private repo link gap**
   - `GitHubService.swift` only supports public REST reads. `SettingsView.swift` still says real OAuth is not wired.
5. **ChatGPT/OpenAI account link gap**
   - Still API-key oriented; native OAuth callback/exchange is not implemented.
6. **PixelLab / pixel buddy link gap**
   - `BuddyView.swift` still labels PixelLab as later enhancement only.
7. **Local model gap**
   - `RuntimeServices.swift` still falls back to stub copy when `MLCSwift` is unavailable.
8. **Teach-by-chat tooling**
   - Basic chat-to-skill drafting/approval is already real and should be preserved, then expanded into the product posture instead of hidden behind the Skills surface.
9. **Tamagotchi depth gap**
   - Care/trust/mood loops exist, but the product shell does not yet center them enough in onboarding/Buddy daily loop.

---

## Slice 1: Ship the native Studio baseline to GitHub

**Objective:** Get the restored native Studio changes committed and ready as the new baseline before layering more product work.

**Files:**
- Modify: `apps/bemore-ios-native/BeMoreAgentShell/Features/Editor/EditorView.swift`
- Modify: `apps/bemore-ios-native/BeMoreAgentShell/Features/Editor/PixelStudioModels.swift`
- Create: `apps/bemore-ios-native/BeMoreAgentShell/Features/Editor/PixelStudioNativeEditor.swift`
- Create: `apps/bemore-ios-native/BeMoreAgentShellTests/PixelStudioStoreTests.swift`
- Modify: `apps/bemore-ios-native/BeMoreAgent.xcodeproj/project.pbxproj`

**Verification:**
- `xcodegen generate`
- `xcodebuild build -project apps/bemore-ios-native/BeMoreAgent.xcodeproj -scheme BeMoreAgent -destination 'platform=iOS Simulator,name=iPhone 17'`

---

## Slice 2: Break Buddy into focused native sections

**Objective:** Split `BuddyView.swift` into smaller surfaces so Buddy stops feeling long and chaotic.

**Files:**
- Create: `apps/bemore-ios-native/BeMoreAgentShell/Features/Buddy/BuddyOverviewSection.swift`
- Create: `apps/bemore-ios-native/BeMoreAgentShell/Features/Buddy/BuddyAppearanceSection.swift`
- Create: `apps/bemore-ios-native/BeMoreAgentShell/Features/Buddy/BuddyCareSection.swift`
- Create: `apps/bemore-ios-native/BeMoreAgentShell/Features/Buddy/BuddyTrainingSection.swift`
- Create: `apps/bemore-ios-native/BeMoreAgentShell/Features/Buddy/BuddyRosterSection.swift`
- Create: `apps/bemore-ios-native/BeMoreAgentShell/Features/Buddy/BuddyTradeSection.swift`
- Modify: `apps/bemore-ios-native/BeMoreAgentShell/Views/BuddyView.swift`
- Modify: `apps/bemore-ios-native/project.yml`

**Acceptance criteria:**
- Buddy top area leads with: overview, care status, appearance, training.
- Lower-value/secondary surfaces move below the core daily loop or into secondary groups.
- Appearance editing is clearly part of Buddy Studio / appearance flow, not buried in a long feed.

**Verification:**
- Build passes.
- `BuddyView.swift` becomes significantly smaller.

---

## Slice 3: Add onboarding appearance creation

**Objective:** Let users customize Buddy appearance during onboarding.

**Files:**
- Modify: `apps/bemore-ios-native/BeMoreAgentShell/OnboardingFlow.swift`
- Modify: `apps/bemore-ios-native/BeMoreAgentShell/AppModels.swift`
- Create: `apps/bemore-ios-native/BeMoreAgentShell/Features/Buddy/BuddyAppearanceEditorView.swift`
- Modify: `apps/bemore-ios-native/BeMoreAgentShell/BuddyInstanceStore.swift`
- Modify: `apps/bemore-ios-native/BeMoreAgentShell/BuddyEventEngine.swift`
- Modify: `apps/bemore-ios-native/project.yml`

**Acceptance criteria:**
- Onboarding adds a step after name/focus selection for appearance.
- User can choose ASCII look immediately.
- If Pixel mode is chosen, that selection is saved as part of onboarding state even if PixelLab linking is still pending.
- Onboarding-created appearance becomes the active Buddy look on first launch.

**Verification:**
- Reset onboarding from Settings and walk through the new appearance step.
- Build passes.

---

## Slice 4: Shared Buddy appearance editor

**Objective:** Reuse one native appearance editor in both Buddy and onboarding.

**Files:**
- Create: `apps/bemore-ios-native/BeMoreAgentShell/Features/Buddy/BuddyAppearanceEditorView.swift`
- Modify: `apps/bemore-ios-native/BeMoreAgentShell/Views/BuddyView.swift`
- Modify: `apps/bemore-ios-native/BeMoreAgentShell/Views/BuddyVisualView.swift`
- Modify: `apps/bemore-ios-native/BeMoreAgentShell/Views/BuddyPixelView.swift`
- Modify: `apps/bemore-ios-native/BeMoreAgentShell/BuddyContracts.swift`

**Acceptance criteria:**
- One editor handles ASCII and pixel look setup.
- Buddy tab and onboarding both call the same surface.
- Pixel mode no longer reads like “later enhancement only.”

---

## Slice 5: Native linked-account shell for GitHub / ChatGPT / PixelLab

**Objective:** Put real native linked-account state and browser OAuth launch points into the app instead of placeholder copy.

**Files:**
- Create: `apps/bemore-ios-native/BeMoreAgentShell/Services/LinkedAccountStore.swift`
- Create: `apps/bemore-ios-native/BeMoreAgentShell/Services/OAuthLinkService.swift`
- Modify: `apps/bemore-ios-native/BeMoreAgentShell/Views/SettingsView.swift`
- Modify: `apps/bemore-ios-native/BeMoreAgentShell/GitHubService.swift`
- Modify: `apps/bemore-ios-native/BeMoreAgentShell/AppModels.swift`
- Modify: `apps/bemore-ios-native/BeMoreAgentShell/Capabilities/BeMoreCapabilityMirror.swift`
- Modify: `apps/bemore-ios-native/BeMoreAgentShell/RuntimeServices.swift`
- Modify: `apps/bemore-ios-native/project.yml`

**Acceptance criteria:**
- Native settings rows show linked/unlinked status for GitHub, ChatGPT/OpenAI, PixelLab.
- Buttons launch external OAuth URL flows with proper app-return URL placeholders/state.
- Linked state persists locally.
- Product copy stops falsely implying the features are already real if callback/backend is still incomplete.

**Important note:**
- This slice can ship a real native *link shell* and launch flow, but full OAuth completion depends on backend/client IDs and callback handling if not already available server-side.

---

## Slice 6: GitHub private-repo read path

**Objective:** Support authenticated GitHub API requests once a user links GitHub.

**Files:**
- Modify: `apps/bemore-ios-native/BeMoreAgentShell/GitHubService.swift`
- Modify: `apps/bemore-ios-native/BeMoreAgentShell/BeMoreWorkspaceRuntime.swift`
- Modify: `apps/bemore-ios-native/BeMoreAgentShell/RuntimeServices.swift`
- Add tests around authenticated request header generation if test harness allows.

**Acceptance criteria:**
- `GitHubService` can inject a bearer token from linked-account state.
- Private repo read capability status changes when linked.
- Public search remains working without a linked account.

---

## Slice 7: Local-model truth cleanup

**Objective:** Stop misleading the user about local models and tighten the local route UX.

**Files:**
- Modify: `apps/bemore-ios-native/BeMoreAgentShell/RuntimeServices.swift`
- Modify: `apps/bemore-ios-native/BeMoreAgentShell/Views/HomeView.swift`
- Modify: `apps/bemore-ios-native/BeMoreAgentShell/Views/ChatView.swift`
- Modify: `apps/bemore-ios-native/BeMoreAgentShell/Views/ModelsView.swift`
- Modify: `apps/bemore-ios-native/BeMoreAgentShell/Features/Models/ModelsTabView.swift`

**Acceptance criteria:**
- If local runtime package is absent, copy is explicit and short.
- If local runtime is present, route labels and chat status read as real on-device.
- No more “once available” hand-wave copy in primary surfaces.

---

## Slice 8: Tamagotchi-first daily loop

**Objective:** Make Buddy feel more like a living companion instead of a control panel.

**Files:**
- Modify: `apps/bemore-ios-native/BeMoreAgentShell/Views/BuddyView.swift`
- Modify: `apps/bemore-ios-native/BeMoreAgentShell/Views/HomeView.swift`
- Modify: `apps/bemore-ios-native/BeMoreAgentShell/OnboardingFlow.swift`
- Modify: `apps/bemore-ios-native/BeMoreAgentShell/BuddyEventEngine.swift`
- Modify: `apps/bemore-ios-native/BeMoreAgentShell/BuddyContracts.swift`

**Acceptance criteria:**
- Daily loop leads with Buddy mood/care/growth.
- Onboarding explains that the Buddy can be named, taught, cared for, customized, and grown.
- Care actions and growth feedback are more central than admin/runtime setup.

---

## Improvement list to include while landing the requested work

1. Remove stale capability descriptions that still mention web shell for Studio/admin.
2. Hide non-flagship “skills” from the product shell where they should be built-in capabilities.
3. Keep Pokémon Team Builder as the explicit skill while moving other useful behaviors into built-in Buddy capability language.
4. Add a lightweight animation playback preview to Studio after export/playback slice starts.
5. Add native artifact export/share from Studio and Buddy appearance surfaces.

---

## Suggested execution order

1. Slice 1 baseline commit
2. Slice 2 Buddy breakup
3. Slice 3 onboarding appearance
4. Slice 4 shared appearance editor
5. Slice 5 linked-account shell
6. Slice 6 authenticated GitHub read
7. Slice 7 local-model truth cleanup
8. Slice 8 tamagotchi-first polish

---

## Validation commands

```bash
cd /Users/prismtek/code/prismtek-apps/apps/bemore-ios-native
xcodegen generate
xcodebuild build -project /Users/prismtek/code/prismtek-apps/apps/bemore-ios-native/BeMoreAgent.xcodeproj -scheme BeMoreAgent -destination 'platform=iOS Simulator,name=iPhone 17'
```

If tests are run, record whether failures are pre-existing or introduced by the slice.
