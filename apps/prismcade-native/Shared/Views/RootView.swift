import SpriteKit
import SwiftUI
#if os(macOS)
import AppKit
#else
import UIKit
#endif

struct RootView: View {
    @EnvironmentObject private var state: PrismcadeState

    var body: some View {
        ZStack {
            PrismcadeBackdrop()
            if let game = state.selectedGame {
                GameHostView(game: game)
            } else {
                HubView()
            }
        }
        .foregroundStyle(.white)
    }
}

private struct PrismcadeBackdrop: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color(red: 0.05, green: 0.06, blue: 0.09),
                Color(red: 0.10, green: 0.08, blue: 0.14),
                Color(red: 0.04, green: 0.09, blue: 0.11)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

private struct HubView: View {
    @EnvironmentObject private var state: PrismcadeState
    @ObservedObject private var platform = PrismcadePlatform.shared

    private var entries: [PrismcadeCatalog.HubEntry] { PrismcadeCatalog.hubEntries }
    private var playableCount: Int { entries.filter(\.isPlayable).count }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                header
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 260), spacing: 16)], spacing: 16) {
                    ForEach(entries) { entry in
                        GameCard(entry: entry, best: platform.best(for: entry.id)) {
                            if let game = entry.nativeGame { state.play(game) }
                        }
                    }
                }
                recentResults
            }
            .padding(28)
            .frame(maxWidth: 1080, alignment: .leading)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Prismcade")
                .font(.system(size: 44, weight: .black, design: .rounded))
            Text("Native macOS/iOS launcher and runtime for the Prismtek arcade.")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.72))
            HStack(spacing: 10) {
                Image(systemName: "person.crop.circle.fill")
                    .foregroundStyle(Color(red: 0.15, green: 0.75, blue: 0.85))
                TextField("Handle", text: $platform.profileHandle)
                    .textFieldStyle(.plain)
                    .frame(maxWidth: 200)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                Text("\(playableCount) playable · \(entries.count) in catalog")
                    .font(.system(size: 12, weight: .semibold, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.6))
            }
            .padding(.top, 4)
        }
        .padding(.top, 26)
    }

    @ViewBuilder private var recentResults: some View {
        if !platform.receipts.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Text("Recent Results")
                    .font(.system(size: 20, weight: .black, design: .rounded))
                ForEach(platform.recentReceipts(limit: 8)) { receipt in
                    HStack {
                        Text(receipt.gameTitle)
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                        Spacer()
                        Text("Score \(receipt.score)")
                            .font(.system(size: 13, weight: .bold, design: .monospaced))
                            .foregroundStyle(Color(red: 1.0, green: 0.85, blue: 0.42))
                    }
                    .padding(.vertical, 6)
                    .padding(.horizontal, 12)
                    .background(Color.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 6))
                }
            }
        }
    }
}

private struct GameCard: View {
    let entry: PrismcadeCatalog.HubEntry
    let best: Int
    let play: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Group {
                if let game = entry.nativeGame {
                    GamePreview(game: game)
                } else {
                    PlannedPreview()
                }
            }
            .frame(height: 120)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

            HStack {
                Text(entry.title)
                    .font(.system(size: 20, weight: .black, design: .rounded))
                Spacer()
                if entry.isPlayable && best > 0 {
                    Text("Best \(best)")
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundStyle(Color(red: 1.0, green: 0.85, blue: 0.42))
                }
            }
            Text(entry.description)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.74))
                .fixedSize(horizontal: false, vertical: true)
            Text(entry.status)
                .font(.system(size: 10, weight: .heavy, design: .monospaced))
                .foregroundStyle(entry.isPlayable ? Color(red: 0.4, green: 0.9, blue: 0.6) : .white.opacity(0.5))

            Button(action: play) {
                Text(entry.isPlayable ? "Play" : "Planned")
                    .font(.system(size: 15, weight: .black, design: .rounded))
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(entry.isPlayable ? Color(red: 0.15, green: 0.75, blue: 0.85) : Color.gray)
            .disabled(!entry.isPlayable)
        }
        .padding(16)
        .background(Color.white.opacity(0.07), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(Color.white.opacity(0.16), lineWidth: 1)
        )
    }
}

