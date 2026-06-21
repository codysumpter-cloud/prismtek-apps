import Foundation
import Combine

/// A local match result. Local-first platform hook: matchReceiptReady / localHistoryReady.
struct MatchReceipt: Codable, Identifiable {
    let id: UUID
    let gameID: String
    let gameTitle: String
    let score: Int
    let date: Date
}

/// Local-first Prismcade platform services shared by every native game.
///
/// Implements the contract's local platform hooks for real (no backend required):
/// - `localProfileReady`  → a persisted player handle.
/// - `localHistoryReady`  → persisted per-game best scores.
/// - `matchReceiptReady`  → a persisted rolling list of recent match receipts.
/// - `leaderboardExportReady` → `exportLeaderboardJSON()` produces a portable payload that a
///   future `LeaderboardService` can POST to the shared Prismcade API (`functions/api/prismcade`)
///   — native should consume that backend, not re-implement it.
@MainActor
final class PrismcadePlatform: ObservableObject {
    static let shared = PrismcadePlatform()

    @Published private(set) var bestScores: [String: Int]
    @Published private(set) var receipts: [MatchReceipt]
    @Published var profileHandle: String {
        didSet { defaults.set(profileHandle, forKey: Keys.handle) }
    }

    private let defaults = UserDefaults.standard
    private let receiptCap = 25

    private enum Keys {
        static let best = "Prismcade.Platform.bestScores"
        static let receipts = "Prismcade.Platform.receipts"
        static let handle = "Prismcade.Platform.handle"
    }

    private init() {
        bestScores = (defaults.dictionary(forKey: Keys.best) as? [String: Int]) ?? [:]
        if let data = defaults.data(forKey: Keys.receipts),
           let decoded = try? JSONDecoder.iso.decode([MatchReceipt].self, from: data) {
            receipts = decoded
        } else {
            receipts = []
        }
        profileHandle = defaults.string(forKey: Keys.handle) ?? "Player One"
    }

    /// Record a finished run. Updates the best score and appends a match receipt.
    func recordResult(gameID: String, gameTitle: String, score: Int) {
        if score > (bestScores[gameID] ?? 0) {
            bestScores[gameID] = score
            defaults.set(bestScores, forKey: Keys.best)
        }
        let receipt = MatchReceipt(id: UUID(), gameID: gameID, gameTitle: gameTitle, score: score, date: Date())
        receipts.insert(receipt, at: 0)
        if receipts.count > receiptCap {
            receipts = Array(receipts.prefix(receiptCap))
        }
        if let data = try? JSONEncoder.iso.encode(receipts) {
            defaults.set(data, forKey: Keys.receipts)
        }
    }

    func best(for gameID: String) -> Int { bestScores[gameID] ?? 0 }

    func recentReceipts(for gameID: String? = nil, limit: Int = 8) -> [MatchReceipt] {
        let filtered = gameID.map { id in receipts.filter { $0.gameID == id } } ?? receipts
        return Array(filtered.prefix(limit))
    }

    /// Portable leaderboard payload for the shared Prismcade API to ingest later.
    func exportLeaderboardJSON() -> Data? {
        let payload: [String: Any] = [
            "schema": "prismcade-native-leaderboard-v0",
            "handle": profileHandle,
            "bestScores": bestScores,
            "receipts": receipts.map {
                ["gameID": $0.gameID, "score": $0.score, "date": ISO8601DateFormatter().string(from: $0.date)]
            }
        ]
        return try? JSONSerialization.data(withJSONObject: payload, options: [.prettyPrinted, .sortedKeys])
    }
}

private extension JSONDecoder {
    static let iso: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
}

private extension JSONEncoder {
    static let iso: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()
}
