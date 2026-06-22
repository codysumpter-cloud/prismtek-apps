import GameKit

/// Optional Game Center readiness. Authenticates if available and falls back to local-only —
/// never blocks gameplay, and works on unsigned local builds (authentication simply fails and we
/// stay offline). Score submission is staged behind leaderboard IDs that still require real App
/// Store Connect leaderboards + the Game Center entitlement to go live (see native README).
@MainActor
final class GameCenterService: ObservableObject {
    static let shared = GameCenterService()

    @Published private(set) var isAuthenticated = false
    @Published private(set) var statusText = "local-only"

    /// Leaderboard IDs to create in App Store Connect once the Game Center entitlement is added.
    static let leaderboardIDs: [String: String] = [
        "flappy-pixel": "com.prismtek.prismcade.flappy.score",
        "prismtek-dino-dash": "com.prismtek.prismcade.dino.score",
        "beat-em-up-buck": "com.prismtek.prismcade.buck.score"
    ]

    private init() {}

    /// Begins optional authentication. Safe to call on unsigned builds — on failure we stay local.
    func authenticate() {
        GKLocalPlayer.local.authenticateHandler = { [weak self] _, _ in
            Task { @MainActor in
                guard let self else { return }
                self.isAuthenticated = GKLocalPlayer.local.isAuthenticated
                self.statusText = self.isAuthenticated ? "Game Center: \(GKLocalPlayer.local.alias)" : "local-only"
            }
        }
    }

    /// Submit a run to the staged leaderboard. No-op unless authenticated + a leaderboard ID maps.
    func submitScore(_ score: Int, gameID: String) {
        guard isAuthenticated, let leaderboardID = Self.leaderboardIDs[gameID] else { return }
        GKLeaderboard.submitScore(score, context: 0, player: GKLocalPlayer.local, leaderboardIDs: [leaderboardID]) { _ in }
    }
}
