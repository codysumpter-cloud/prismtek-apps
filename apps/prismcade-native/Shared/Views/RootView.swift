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
                creatorTools
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

    private var creatorTools: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Creator Tools")
                .font(.system(size: 20, weight: .black, design: .rounded))
            HStack(alignment: .center, spacing: 14) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Prism Grove Character Creator")
                        .font(.system(size: 17, weight: .black, design: .rounded))
                    Text("Create your avatar inside the native Prism Grove scene. The web game uses the same Prismcade account key.")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.72))
                        .fixedSize(horizontal: false, vertical: true)
                    Text("games/prism-grove · prismcade.localAccount.v0")
                        .font(.system(size: 10, weight: .heavy, design: .monospaced))
                        .foregroundStyle(Color(red: 0.4, green: 0.9, blue: 0.6))
                }
                Spacer()
                Button("Open Native Grove") { state.play(.prismGrove) }
                    .buttonStyle(.borderedProminent)
                    .tint(Color(red: 0.15, green: 0.75, blue: 0.85))
            }
            .padding(16)
            .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(Color.white.opacity(0.14), lineWidth: 1)
            )
        }
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

private struct GamePreview: View {
    let game: PrismcadeGame

    var body: some View {
        if game == .prismGrove {
            PrismGrovePreview()
        } else if let image = Self.bundledImage(game.previewAsset) {
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

private struct PrismGrovePreview: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.10, green: 0.23, blue: 0.14), Color(red: 0.06, green: 0.12, blue: 0.10)],
                startPoint: .top,
                endPoint: .bottom
            )
            ForEach(0..<8, id: \.self) { index in
                Rectangle()
                    .fill(index.isMultiple(of: 2) ? Color(red: 0.55, green: 0.38, blue: 0.25) : Color(red: 0.37, green: 0.28, blue: 0.22))
                    .frame(width: 34, height: 24)
                    .offset(x: CGFloat((index % 4) * 46 - 70), y: CGFloat((index / 4) * 34 - 16))
            }
            VStack(spacing: 0) {
                Rectangle().fill(Color(red: 0.22, green: 0.13, blue: 0.08)).frame(width: 18, height: 8)
                Rectangle().fill(Color(red: 0.94, green: 0.78, blue: 0.62)).frame(width: 16, height: 16)
                Rectangle().fill(Color(red: 0.07, green: 0.72, blue: 0.78)).frame(width: 22, height: 28)
            }
            .offset(x: 64, y: 26)
        }
    }
}

private struct PlannedPreview: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.10, green: 0.13, blue: 0.20), Color(red: 0.07, green: 0.09, blue: 0.14)],
                startPoint: .top,
                endPoint: .bottom
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
        case .prismGrove: "preview_prism_grove"
        case .flappyPixel: "preview_flappy_pixel"
        case .dinoDash: "preview_dino_dash"
        case .buckBorris: "preview_beat_em_up_buck"
        }
    }
}

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
        case .prismGrove:
            PrismGroveScene()
        case .flappyPixel:
            FlappyPixelScene()
        case .dinoDash:
            DinoDashScene()
        case .buckBorris:
            BuckBorrisScene()
        }
    }
}

private final class PrismGroveScene: SKScene {
    private var player = CGPoint(x: 520, y: 230)
    private var seedIndex = 0
    private var coins = 80
    private var harvests = 0
    private let cropColors: [SKColor] = [.orange, .red, .yellow, .cyan]
    private let status = SKLabelNode(fontNamed: "Menlo-Bold")

    override init(size: CGSize = CGSize(width: 1024, height: 640)) {
        super.init(size: size)
        scaleMode = .resizeFill
        backgroundColor = SKColor(red: 0.08, green: 0.15, blue: 0.11, alpha: 1)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func didMove(to view: SKView) {
        redraw()
    }

    #if os(macOS)
    override func mouseDown(with event: NSEvent) {
        player = event.location(in: self)
        harvest()
        redraw()
    }
    #else
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let point = touches.first?.location(in: self) { player = point }
        harvest()
        redraw()
    }
    #endif

    private func harvest() {
        coins += 18 + seedIndex * 8
        harvests += 1
        seedIndex = (seedIndex + 1) % cropColors.count
        Task { @MainActor in
            PrismcadePlatform.shared.recordResult(gameID: "prism-grove", gameTitle: "Prism Grove", score: coins + harvests * 10)
        }
    }

    private func redraw() {
        removeAllChildren()
        for x in stride(from: 0, through: Int(size.width), by: 48) {
            for y in stride(from: 0, through: Int(size.height), by: 48) {
                let tile = SKSpriteNode(color: ((x + y) / 48).isMultiple(of: 2) ? SKColor(red: 0.10, green: 0.24, blue: 0.13, alpha: 1) : SKColor(red: 0.12, green: 0.28, blue: 0.15, alpha: 1), size: CGSize(width: 48, height: 48))
                tile.position = CGPoint(x: CGFloat(x) + 24, y: CGFloat(y) + 24)
                addChild(tile)
            }
        }
        for index in 0..<18 {
            let plot = SKSpriteNode(color: index.isMultiple(of: 2) ? SKColor(red: 0.55, green: 0.39, blue: 0.27, alpha: 1) : SKColor(red: 0.37, green: 0.28, blue: 0.22, alpha: 1), size: CGSize(width: 62, height: 44))
            plot.position = CGPoint(x: 170 + CGFloat(index % 6) * 92, y: size.height - 170 - CGFloat(index / 6) * 76)
            plot.zPosition = 2
            addChild(plot)
            let plant = SKSpriteNode(color: cropColors[index % cropColors.count], size: CGSize(width: 14, height: 24))
            plant.position = CGPoint(x: plot.position.x, y: plot.position.y + 20)
            plant.zPosition = 3
            addChild(plant)
        }
        let body = SKSpriteNode(color: SKColor(red: 0.07, green: 0.72, blue: 0.78, alpha: 1), size: CGSize(width: 32, height: 42))
        body.position = player
        body.zPosition = 10
        addChild(body)
        let head = SKSpriteNode(color: SKColor(red: 0.94, green: 0.78, blue: 0.62, alpha: 1), size: CGSize(width: 30, height: 30))
        head.position = CGPoint(x: player.x, y: player.y + 38)
        head.zPosition = 11
        addChild(head)
        status.text = "Prism Grove native MVP · tap plots · coins \(coins) · harvests \(harvests)"
        status.fontSize = 20
        status.fontColor = .white
        status.position = CGPoint(x: size.width / 2, y: size.height - 54)
        status.zPosition = 20
        addChild(status)
    }
}
