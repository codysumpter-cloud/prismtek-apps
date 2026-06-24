import Foundation

enum PrismcadeGame: String, CaseIterable, Identifiable {
    case prismGrove
    case flappyPixel
    case dinoDash
    case buckBorris

    var id: String { rawValue }

    var previewAsset: String {
        switch self {
        case .prismGrove: "prism_grove_preview"
        case .flappyPixel: "flappy_preview"
        case .dinoDash: "dino_preview"
        case .buckBorris: "buck_preview"
        }
    }

    var manifestID: String {
        switch self {
        case .prismGrove: "prism-grove"
        case .flappyPixel: "flappy-pixel"
        case .dinoDash: "prismtek-dino-dash"
        case .buckBorris: "beat-em-up-buck"
        }
    }

    var title: String {
        switch self {
        case .prismGrove: "Prism Grove"
        case .flappyPixel: "Flappy Pixel"
        case .dinoDash: "Prismtek Dino Dash"
        case .buckBorris: "Beat Em Up Buck"
        }
    }

    var description: String {
        switch self {
        case .prismGrove: "Create a Prismcade avatar, grow a cozy garden, harvest crops, and unlock cosmetics."
        case .flappyPixel: "One-button Prismcade score chase with 50 playable birds and a pixel mountain stage."
        case .dinoDash: "Four-sprite dinosaur runner with character select, speed ramp, and a pixel hills stage."
        case .buckBorris: "Tiny native Buck Borris brawler with lane movement, attacks, health, and KO scoring."
        }
    }

    var sourceNote: String {
        switch self {
        case .prismGrove: "Art: procedural MVP placeholders; uploaded character/garden packs remain source-only until sliced into runtime layers."
        case .flappyPixel: "Art: Garden Birds, Onocentaur birds, and Background Hills from local LibreSprite packs."
        case .dinoDash: "Art: DinoSprites doux, mort, tard, vita sheets plus Background Hills layers."
        case .buckBorris: "Art: Buck Borris frames, a composited desert arena, and the licensed CraftPix Mummy enemy strips."
        }
    }
}

@MainActor
final class PrismcadeState: ObservableObject {
    @Published var selectedGame: PrismcadeGame?

    init() {
        if ProcessInfo.processInfo.environment["PRISMCADE_AUTOVERIFY_PLATFORM"] == "1" {
            PrismcadePlatform.shared.recordResult(gameID: "prism-grove", gameTitle: "Prism Grove", score: 42)
        }
        if !ProcessInfo.processInfo.environment.keys.contains(where: { $0.hasPrefix("PRISMCADE_AUTOVERIFY") }) {
            GameCenterService.shared.authenticate()
        }
        switch ProcessInfo.processInfo.environment["PRISMCADE_START_GAME"] {
        case "grove": selectedGame = .prismGrove
        case "flappy": selectedGame = .flappyPixel
        case "dino": selectedGame = .dinoDash
        case "buck": selectedGame = .buckBorris
        default: break
        }
    }

    func play(_ game: PrismcadeGame) { selectedGame = game }
    func returnToHub() { selectedGame = nil }
}
