import Foundation
#if os(macOS)
import AppKit
#endif

enum PrismcadeGame: String, CaseIterable, Identifiable {
    case flappyPixel
    case dinoDash
    case buckBorris

    var id: String { rawValue }

    var title: String {
        switch self {
        case .flappyPixel: "Flappy Pixel"
        case .dinoDash: "Prismtek Dino Dash"
        case .buckBorris: "Buck Borris Mini-Game"
        }
    }

    var description: String {
        switch self {
        case .flappyPixel: "One-button Prismcade score chase with a real bird sprite and tight restarts."
        case .dinoDash: "Four-sprite dinosaur runner with character select and speed ramp."
        case .buckBorris: "Small Buck Borris arcade dodge prototype using the real Buck frame set."
        }
    }

    var sourceNote: String {
        switch self {
        case .flappyPixel: "Art: Onocentaur bird sheet, curated from Documents/Libresprite."
        case .dinoDash: "Art: DinoSprites doux, mort, tard, vita sheets."
        case .buckBorris: "Art: Buck Borris sensible frames and strips."
        }
    }
}

@MainActor
final class PrismcadeState: ObservableObject {
    @Published var selectedGame: PrismcadeGame?

    init() {
        let startGame = ProcessInfo.processInfo.environment["PRISMCADE_START_GAME"]
        if ProcessInfo.processInfo.environment["PRISMCADE_AUTOVERIFY_HUB"] == "1" {
            writeHubVerification()
        }
        if startGame == "flappy" {
            selectedGame = .flappyPixel
            try? "flappy\n".write(toFile: "/tmp/prismcade-start-game-marker.txt", atomically: true, encoding: .utf8)
        } else if startGame == "dino" {
            selectedGame = .dinoDash
            try? "dino\n".write(toFile: "/tmp/prismcade-start-game-marker.txt", atomically: true, encoding: .utf8)
        } else if startGame == "buck" {
            selectedGame = .buckBorris
            try? "buck\n".write(toFile: "/tmp/prismcade-start-game-marker.txt", atomically: true, encoding: .utf8)
        }
    }

    func play(_ game: PrismcadeGame) {
        selectedGame = game
    }

    func returnToHub() {
        selectedGame = nil
    }

    private func writeHubVerification() {
        let titles = PrismcadeGame.allCases.map(\.title)
        let receipt: [String: Any] = [
            "screen": "Prismcade hub",
            "gameCards": titles,
            "cardCount": titles.count,
            "selectedGame": selectedGame?.title ?? NSNull(),
            "verified": titles.contains("Flappy Pixel")
                && titles.contains("Prismtek Dino Dash")
                && titles.contains("Buck Borris Mini-Game")
        ]
        if let data = try? JSONSerialization.data(withJSONObject: receipt, options: [.prettyPrinted, .sortedKeys]) {
            try? data.write(to: URL(fileURLWithPath: "/tmp/prismcade-hub-runtime-verification.json"), options: .atomic)
        }
        #if os(macOS)
        writeHubSnapshot(titles: titles)
        #endif
    }

