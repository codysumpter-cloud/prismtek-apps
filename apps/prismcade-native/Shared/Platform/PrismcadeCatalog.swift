import Foundation

/// A canonical Prismcade catalog entry (subset of `data/prismcade/prismcade-catalog.json`).
/// The canonical catalog is the union of the web/HTML catalog, the prismtek-apps registry, and
/// native runtimes — the single source of truth the native hub renders for cross-surface parity.
struct CanonicalGame: Codable, Identifiable {
    struct Web: Codable { let present: Bool; let playable: Bool }

    let id: String
    let title: String
    let description: String
    let categories: [String]
    let web: Web
    let website: Bool
    let windows: String
    let native: String            // "playable" | "planned"
    let canonicalRuntime: String  // "native" | "web" | "apps"
    let replaces: [String]
}

private struct CanonicalCatalogFile: Codable {
    let games: [CanonicalGame]
}

/// Loads the bundled canonical catalog and unifies it with native runtimes so the hub shows the
/// full platform with honest status: native-playable games launch a scene, every other catalog
/// game surfaces as a clearly-labelled "planned" parity target (no fake playable buttons).
enum PrismcadeCatalog {
    /// Every canonical catalog game (decoded from the bundled catalog).
    static let canonical: [CanonicalGame] = {
        guard let url = Bundle.main.url(forResource: "prismcade-catalog", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let file = try? JSONDecoder().decode(CanonicalCatalogFile.self, from: data) else {
            return []
        }
        return file.games
    }()

    static func nativeRuntime(for id: String) -> PrismcadeGame? {
        PrismcadeGame.allCases.first { $0.manifestID == id }
    }

    struct HubEntry: Identifiable {
        let id: String
        let title: String
        let description: String
        let status: String
        let nativeGame: PrismcadeGame?
        let webPlayable: Bool
        var isPlayable: Bool { nativeGame != nil }
    }

    /// Native-playable runtimes first (in enum order), then every other catalog game as a planned
    /// parity target. One entry per id — native canonical builds dedupe their web duplicate.
    static var hubEntries: [HubEntry] {
        let byID = Dictionary(canonical.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        var entries: [HubEntry] = []
        var used = Set<String>()

        for game in PrismcadeGame.allCases {
            let canonicalEntry = byID[game.manifestID]
            entries.append(
                HubEntry(
                    id: game.manifestID,
                    title: canonicalEntry?.title ?? game.title,
                    description: canonicalEntry?.description ?? game.description,
                    status: "native-playable",
                    nativeGame: game,
                    webPlayable: canonicalEntry?.web.playable ?? false
                )
            )
            used.insert(game.manifestID)
        }

        for game in canonical where !used.contains(game.id) {
            entries.append(
                HubEntry(
                    id: game.id,
                    title: game.title,
                    description: game.description,
                    status: game.web.playable ? "planned · playable on web" : "planned",
                    nativeGame: nil,
                    webPlayable: game.web.playable
                )
            )
        }
        return entries
    }
}