/// Real gameplay preview for native games (bundled snapshot), with the symbolic preview as a
/// fallback if the image is missing.
private struct GamePreview: View {
    let game: PrismcadeGame

    var body: some View {
        if let image = Self.bundledImage(game.previewAsset) {
            image
                .resizable()
                .interpolation(.none)
                .aspectRatio(contentMode: .fill)
        } else {
            PixelPreview(game: game)
        }
    }

    static func bundledImage(_ name: String) -> Image? {
        guard let url = Bundle.main.url(forResource: name, withExtension: "png") else { return nil }
        #if os(macOS)
        guard let ns = NSImage(contentsOf: url) else { return nil }
        return Image(nsImage: ns)
        #else
        guard let ui = UIImage(contentsOfFile: url.path) else { return nil }
        return Image(uiImage: ui)
        #endif
    }
}

private struct PlannedPreview: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.10, green: 0.13, blue: 0.20), Color(red: 0.07, green: 0.09, blue: 0.14)],
                startPoint: .top, endPoint: .bottom
            )
            Image(systemName: "gamecontroller")
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(.white.opacity(0.28))
        }
    }
}

private struct PixelPreview: View {
    let game: PrismcadeGame

    var body: some View {
        Image(previewName)
            .resizable()
            .interpolation(.none)
            .scaledToFill()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipped()
    }

    private var previewName: String {
        switch game {
        case .flappyPixel: "preview_flappy_pixel"
        case .dinoDash: "preview_dino_dash"
        case .buckBorris: "preview_beat_em_up_buck"
        }
    }
}

/// Shared game shell: a consistent results/status bar (best, last result, leaderboard sync) plus
/// restart + return, wrapped around any native scene so individual games don't reinvent post-game UI.
private struct GameHostView: View {
    @EnvironmentObject private var state: PrismcadeState
    @ObservedObject private var platform = PrismcadePlatform.shared
    @ObservedObject private var leaderboard = LeaderboardService.shared
    let game: PrismcadeGame
    @State private var sceneReloadToken = UUID()

    private var best: Int { platform.best(for: game.manifestID) }
    private var lastResult: MatchReceipt? { platform.recentReceipts(for: game.manifestID, limit: 1).first }

    var body: some View {
        VStack(spacing: 0) {
            shellBar
            SpriteKitContainer(scene: scene(for: game))
                .id(sceneReloadToken)
                .ignoresSafeArea(edges: .bottom)
        }
    }

    private var shellBar: some View {
        HStack(spacing: 12) {
            Button("Return") { state.returnToHub() }
                .buttonStyle(.borderedProminent)
                .tint(Color(red: 0.15, green: 0.75, blue: 0.85))
            Button("Restart") { sceneReloadToken = UUID() }
                .buttonStyle(.bordered)

            Text(game.title)
                .font(.system(size: 18, weight: .black, design: .rounded))

            Spacer()

            shellStat("Best", "\(best)")
            if let last = lastResult {
                shellStat("Last", "\(last.score)")
            }
            shellStat("Leaderboard", leaderboard.syncStateDescription)
        }
        .padding(12)
        .background(Color.black.opacity(0.28))
    }

    private func shellStat(_ label: String, _ value: String) -> some View {
        VStack(alignment: .trailing, spacing: 1) {
            Text(label)
                .font(.system(size: 9, weight: .heavy, design: .monospaced))
                .foregroundStyle(.white.opacity(0.55))
            Text(value)
                .font(.system(size: 13, weight: .bold, design: .monospaced))
                .foregroundStyle(Color(red: 1.0, green: 0.85, blue: 0.42))
        }
    }

    private func scene(for game: PrismcadeGame) -> SKScene {
        switch game {
        case .flappyPixel:
            FlappyPixelScene()
        case .dinoDash:
            DinoDashScene()
        case .buckBorris:
            BuckBorrisScene()
        }
    }
}
