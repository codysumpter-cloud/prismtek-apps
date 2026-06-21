import Foundation

/// A Prismcade game manifest entry (subset of `data/prismcade/game-manifests.json`).
/// Decoded leniently so the native catalog tracks the same canonical source the web uses.
struct GameManifest: Codable, Identifiable {
    let id: String
    let title: String
    let slug: String?
    let status: String?
    let arcadeRole: String?
    let priority: String?
    let description: String?
    let tags: [String]?
}

private struct CatalogFile: Codable {
    let games: [GameManifest]
}

/// Loads the bundled canonical catalog and unifies it with the native runtimes so the hub can
/// show every game with honest status: native-playable games launch a scene, catalog-only games
/// surface as "planned" (web parity targets).
enum PrismcadeCatalog {
    /// Catalog entries decoded from the bundled canonical manifest.
    static let manifests: [GameManifest] = {
        guard let url = Bundle.main.url(forResource: "prismcade-game-manifests", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let file = try? JSONDecoder().decode(CatalogFile.self, from: data) else {
            return []
        }
        return file.games
    }()

    struct HubEntry: Identifiable {
        let id: String
        let title: String
        let description: String
        let status: String
        let nativeGame: PrismcadeGame?
        var isPlayable: Bool { nativeGame != nil }
    }

    /// Native runtimes first (playable), then any catalog game without a native runtime (planned).
    static var hubEntries: [HubEntry] {
        var entries: [HubEntry] = PrismcadeGame.allCases.map { game in
            HubEntry(
                id: game.manifestID,
                title: game.title,
                description: game.description,
                status: "native-playable",
                nativeGame: game
            )
        }
        let nativeIDs = Set(entries.map(\.id))
        for manifest in manifests where !nativeIDs.contains(manifest.id) {
            entries.append(
                HubEntry(
                    id: manifest.id,
                    title: manifest.title,
                    description: manifest.description ?? "Prismcade catalog game.",
                    status: "planned (web: \(manifest.status ?? "unknown"))",
                    nativeGame: nil
                )
            )
        }
        return entries
    }
}
