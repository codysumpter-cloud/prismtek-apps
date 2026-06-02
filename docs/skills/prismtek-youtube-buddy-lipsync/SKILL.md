---
name: prismtek-youtube-buddy-lipsync
description: App-facing contract for a Prismtek/Buddy talking-host overlay workflow.
version: 1.1.0
author: Prismtek
canonical_runtime: codysumpter-cloud/buddy-agent#18
operator_reference: codysumpter-cloud/buddy-brain#315
---

# Prismtek YouTube Buddy Lip-Sync

This document is the BeMore / Prismtek Apps product contract for the Buddy talking-host lip-sync workflow.

The runnable implementation belongs in `buddy-agent`. The app should treat this as a future UI/UX contract for a local or relayed render workflow, not as an in-app media engine.

## Product Flow

1. User chooses a Buddy appearance.
2. User chooses a local video/audio source.
3. Runtime generates Buddy mouth states from the selected avatar.
4. Runtime renders a short proof clip.
5. User reviews the proof clip.
6. User may render the full version after review.

## App UX Requirements

- Show this as an optional media/creator workflow, not a required Buddy care loop.
- Make proof preview the default.
- Keep generated files visible in a user-controlled export/review surface.
- Never pretend a render is published or released just because it exists locally.
- Keep the exact runtime owner visible in developer/operator mode.

## Runtime Contract

The app should call into a runtime service that exposes:

```ts
interface BuddyLipSyncRequest {
  sourceVideoPath: string
  closedAvatarPath: string
  openAvatarPath: string
  outputPath?: string
  width?: number
  marginX?: number
  marginY?: number
  fps?: number
  sensitivity?: number
  limitSeconds?: number
}

interface BuddyLipSyncReceipt {
  receiptType: "buddy_lipsync_receipt"
  inputVideo: string
  outputVideo: string
  renderDurationSeconds: number
  fps: number
  mouthStats: Record<string, number>
  streams?: string
}
```

## Related PRs

- Canonical runtime package: `codysumpter-cloud/buddy-agent#18`
- Operator reference: `codysumpter-cloud/buddy-brain#315`
- Omni/local-device reference: `codysumpter-cloud/omni-buddy#11`
- Upstream context: `NousResearch/hermes-agent#26463`
