import SwiftUI
import UIKit

struct BuddyPixelView: View {
    @EnvironmentObject private var appState: AppState

    var buddy: BuddyInstance?
    var template: CouncilStarterBuddyTemplate?
    var previewSpec: BuddyAppearancePreviewSpec?
    let mood: BuddyAnimationMood
    var compact = false

    @State private var pixelRecord: PixelLabPreviewRecord?

    var body: some View {
        VStack(spacing: compact ? 10 : 14) {
            previewBody

            if let pixelRecord {
                Text(statusLabel(for: pixelRecord))
                    .font(.caption)
                    .foregroundColor(BMOTheme.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .task(id: refreshKey) {
            await loadOrSyncPreview()
        }
    }

    private var refreshKey: String {
        let tokenState = appState.linkedAccountStore.record(for: .pixelLab).isLinked ? "linked" : "unlinked"
        return "\(requestKey ?? "none")|\(tokenState)"
    }

    private var pendingExplanation: String {
        if appState.linkedAccountStore.record(for: .pixelLab).isLinked {
            return "This Buddy look has a pixel render key but no real PixelLab preview yet."
        }
        return "Link PixelLab to generate a real pixel Buddy instead of a placeholder icon."
    }

    private func loadOrSyncPreview() async {
        guard let requestKey, requestKey.hasPrefix("pixellab:"), !requestKey.isEmpty else {
            await MainActor.run { pixelRecord = nil }
            return
        }
        if let existing = PixelLabPreviewService.record(for: requestKey) {
            await MainActor.run { pixelRecord = existing }
            if existing.status == .ready { return }
        }
        guard let token = appState.linkedAccountStore.record(for: .pixelLab).accessToken?.trimmingCharacters(in: .whitespacesAndNewlines), !token.isEmpty else {
            return
        }
        let record = await PixelLabPreviewService.sync(spec: spec, accessToken: token)
        await MainActor.run { pixelRecord = record }
    }

    private func statusLabel(for record: PixelLabPreviewRecord) -> String {
        switch record.status {
        case .queued: return "PixelLab job queued."
        case .ready: return "Real PixelLab preview loaded."
        case .failed: return record.errorMessage ?? "PixelLab generation failed."
        }
    }

    private func fallbackCard(title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(BMOTheme.textPrimary)
            Text(body)
                .font(.caption)
                .foregroundColor(BMOTheme.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(compact ? 12 : 20)
        .background(BMOTheme.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: BMOTheme.radiusSmall, style: .continuous))
    }

    private var templatePaletteID: String {
        template.map { CouncilBuddyIdentityCatalog.identity(for: $0).palette } ?? "mint_cream"
    }

    private var requestKey: String? {
        previewSpec?.pixelRequestKey ?? buddy?.visual?.pixelVariantId
    }

    private var spec: BuddyAppearancePreviewSpec {
        if let previewSpec {
            return previewSpec
        }
        return BuddyAppearanceRenderContract.makePreviewSpec(
            buddyName: buddy?.displayName ?? template?.name ?? "Buddy",
            archetypeID: buddy?.identity.archetype ?? template.map { CouncilBuddyIdentityCatalog.identity(for: $0).archetype } ?? "console_pet",
            paletteID: buddy?.identity.palette ?? templatePaletteID,
            asciiVariantID: buddy?.visual?.asciiVariantId ?? "starter_a",
            expressionTone: buddyExpressionTone,
            accentLabel: buddy?.visual?.evolutionCosmetics.first ?? "pocket glow",
            renderStyle: .pixel,
            pixelRequestKey: buddy?.visual?.pixelVariantId,
            pixelAssetPath: buddy?.visual?.pixelAssetPath
        )
    }

    private var buddyExpressionTone: String {
        switch (buddy?.visual?.currentAnimationState ?? buddy?.state.mood)?.lowercased() {
        case "thinking": return "curious"
        case "working": return "focused"
        default: return "friendly"
        }
    }

    @ViewBuilder
    private var previewBody: some View {
        if let localPath = pixelRecord?.localAssetPath ?? previewSpec?.pixelAssetPath ?? buddy?.visual?.pixelAssetPath,
           FileManager.default.fileExists(atPath: localPath),
           let image = UIImage(contentsOfFile: localPath) {
            imageCard(image)
        } else if pixelRecord?.status == .queued {
            ProgressView()
                .frame(maxWidth: .infinity)
                .padding(compact ? 12 : 20)
                .background(BMOTheme.backgroundSecondary)
                .clipShape(RoundedRectangle(cornerRadius: BMOTheme.radiusSmall, style: .continuous))
        } else if supportsASCIIFallback {
            VStack(alignment: .leading, spacing: 8) {
                if pixelRecord?.errorMessage != nil {
                    Text(pixelRecord?.errorMessage ?? "Pixel preview unavailable.")
                        .font(.caption)
                        .foregroundColor(BMOTheme.textSecondary)
                }
                BuddyAsciiView(buddy: buddy, template: template, previewSpec: spec, mood: mood, compact: compact)
            }
        } else {
            fallbackCard(title: "Pixel preview unavailable", body: pixelRecord?.errorMessage ?? pendingExplanation)
        }
    }

    private func imageCard(_ image: UIImage) -> some View {
        Image(uiImage: image)
            .resizable()
            .interpolation(.none)
            .scaledToFit()
            .frame(maxWidth: compact ? 120 : 180, maxHeight: compact ? 120 : 180)
            .padding(compact ? 8 : 16)
            .frame(maxWidth: .infinity)
            .background(BMOTheme.backgroundSecondary)
            .clipShape(RoundedRectangle(cornerRadius: BMOTheme.radiusSmall, style: .continuous))
    }

    private var supportsASCIIFallback: Bool {
        let supported = [
            "dino", "pixel_pet", "cat_like", "fox_like", "robot",
            "slime", "plant_creature", "mini_wizard", "spirit",
            "companion_orb", "tiny_monster", "console_pet"
        ]
        return supported.contains(spec.archetypeID)
    }
}
