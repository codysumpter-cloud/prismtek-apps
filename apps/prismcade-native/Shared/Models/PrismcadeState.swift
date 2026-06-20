import Foundation

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
}
