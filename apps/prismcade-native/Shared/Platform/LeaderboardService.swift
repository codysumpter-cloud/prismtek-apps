import Foundation
import Combine

/// Submits native match receipts to the shared Prismcade API, with a local-first, offline-safe
/// queue. Native consumes the existing backend (`functions/api/prismcade` in prismtek-site) rather
/// than re-implementing it.
///
/// Safety / config:
/// - No production URL is hard-coded. The base URL comes from the `PRISMCADE_API_BASE` environment
///   variable (or a future settings layer). When unset, the service stays in `.disabled` and only
///   queues locally — gameplay is never blocked and no network call is made.
/// - When configured, receipts are POSTed to `<base>/api/prismcade/scores` as fire-and-forget;
///   failures keep the receipt queued for a later `flush()`.
///
/// TODO (backend): the shared Prismcade API needs a `POST /api/prismcade/scores` endpoint that
/// accepts `{ handle, gameID, score, date }` (see `exportLeaderboardJSON()` for the bulk shape).
/// Until that exists + a configured base URL, this remains a local export queue by design.
@MainActor
final class LeaderboardService: ObservableObject {
    static let shared = LeaderboardService()

    enum SyncState: Equatable {
        case disabled
        case pending(Int)
        case syncing
        case synced
        case failed(String)
    }

    @Published private(set) var state: SyncState = .disabled

    private var pending: [MatchReceipt] = []
    private let defaults = UserDefaults.standard
    private let queueKey = "Prismcade.Leaderboard.pendingQueue"

    private var baseURL: URL? {
        guard let raw = ProcessInfo.processInfo.environment["PRISMCADE_API_BASE"], !raw.isEmpty else { return nil }
        return URL(string: raw)
    }

    private init() {
        if let data = defaults.data(forKey: queueKey),
           let decoded = try? JSONDecoder().decode([MatchReceipt].self, from: data) {
            pending = decoded
        }
        refreshState()
    }

    /// Queue a receipt and try to flush. Never throws, never blocks gameplay.
    func submit(_ receipt: MatchReceipt) {
        pending.append(receipt)
        persist()
        flush()
    }

    func flush() {
        guard let base = baseURL else {
            refreshState()
            return
        }
        guard !pending.isEmpty else {
            state = .synced
            return
        }
        state = .syncing
        let endpoint = base.appendingPathComponent("api/prismcade/scores")
        let batch = pending
        guard let body = try? JSONEncoder().encode(SyncPayload(handle: PrismcadePlatform.shared.profileHandle, receipts: batch)) else {
            state = .failed("encode")
            return
        }
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body
        URLSession.shared.dataTask(with: request) { [weak self] _, response, error in
            Task { @MainActor in
                guard let self else { return }
                if let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode), error == nil {
                    self.pending.removeAll { receipt in batch.contains { $0.id == receipt.id } }
                    self.persist()
                    self.state = self.pending.isEmpty ? .synced : .pending(self.pending.count)
                } else {
                    self.state = .failed(error?.localizedDescription ?? "http")
                }
            }
        }.resume()
    }

    var syncStateDescription: String {
        switch state {
        case .disabled: return "local-only (set PRISMCADE_API_BASE to sync)"
        case .pending(let n): return "\(n) pending"
        case .syncing: return "syncing…"
        case .synced: return "synced"
        case .failed(let reason): return "retry queued (\(reason))"
        }
    }

    private func persist() {
        if let data = try? JSONEncoder().encode(pending) {
            defaults.set(data, forKey: queueKey)
        }
        refreshState()
    }

    private func refreshState() {
        if baseURL == nil {
            state = .disabled
        } else {
            state = pending.isEmpty ? .synced : .pending(pending.count)
        }
    }

    private struct SyncPayload: Codable {
        let handle: String
        let receipts: [MatchReceipt]
    }
}
