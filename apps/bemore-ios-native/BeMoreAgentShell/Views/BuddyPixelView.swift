import SwiftUI

struct BuddyPixelView: View {
    @EnvironmentObject private var appState: AppState

    var buddy: BuddyInstance?
    var template: CouncilStarterBuddyTemplate?
    let mood: BuddyAnimationMood
    var compact = false

    @State private var pixelRecord: PixelLabPreviewRecord?

    var body: some View {
        VStack(spacing: compact ? 10 : 14) {
            if let previewURL = pixelRecord?.previewURL,
               let url = URL(string: previewURL) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding(compact ? 12 : 20)
                            .background(BMOTheme.backgroundSecondary)
                            .clipShape(RoundedRectangle(cornerRadius: BMOTheme.radiusSmall, style: .continuous))
                    case .success(let image):
                        image
                            .resizable()
                            .interpolation(.none)
                            .scaledToFit()
                            .frame(maxWidth: compact ? 120 : 180, maxHeight: compact ? 120 : 180)
                            .padding(compact ? 8 : 16)
                            .frame(maxWidth: .infinity)
                            .background(BMOTheme.backgroundSecondary)
                            .clipShape(RoundedRectangle(cornerRadius: BMOTheme.radiusSmall, style: .continuous))
                    case .failure:
                        fallbackCard(title: "Pixel preview unavailable", body: pixelRecord?.errorMessage ?? "No preview image was returned.")
                    @unknown default:
                        fallbackCard(title: "Pixel preview unavailable", body: "Unknown preview state.")
                    }
                }
            } else {
                switch pixelRecord?.status {
                case .queued:
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(compact ? 12 : 20)
                        .background(BMOTheme.backgroundSecondary)
                        .clipShape(RoundedRectangle(cornerRadius: BMOTheme.radiusSmall, style: .continuous))
                case .failed:
                    fallbackCard(title: "PixelLab generation failed", body: pixelRecord?.errorMessage ?? "This pixel look failed to generate.")
                default:
                    fallbackCard(title: "No PixelLab render", body: pendingExplanation)
                }
            }

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
        return "\(buddy?.visual?.pixelVariantId ?? "none")|\(tokenState)"
    }

    private var pendingExplanation: String {
        if appState.linkedAccountStore.record(for: .pixelLab).isLinked {
            return "This Buddy look has a pixel render key but no real PixelLab preview yet."
        }
        return "Link PixelLab to generate a real pixel Buddy instead of a placeholder icon."
    }

    private func loadOrSyncPreview() async {
        guard let requestKey = buddy?.visual?.pixelVariantId, requestKey.hasPrefix("pixellab:"), !requestKey.isEmpty else {
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
        let record = await PixelLabPreviewService.sync(
            requestKey: requestKey,
            buddyName: buddy?.displayName ?? template?.name ?? "Buddy",
            archetypeID: buddy?.identity.archetype ?? template.map { CouncilBuddyIdentityCatalog.identity(for: $0).archetype } ?? "console_pet",
            paletteID: buddy?.identity.palette ?? templatePaletteID,
            expressionTone: buddy?.visual?.currentAnimationState ?? buddy?.state.mood ?? "happy",
            accentLabel: buddy?.visual?.evolutionCosmetics.first ?? "pocket glow",
            accessToken: token
        )
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
}
