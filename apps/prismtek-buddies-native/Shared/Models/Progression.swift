import Foundation

/// XP + level progression for completed focus sessions, plus a simple gift/unlock stub.
struct Progression: Codable, Equatable {
    var focusXP: Int = 0
    var focusSessions: Int = 0

    /// XP needed to reach the next level (flat, simple v0 curve).
    static let xpPerLevel = 100
    /// Per completed focus session.
    static let xpPerSession = 25
    /// Show a gift/unlock placeholder after this many focus sessions.
    static let sessionsPerGift = 4

    var level: Int { focusXP / Progression.xpPerLevel + 1 }

    var xpIntoLevel: Int { focusXP % Progression.xpPerLevel }

    var xpToNextLevel: Int { Progression.xpPerLevel - xpIntoLevel }

    /// Number of gift unlocks earned so far (placeholder reward).
    var giftsUnlocked: Int { focusSessions / Progression.sessionsPerGift }

    /// True right after a session count crosses a gift threshold.
    func justUnlockedGift(previousSessions: Int) -> Bool {
        (previousSessions / Progression.sessionsPerGift) < (focusSessions / Progression.sessionsPerGift)
    }

    mutating func completeFocusSession() {
        focusSessions += 1
        focusXP += Progression.xpPerSession
    }
}