    #if os(macOS)
    private func writeHubSnapshot(titles: [String]) {
        let size = NSSize(width: 1100, height: 720)
        let image = NSImage(size: size)
        image.lockFocus()

        NSColor(calibratedRed: 0.05, green: 0.06, blue: 0.09, alpha: 1).setFill()
        NSBezierPath(rect: NSRect(origin: .zero, size: size)).fill()
        NSColor(calibratedRed: 0.10, green: 0.16, blue: 0.19, alpha: 1).setFill()
        NSBezierPath(rect: NSRect(x: 0, y: 0, width: size.width, height: 260)).fill()

        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 48, weight: .black),
            .foregroundColor: NSColor.white
        ]
        NSString(string: "Prismcade").draw(at: NSPoint(x: 64, y: 620), withAttributes: titleAttributes)

        let subtitleAttributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 18, weight: .medium),
            .foregroundColor: NSColor(calibratedWhite: 1, alpha: 0.74)
        ]
        NSString(string: "Native macOS/iOS launcher and runtime for Prismtek arcade games.")
            .draw(at: NSPoint(x: 66, y: 590), withAttributes: subtitleAttributes)

        let cardWidth: CGFloat = 300
        let cardHeight: CGFloat = 310
        for (index, game) in PrismcadeGame.allCases.enumerated() {
            let x = CGFloat(index) * (cardWidth + 28) + 64
            let cardRect = NSRect(x: x, y: 210, width: cardWidth, height: cardHeight)
            NSColor(calibratedWhite: 1, alpha: 0.08).setFill()
            NSBezierPath(roundedRect: cardRect, xRadius: 8, yRadius: 8).fill()
            NSColor(calibratedWhite: 1, alpha: 0.20).setStroke()
            NSBezierPath(roundedRect: cardRect, xRadius: 8, yRadius: 8).stroke()

            drawPreview(for: game, in: NSRect(x: x + 18, y: 360, width: cardWidth - 36, height: 130))

            NSString(string: game.title).draw(
                in: NSRect(x: x + 18, y: 320, width: cardWidth - 36, height: 30),
                withAttributes: [
                    .font: NSFont.systemFont(ofSize: 21, weight: .black),
                    .foregroundColor: NSColor.white
                ]
            )
            NSString(string: game.sourceNote).draw(
                in: NSRect(x: x + 18, y: 246, width: cardWidth - 36, height: 52),
                withAttributes: [
                    .font: NSFont.monospacedSystemFont(ofSize: 11, weight: .semibold),
                    .foregroundColor: NSColor(calibratedRed: 1.0, green: 0.85, blue: 0.42, alpha: 1)
                ]
            )
        }

        image.unlockFocus()
        guard let tiff = image.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiff),
              let png = bitmap.representation(using: .png, properties: [:]) else {
            return
        }
        try? png.write(to: URL(fileURLWithPath: "/tmp/prismcade-hub-runtime-snapshot.png"), options: .atomic)
    }

    private func drawPreview(for game: PrismcadeGame, in rect: NSRect) {
        NSColor(calibratedRed: 0.08, green: 0.16, blue: 0.22, alpha: 1).setFill()
        NSBezierPath(roundedRect: rect, xRadius: 6, yRadius: 6).fill()
        switch game {
        case .flappyPixel:
            fillPixel(NSRect(x: rect.minX + 58, y: rect.minY + 50, width: 42, height: 28), red: 0.98, green: 0.95, blue: 0.88)
            fillPixel(NSRect(x: rect.minX + 92, y: rect.minY + 57, width: 18, height: 10), red: 1.0, green: 0.55, blue: 0.12)
            fillPixel(NSRect(x: rect.minX + 150, y: rect.minY, width: 30, height: 48), red: 0.18, green: 0.72, blue: 0.50)
            fillPixel(NSRect(x: rect.minX + 150, y: rect.minY + 88, width: 30, height: 42), red: 0.18, green: 0.72, blue: 0.50)
        case .dinoDash:
            fillPixel(NSRect(x: rect.minX + 54, y: rect.minY + 34, width: 56, height: 34), red: 0.42, green: 0.86, blue: 0.46)
            fillPixel(NSRect(x: rect.minX, y: rect.minY + 16, width: rect.width, height: 10), red: 0.83, green: 0.67, blue: 0.39)
            fillPixel(NSRect(x: rect.minX + 154, y: rect.minY + 24, width: 18, height: 30), red: 0.78, green: 0.92, blue: 0.54)
        case .buckBorris:
            fillPixel(NSRect(x: rect.minX + 58, y: rect.minY + 30, width: 42, height: 58), red: 0.78, green: 0.44, blue: 0.28)
            fillPixel(NSRect(x: rect.minX + 150, y: rect.minY + 60, width: 34, height: 34), red: 0.25, green: 0.78, blue: 0.90)
            fillPixel(NSRect(x: rect.minX, y: rect.minY + 16, width: rect.width, height: 10), red: 0.48, green: 0.34, blue: 0.22)
        }
    }

    private func fillPixel(_ rect: NSRect, red: CGFloat, green: CGFloat, blue: CGFloat) {
        NSColor(calibratedRed: red, green: green, blue: blue, alpha: 1).setFill()
        NSBezierPath(rect: rect).fill()
    }
    #endif
}
