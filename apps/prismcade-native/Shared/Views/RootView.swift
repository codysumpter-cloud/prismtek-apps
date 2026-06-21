import SpriteKit
import SwiftUI

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
                    PixelPreview(game: game)
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
        Canvas { context, size in
            let sky = Path(CGRect(origin: .zero, size: size))
            context.fill(sky, with: .color(Color(red: 0.08, green: 0.16, blue: 0.22)))
            for index in 0..<14 {
                let x = CGFloat(index) * size.width / 14
                let y = CGFloat((index * 29) % 72) + 18
                context.fill(Path(CGRect(x: x, y: y, width: 18, height: 8)), with: .color(.white.opacity(0.18)))
            }
            switch game {
            case .flappyPixel:
                drawRect(&context, x: 74, y: 52, w: 42, h: 28, color: Color(red: 0.98, green: 0.95, blue: 0.88))
                drawRect(&context, x: 106, y: 58, w: 18, h: 10, color: .orange)
                drawRect(&context, x: 148, y: 0, w: 28, h: 48, color: Color(red: 0.18, green: 0.72, blue: 0.50))
                drawRect(&context, x: 148, y: 91, w: 28, h: 42, color: Color(red: 0.18, green: 0.72, blue: 0.50))
            case .dinoDash:
                drawRect(&context, x: 58, y: 72, w: 56, h: 32, color: Color(red: 0.42, green: 0.86, blue: 0.46))
                drawRect(&context, x: 148, y: 78, w: 18, h: 28, color: Color(red: 0.78, green: 0.92, blue: 0.54))
                drawRect(&context, x: 0, y: 108, w: size.width, h: 10, color: Color(red: 0.83, green: 0.67, blue: 0.39))
            case .buckBorris:
                drawRect(&context, x: 62, y: 48, w: 40, h: 56, color: Color(red: 0.78, green: 0.44, blue: 0.28))
                drawRect(&context, x: 148, y: 44, w: 34, h: 34, color: Color(red: 0.25, green: 0.78, blue: 0.90))
                drawRect(&context, x: 0, y: 108, w: size.width, h: 10, color: Color(red: 0.48, green: 0.34, blue: 0.22))
            }
        }
    }

    private func drawRect(_ context: inout GraphicsContext, x: CGFloat, y: CGFloat, w: CGFloat, h: CGFloat, color: Color) {
        context.fill(Path(CGRect(x: x, y: y, width: w, height: h)), with: .color(color))
    }
}

private struct GameHostView: View {
    @EnvironmentObject private var state: PrismcadeState
    let game: PrismcadeGame

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button("Return to Prismcade") {
                    state.returnToHub()
                }
                .buttonStyle(.borderedProminent)
                .tint(Color(red: 0.15, green: 0.75, blue: 0.85))

                Text(game.title)
                    .font(.system(size: 18, weight: .black, design: .rounded))
                Spacer()
            }
            .padding(12)
            .background(Color.black.opacity(0.28))

            SpriteKitContainer(scene: scene(for: game))
                .ignoresSafeArea(edges: .bottom)
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
